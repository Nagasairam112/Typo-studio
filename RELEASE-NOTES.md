# Typo Studio 1.0.0 — macOS (Apple silicon)

A vertical-first video editor with motion graphics, colour grading and AI subject tools.

## Install
1. Download **Typo-1.0.0-arm64.dmg** below and drag **Typo** into Applications.
2. The first time, right-click Typo → **Open** → **Open** (the app isn't notarised by Apple yet).
   If macOS says it's damaged, run once in Terminal: `xattr -dr com.apple.quarantine /Applications/Typo.app`

Requires an Apple silicon Mac (M1 or later), macOS 14 or newer for subject detection.

## Watermark
Exported videos carry a small "made with Typo" mark. Enter your TyKey in Typo › Settings… › TyKey to remove it.

## Claude & MCP
- **Ask Claude** — add your Anthropic API key in Typo › Settings… › Connections, then type `ask …` in the command bar.
- **MCP server** — switch it on in the same place to let Claude Code, Claude Desktop or any MCP client drive Typo (local only, token-protected).
