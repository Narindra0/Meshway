import { init, callTool } from './mcp-client.mjs';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(HERE, '..', '..');

// Markdown sources live in docs/notion/ and are the single source of truth.
const DIR = path.join(REPO, 'docs', 'notion');
// Verification artifacts are written to a scratch directory that is never committed.
const OUT = process.env.NOTION_OUT_DIR ?? path.join(REPO, '.notion-oauth');
fs.mkdirSync(OUT, { recursive: true });

const HUB = '400b224ccfa681ec9ab7d83a4a38ce60';
const PAGES = [
  { n: '01', file: '01-hub.md', id: HUB },
  { n: '02', file: '02-vision-perimetre-decisions.md', id: '400b224ccfa681f99afafde49e02bbf1' },
  { n: '03', file: '03-architecture-technique.md', id: '400b224ccfa681d389bfcf62dc7c9549' },
  { n: '04', file: '04-protocole-mesh.md', id: '400b224ccfa6814f9039e830b5e00fa9' },
  { n: '05', file: '05-alertes-securite.md', id: '400b224ccfa68177bd57e0b2588f92ed' },
  { n: '06', file: '06-transport-ble.md', id: '400b224ccfa681ce8ebfcd22750e715b' },
  { n: '07', file: '07-ux-design.md', id: '400b224ccfa68116ae9cdf32389687f2' },
  { n: '08', file: '08-donnees-persistance.md', id: '400b224ccfa681b0a726f170934dfa2f' },
  { n: '09', file: '09-tests-deploiement.md', id: '400b224ccfa68179b62df16f1b1ce218' },
  { n: '10', file: '10-guide-developpeur.md', id: '400b224ccfa681d2a341fcc1c8685d8a' },
  { n: '11', file: '11-risques-roadmap.md', id: '400b224ccfa681deb74bcb16369dde8f' },
];

function textOf(res) {
  const c = res?.result?.content;
  if (Array.isArray(c)) return c.map(b => b.text ?? '').join('\n');
  return JSON.stringify(res?.result?.structuredContent ?? res, null, 2);
}

// ---------------------------------------------------------------------------
// Fix: page 10 kept its H1 in the body (duplicate of the page title).
// Idempotent: only applies if the duplicate is still present.
// ---------------------------------------------------------------------------
const PAGE10 = '400b224ccfa681d2a341fcc1c8685d8a';

const pre10 = await callTool('notion-fetch', { id: PAGE10 });
const pre10Text = textOf(pre10);
if (/# Guide du développeur/.test(pre10Text)) {
  const fix = await callTool('notion-update-page', {
    page_id: PAGE10,
    command: 'update_content',
    content_updates: [{ old_str: '# Guide du développeur\n\n', new_str: '' }],
  });
  console.log('FIX 10 =>', textOf(fix).slice(0, 400));
} else {
  console.log('FIX 10 => already clean (no duplicate H1)');
}

// ---------------------------------------------------------------------------
// Verification pass
// ---------------------------------------------------------------------------
const report = [];
for (const p of PAGES) {
  const res = await callTool('notion-fetch', { id: p.id });
  const t = textOf(res);
  fs.writeFileSync(`${OUT}/fetch-${p.n}.txt`, t, 'utf8');

  const mdPath = `${DIR}/${p.file}`;
  const local = fs.existsSync(mdPath) ? fs.readFileSync(mdPath, 'utf8') : '';
  const localH1 = (local.match(/^#\s+(.+)$/m) || [])[1] || '';
  const localTitle = localH1.trim();

  let title = '', content = '', ancestor = '';
  try {
    const j = JSON.parse(t);
    title = j.title ?? '';
    const inner = j.text ?? '';
    const m = inner.match(/<content>([\s\S]*?)<\/content>/);
    content = m ? m[1] : inner;
    const a = inner.match(/<ancestor-path>([\s\S]*?)<\/ancestor-path>/);
    ancestor = a ? a[1] : '';
  } catch (e) {
    content = t;
  }

  // Notion titles carry the numeric prefix and a leading emoji (e.g. "🧭 02 — Vision, périmètre et décisions").
  const titleClean = title.replace(/^\s*\p{Extended_Pictographic}[\s️️]*\s*/u, '').trim();
  const expectedTitle = p.n === '01' ? 'Hafatra — Centre de documentation' : `${p.n} — ${localTitle}`;
  const titleOk = titleClean === expectedTitle;

  const parentHub = /400b224ccfa681ec9ab7d83a4a38ce60/.test(ancestor);
  const parentOk = p.n === '01' ? ancestor.replace(/\s/g, '') === '' : parentHub;

  // Duplicate H1 in body: the body must not repeat the page title as a heading.
  // Code fences are stripped first so shell comments (e.g. "# Vérifier l'alerte") are not read as headings.
  const stripFences = s => s.replace(/```[\s\S]*?```/g, '');
  const bodyHeadings = (stripFences(content).match(/^#{1,6}\s.*$/gm) || [])
    .map(s => s.replace(/^#+\s*/, '').trim());
  const dupH1 = bodyHeadings.filter(h => h === localTitle);

  // Normalize both sides to plain text so formatting differences don't create false positives.
  // Strips: bold/italic markers, inline code, HTML tags, list markers, link syntax, emoji, whitespace.
  const norm = s => s
    .replace(/\[([^\]]*)\]\([^)]*\)/g, '$1')        // [text](url) -> text
    .replace(/<\/?code>/g, '')
    .replace(/<\/?b>/g, '')
    .replace(/<\/?i>/g, '')
    .replace(/<br\s*\/?>/g, ' ')
    .replace(/<[^>]+>/g, '')
    .replace(/\\([*_`~\[\]])/g, '$1')              // markdown escapes
    .replace(/`+/g, '')                            // inline code
    .replace(/\*\*|__/g, '')                       // bold
    .replace(/(^|[\s(])\*([^*\n]+)\*/g, '$1$2')     // italic
    .replace(/~~/g, '')                            // strikethrough
    .replace(/^\s*[-*+]\s+/gm, '')                 // bullet marker
    .replace(/^\s*\d+\.\s+/gm, '')                 // ordered marker
    .replace(/^\s*#+\s*/gm, '')                    // heading marker
    .replace(/^\s*>\s?/gm, '')                     // blockquote marker
    .replace(/^\s*\|?[-:| ]+\|\s*$/gm, '')         // table separator row
    .replace(/\p{Extended_Pictographic}/gu, '')     // emoji
    .replace(/[ \t]+/g, ' ')
    .replace(/\s*\n\s*/g, '\n')
    .trim();
  const contentNorm = norm(content);

  // Every local H2 must survive.
  const localH2 = (local.match(/^##\s+(.+)$/gm) || []).map(s => norm(s.replace(/^##\s+/, '')));
  const missingH2 = localH2.filter(h => h && !contentNorm.includes(h));

  // Every local H3 must survive.
  const localH3 = (local.match(/^###\s+(.+)$/gm) || []).map(s => norm(s.replace(/^###\s+/, '')));
  const missingH3 = localH3.filter(h => h && !contentNorm.includes(h));

  // Code fences
  const localFences = (local.match(/^```/gm) || []).length;
  const fetchFences = (content.match(/```/g) || []).length;

  // Table rows
  const localTableRows = (local.match(/^\|.+\|$/gm) || []).length;
  const fetchTableRows = (content.match(/^\|.+\|$/gm) || []).length;

  // Prose coverage: every non-trivial local text line must appear in the fetched body.
  // The H1 line is excluded: it becomes the Notion page title, not body content.
  const localLines = local
    .split(/\r?\n/)
    .filter(l => !/^#\s/.test(l))
    .map(l => norm(l))
    .filter(l => l.length >= 25 && !l.startsWith('|') && !l.startsWith('```'));
  const missingLines = localLines.filter(l => !contentNorm.includes(l));

  const links = [...new Set(content.match(/https:\/\/app\.notion\.com\/p\/[0-9a-f]{32}/g) || [])];
  const err = /"code":\s*"validation_error"|"object":\s*"error"/.test(t);

  const row = {
    n: p.n, id: p.id, len: t.length, title: titleClean, titleOk, parentOk,
    dupH1, localFences, fetchFences, localTableRows, fetchTableRows,
    links: links.length, missingH2, missingH3, missingLines, err,
  };
  report.push(row);

  const bad = !titleOk || !parentOk || dupH1.length || err || missingH2.length || missingH3.length || missingLines.length
    || fetchFences !== localFences || fetchTableRows !== localTableRows;
  console.log(
    `${p.n} title=${titleOk ? 'OK' : 'BAD(' + titleClean + ')'} parent=${parentOk ? 'OK' : 'BAD'} ` +
    `dupH1=${dupH1.length} fences=${fetchFences}/${localFences} tbl=${fetchTableRows}/${localTableRows} ` +
    `links=${links.length} missH2=${missingH2.length} missH3=${missingH3.length} missLine=${missingLines.length}${bad ? '  <== ISSUE' : ''}`
  );
  if (dupH1.length) console.log('   DUP H1:', JSON.stringify(dupH1));
  if (missingH2.length) console.log('   missing H2:', JSON.stringify(missingH2));
  if (missingH3.length) console.log('   missing H3:', JSON.stringify(missingH3));
  if (missingLines.length) console.log('   missing lines:', JSON.stringify(missingLines.slice(0, 5)));
}

fs.writeFileSync(`${OUT}/verify-report.json`, JSON.stringify(report, null, 2), 'utf8');
console.log('\nWrote verify-report.json');
