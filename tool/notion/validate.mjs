import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(HERE, '..', '..');
const DIR = process.env.DOCS_DIR ?? path.join(REPO, 'docs', 'notion');
const ALLOWED_TAGS = new Set([
  'b','i','s','u','span','mention','date','link-preview',
  'p','h1','h2','h3','h4','quote','toggle','li','column','columns','tab',
  'mail','meeting-notes','callout','todo','equation','table-of-contents',
  'image','pdf','file','audio','video','bookmark','embed','page','folder',
  'database','synced-block','synced-block-reference','custom-block',
  'external_object_instance','meeting-notes-section-notes',
  'meeting-notes-section-summary','meeting-notes-section-transcript',
  'ul','ol','table','tr','th','td','colgroup','col',
]);

const fenceRe = /^(`{3,}|~{3,})(.*)$/;

let problems = 0;

for (const name of fs.readdirSync(DIR).filter(f => f.endsWith('.md')).sort()) {
  const raw = fs.readFileSync(path.join(DIR, name), 'utf8');
  const lines = raw.split(/\r?\n/);
  const issues = [];

  // Strip fenced code blocks and inline code spans before tag/H1 checks
  const fenceRe = /^(`{3,}|~{3,})(.*)$/;
  let inFence = false, fenceCh = '';
  const stripped = [];
  for (const l of lines) {
    const fm = l.match(fenceRe);
    if (fm) {
      if (!inFence) { inFence = true; fenceCh = fm[1][0]; stripped.push(''); }
      else if (fm[1][0] === fenceCh) { inFence = false; stripped.push(''); }
      else stripped.push('');
      continue;
    }
    stripped.push(inFence ? '' : l.replace(/`[^`\n]*`/g, m => ' '.repeat(m.length)));
  }
  const clean = stripped.join('\n');

  // Title
  const titleLine = lines.find(l => l.startsWith('# '));
  if (!titleLine) issues.push('MISSING H1 TITLE');
  if (stripped.filter(l => l.startsWith('# ')).length > 1) issues.push('MULTIPLE H1');

  // Append markers / placeholders
  for (const marker of ['<!--APPEND-->', 'APPEND', 'TODO:', 'FIXME', 'XXX', 'Lorem ipsum', 'PLACEHOLDER']) {
    if (raw.includes(marker)) issues.push(`MARKER FOUND: ${marker}`);
  }

  // Code fences balanced
  let open = null, openLine = 0;
  lines.forEach((l, i) => {
    const m = l.match(fenceRe);
    if (!m) return;
    if (open === null) { open = m[1]; openLine = i + 1; }
    else if (m[1].length >= open.length && m[1][0] === open[0]) { open = null; }
  });
  if (open !== null) issues.push(`UNCLOSED CODE FENCE at line ${openLine}`);

  // One-copyable-block rule: inner backtick run must be shorter than fence
  {
    let inF = false, fCh = '', fLen = 0, fStart = 0;
    lines.forEach((l, i) => {
      const m = l.match(fenceRe);
      if (m) {
        if (!inF) { inF = true; fCh = m[1][0]; fLen = m[1].length; fStart = i + 1; }
        else if (m[1][0] === fCh) inF = false;
        return;
      }
      if (!inF) return;
      const runs = l.match(/`+/g) || [];
      for (const r of runs) {
        if (r.length >= fLen) issues.push(`BACKTICK RUN >= FENCE at line ${i + 1} (fence ${fLen}, run ${r.length})`);
      }
    });
  }

  // Indented code blocks (4 spaces) outside fences
  {
    let inF2 = false, fCh2 = '';
    lines.forEach((l, i) => {
      const m = l.match(fenceRe);
      if (m) { if (!inF2) { inF2 = true; fCh2 = m[1][0]; } else if (m[1][0] === fCh2) inF2 = false; return; }
      if (inF2) return;
      if (/^ {4,}\S/.test(l) && !/^\s*[-*+]\s/.test(l) && !/^\s*\d+\.\s/.test(l)) {
        issues.push(`POSSIBLE INDENTED CODE BLOCK at line ${i + 1}: ${l.slice(0, 50)}`);
      }
    });
  }

  // Blockquote with children (needs <quote> tag form)
  {
    let inF3 = false, fCh3 = '';
    for (let i = 0; i < lines.length; i++) {
      const l = lines[i];
      const m = l.match(fenceRe);
      if (m) { if (!inF3) { inF3 = true; fCh3 = m[1][0]; } else if (m[1][0] === fCh3) inF3 = false; continue; }
      if (inF3) continue;
      if (/^>\s*$/.test(l)) {
        // blank quote line -> look ahead for nested list/paragraph
        let j = i + 1, found = null;
        while (j < lines.length && /^>/.test(lines[j])) {
          if (/^>\s*([-*+]|\d+\.)\s/.test(lines[j])) { found = 'list'; break; }
          j++;
        }
        if (found) issues.push(`BLOCKQUOTE WITH ${found.toUpperCase()} CHILD at line ${i + 1} (use <quote> tag)`);
      }
    }
  }

  // HTML tags (check cleaned text)
  const tagRe = /<\/?([a-zA-Z][a-zA-Z0-9-]*)(\s[^>]*)?\/?>/g;
  let tm;
  while ((tm = tagRe.exec(clean)) !== null) {
    const t = tm[1].toLowerCase();
    if (!ALLOWED_TAGS.has(t)) issues.push(`UNSUPPORTED TAG <${t}> at offset ${tm.index}`);
  }

  // Table sanity: each table block rows have consistent pipe counts
  let table = [];
  const flush = () => {
    if (table.length < 2) { table = []; return; }
    const counts = table.map(r => (r.match(/\|/g) || []).length);
    if (new Set(counts).size > 1) issues.push(`TABLE RAGGED (pipes ${counts.join(',')}) near: ${table[0].slice(0,60)}`);
    table = [];
  };
  for (const l of stripped) {
    if (/^\s*\|.*\|\s*$/.test(l)) table.push(l);
    else flush();
  }
  flush();

  // Non-ASCII stray CJK (should be French)
  const cjk = clean.match(/[\u4e00-\u9fff\u3040-\u30ff]/g);
  if (cjk) issues.push(`CJK FOUND: ${[...new Set(cjk)].join('')}`);

  // Raw HTML-looking non-tag leftovers
  const ang = clean.match(/<(?![a-zA-Z/!])/g);
  if (ang) issues.push('SUSPICIOUS < CHARACTER');

  if (issues.length) {
    problems += issues.length;
    console.log(`\n### ${name}`);
    for (const i of issues) console.log('  - ' + i);
  } else {
    console.log(`OK  ${name}`);
  }
}

console.log(`\nTOTAL PROBLEMS: ${problems}`);
