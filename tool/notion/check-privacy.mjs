import { init, callTool } from './mcp-client.mjs';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(HERE, '..', '..');
const OUT = process.env.NOTION_OUT_DIR ?? path.join(REPO, '.notion-oauth');
fs.mkdirSync(OUT, { recursive: true });

function textOf(res) {
  const c = res?.result?.content;
  if (Array.isArray(c)) return c.map(b => b.text ?? '').join('\n');
  return JSON.stringify(res?.result?.structuredContent ?? res, null, 2);
}

const HUB = '400b224ccfa681ec9ab7d83a4a38ce60';
const CHILDREN = [
  '400b224ccfa681f99afafde49e02bbf1','400b224ccfa681d389bfcf62dc7c9549',
  '400b224ccfa6814f9039e830b5e00fa9','400b224ccfa68177bd57e0b2588f92ed',
  '400b224ccfa681ce8ebfcd22750e715b','400b224ccfa68116ae9cdf32389687f2',
  '400b224ccfa681b0a726f170934dfa2f','400b224ccfa68179b62df16f1b1ce218',
  '400b224ccfa681d2a341fcc1c8685d8a','400b224ccfa681deb74bcb16369dde8f',
];

await init();

const priv = textOf(await callTool('notion-list-private-pages', {}));
const shared = textOf(await callTool('notion-list-shared-pages', {}));

console.log('PRIVATE contains hub id  :', priv.includes(HUB));
console.log('PRIVATE contains hub url :', priv.includes('https://app.notion.com/p/' + HUB));
console.log('PRIVATE contains "Hafatra — Centre de documentation":', priv.includes('Centre de documentation'));
console.log('SHARED  contains hub id  :', shared.includes(HUB));

const leaked = CHILDREN.filter(id => shared.includes(id));
console.log('Children visible in Shared:', leaked.length, leaked.join(', '));

fs.writeFileSync(path.join(OUT, 'privacy-check.txt'), priv + '\n\n===== SHARED =====\n' + shared, 'utf8');
console.log('Wrote privacy-check.txt');
