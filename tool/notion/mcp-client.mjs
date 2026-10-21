import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(HERE, '..', '..');

// The OAuth access token is NOT stored in the repository.
// Provide it through the NOTION_TOKEN environment variable, or point NOTION_TOKEN_FILE
// at a local file that is kept out of version control.
const TOKEN_FILE = process.env.NOTION_TOKEN_FILE
  ?? path.join(REPO, '.notion-oauth', 'access_token.txt');

function readToken() {
  if (process.env.NOTION_TOKEN) return process.env.NOTION_TOKEN.trim();
  try {
    const t = fs.readFileSync(TOKEN_FILE, 'utf8').trim();
    if (t) return t;
  } catch {
    /* fall through to the explicit error below */
  }
  throw new Error(
    'No Notion access token found.\n' +
    'Set NOTION_TOKEN=<token>, or NOTION_TOKEN_FILE=<path> pointing at a local token file.\n' +
    `Default token file (git-ignored) would be: ${TOKEN_FILE}`
  );
}

const TOKEN = readToken();
const MCP_URL = 'https://mcp.notion.com/mcp';

let sessionId = null;
let rpcId = 0;

async function rpc(method, params = {}, notification = false) {
  const payload = { jsonrpc: '2.0', method, params };
  if (!notification) payload.id = ++rpcId;

  const headers = {
    Authorization: `Bearer ${TOKEN}`,
    'Content-Type': 'application/json',
    Accept: 'application/json, text/event-stream',
  };
  if (sessionId) headers['Mcp-Session-Id'] = sessionId;

  const res = await fetch(MCP_URL, {
    method: 'POST',
    headers,
    body: JSON.stringify(payload),
  });

  const sid = res.headers.get('mcp-session-id');
  if (sid) sessionId = sid;

  const text = await res.text();
  if (!text.trim()) return null;

  let out = null;
  for (const line of text.split(/\r?\n/)) {
    if (line.startsWith('data: ')) {
      try { out = JSON.parse(line.slice(6)); } catch { /* keep last */ }
    }
  }
  if (!out) {
    try { out = JSON.parse(text); } catch { out = { raw: text.slice(0, 2000) }; }
  }
  return out;
}

export async function init() {
  const r = await rpc('initialize', {
    protocolVersion: '2025-06-18',
    capabilities: {},
    clientInfo: { name: 'hafatra-publisher', version: '1.0.0' },
  });
  await rpc('notifications/initialized', {}, true);
  return r;
}

export async function listTools() {
  const r = await rpc('tools/list', {});
  return r?.result?.tools ?? [];
}

export async function callTool(name, args) {
  const r = await rpc('tools/call', { name, arguments: args });
  return r;
}

export function session() { return sessionId; }
