<#
.SYNOPSIS
  Acquires a Notion MCP OAuth access token using the PKCE flow.

.DESCRIPTION
  Starts a local loopback listener, prints the authorization URL, waits for the
  redirect, exchanges the authorization code for an access token, and writes the
  token to a local, git-ignored file.

  The token is NEVER committed. It is written to .notion-oauth/access_token.txt
  (git-ignored) and can also be consumed via the NOTION_TOKEN environment variable.

.EXAMPLE
  .\tool\notion\get-token.ps1
  .\tool\notion\get-token.ps1 -ClientId "8h3qINvVsU_Py8AG" -Port 8791
#>
[CmdletBinding()]
param(
  [string] $ClientId = "8h3qINvVsU_Py8AG",
  [int]    $Port = 8791
)

$ErrorActionPreference = "Stop"

$dir = Join-Path $PSScriptRoot "..\..\.notion-oauth"
$dir = [System.IO.Path]::GetFullPath($dir)
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

$redirectUri = "http://localhost:$Port/callback"
$state = [guid]::NewGuid().ToString("N")

# --- PKCE -------------------------------------------------------------------
$verifier = [Convert]::ToBase64String((1..48 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 })).TrimEnd("=").Replace("+","-").Replace("/","_")
$sha = [System.Security.Cryptography.SHA256]::Create()
$challenge = [Convert]::ToBase64String($sha.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($verifier))).TrimEnd("=").Replace("+","-").Replace("/","_")
Set-Content -Path "$dir\verifier.txt" -Value $verifier -NoNewline
Set-Content -Path "$dir\state.txt" -Value $state -NoNewline

$authUrl = "https://mcp.notion.com/authorize?client_id=$ClientId&response_type=code" +
  "&redirect_uri=$([uri]::EscapeDataString($redirectUri))" +
  "&code_challenge=$challenge&code_challenge_method=S256&state=$state"
Set-Content -Path "$dir\authorize_url.txt" -Value $authUrl -NoNewline

Write-Host ""
Write-Host "Open this URL in your browser and approve the request:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  $authUrl" -ForegroundColor White
Write-Host ""
Write-Host "Waiting for the redirect on $redirectUri ..." -ForegroundColor DarkGray

# --- Loopback listener ------------------------------------------------------
# A raw TCP listener is used instead of HttpListener because the Notion redirect
# hits a non-root path and HttpListener prefix matching can reject it.
$code = $null
try {
  $tcp = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, $Port)
  try {
    $tcp.Start()
  } catch {
    throw "Port $Port is already in use. Close whatever is listening there (or pass -Port <other>)."
  }
  $client = $tcp.AcceptTcpClient()
  $stream = $client.GetStream()
  $reader = New-Object System.IO.StreamReader($stream)

  $reqLine = $reader.ReadLine()
  $requestUrl = ($reqLine -split " ")[1]
  while (($line = $reader.ReadLine()) -ne "") { }

  if ($requestUrl -match "code=([^&\s]+)") { $code = [uri]::UnescapeDataString($Matches[1]) }

  $body = "<html><body style='font-family:sans-serif;padding:40px'><h2>Autorisation Notion accordee</h2><p>Fermez cette fenetre et revenez dans Cline.</p></body></html>"
  $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)
  $header = "HTTP/1.1 200 OK`r`nContent-Type: text/html; charset=utf-8`r`nContent-Length: $($bodyBytes.Length)`r`nConnection: close`r`n`r`n"
  $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($header)
  $stream.Write($headerBytes, 0, $headerBytes.Length)
  $stream.Write($bodyBytes, 0, $bodyBytes.Length)
  $stream.Flush()
  $client.Close()
  $tcp.Stop()
} catch {
  Write-Host "Listener error: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}

if (-not $code) {
  Write-Host "No authorization code received." -ForegroundColor Red
  exit 1
}

# --- Exchange the code for a token -----------------------------------------
# Notion's MCP token endpoint expects application/x-www-form-urlencoded and
# requires the `resource` parameter to match the MCP server URL.
$form = @(
  "client_id=$([uri]::EscapeDataString($ClientId))",
  "code=$([uri]::EscapeDataString($code))",
  "grant_type=authorization_code",
  "redirect_uri=$([uri]::EscapeDataString($redirectUri))",
  "code_verifier=$([uri]::EscapeDataString($verifier))",
  "resource=$([uri]::EscapeDataString("https://mcp.notion.com/mcp"))"
) -join "&"

$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://mcp.notion.com/token" -ContentType "application/x-www-form-urlencoded" -Body $form

if (-not $tokenResponse.access_token) {
  Write-Host "Token exchange failed: $($tokenResponse | ConvertTo-Json -Depth 5)" -ForegroundColor Red
  exit 1
}

Set-Content -Path "$dir\access_token.txt" -Value $tokenResponse.access_token -NoNewline
Remove-Item "$dir\code.txt" -ErrorAction SilentlyContinue
Remove-Item "$dir\verifier.txt" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Access token written to $dir\access_token.txt" -ForegroundColor Green
Write-Host "Scope: $($tokenResponse.scope)" -ForegroundColor DarkGray
Write-Host "This directory is git-ignored; the token is never committed." -ForegroundColor DarkGray
