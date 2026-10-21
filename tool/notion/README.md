# Notion publishing tooling

Scripts that publish the documentation hub to Notion and verify the result.

| Script | Role |
| --- | --- |
| `get-token.ps1` | Acquires a Notion MCP OAuth access token via the PKCE flow and writes it to the git-ignored `.notion-oauth/access_token.txt`. |
| `validate.mjs` | Static checks on the Markdown sources (balanced fences, single H1, supported tags, table shape). |
| `publish.mjs` | Fetches every page from Notion and compares it against the sources. Reports per-page title, parent, code-fence, table-row, link and prose coverage. |
| `check-privacy.mjs` | Confirms the hub appears in the Notion **Private** section and that no page leaked into **Shared**. |
| `mcp-client.mjs` | Minimal JSON-RPC client for the Notion MCP endpoint. |

## Sources of truth

- `docs/notion/*.md` — the Markdown for the hub and its 10 child pages. Edit these; they are the
  single source of truth for the published content.
- The Notion page IDs are hard-coded in `publish.mjs` (`PAGES`) and `check-privacy.mjs` (`CHILDREN`).

## Authentication

The OAuth access token is **not** stored in the repository. Acquire one with:

```powershell
.\tool\notion\get-token.ps1
```

The script prints an authorization URL, waits for the browser redirect, and writes the token to
`.notion-oauth/access_token.txt` — a git-ignored path. It never prints the token itself.

Alternatively, provide a token directly:

```powershell
$env:NOTION_TOKEN = '<token>'
# or
$env:NOTION_TOKEN_FILE = 'C:\path\to\access_token.txt'
```

`mcp-client.mjs` falls back to `.notion-oauth/access_token.txt` (git-ignored) when neither is set,
and fails with an explicit message when no token is available.

## Usage

```powershell
node tool/notion/validate.mjs       # validate the sources
node tool/notion/publish.mjs         # fetch from Notion and diff against the sources
node tool/notion/check-privacy.mjs   # verify the hub stays private
```

Verification artifacts (`fetch-NN.txt`, `verify-report.json`, `privacy-check.txt`) are written to
`.notion-oauth/` (git-ignored) unless `NOTION_OUT_DIR` points elsewhere.

## Comparison notes

Notion normalizes Markdown on write: emphasis becomes `<b>`/`<i>`, inline code becomes `<code>`,
list numbering is stored outside the text, and underscores are escaped as `\_`. `publish.mjs`
normalizes both sides to plain text before comparing so that formatting differences are not
reported as missing content.
