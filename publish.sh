#!/bin/bash
# Publish Typo Studio to GitHub: create the repo (if it isn't there), push README / ABOUT / .gitignore / assets, and
# publish release v1.0.0 with the .dmg and .zip attached (Releases take files up to 2 GB).
# Needs the GitHub CLI, signed in once:  gh auth login
# Usage:  ./publish.sh            (repo "typo-studio", public)
#         ./publish.sh my-name    (another repo name)
set -euo pipefail
cd "$(dirname "$0")"
REPO="${1:-typo-studio}"; TAG="v1.0.0"; TITLE="Typo Studio 1.0.0"
GH="$(command -v gh || true)"; [ -z "$GH" ] && [ -x /usr/local/bin/gh ] && GH=/usr/local/bin/gh; [ -z "$GH" ] && [ -x /opt/homebrew/bin/gh ] && GH=/opt/homebrew/bin/gh
[ -n "$GH" ] || { echo "GitHub CLI not found — install it from https://cli.github.com, then run: gh auth login"; exit 1; }
"$GH" auth status >/dev/null 2>&1 || { echo "Not signed in — run: gh auth login"; exit 1; }
OWNER="$("$GH" api user -q .login)"; echo "• GitHub account: $OWNER · repo: $OWNER/$REPO"
DESC="Vertical-first video editor for Reels, Shorts & TikTok — vertical timeline, pro colour grading with 75+ looks and 47 filters, on-device AI subject detection, and Claude + MCP built in. macOS (Apple silicon)."
TOPICS="video-editor,vertical-video,reels,shorts,tiktok,motion-graphics,color-grading,lut,macos,apple-silicon,electron,claude,mcp,ai,subject-detection"

# 1. the repo (created public if it doesn't exist yet)
if ! "$GH" repo view "$OWNER/$REPO" >/dev/null 2>&1; then echo "• creating $OWNER/$REPO (public)…"; "$GH" repo create "$OWNER/$REPO" --public --description "$DESC" >/dev/null; fi
"$GH" repo edit "$OWNER/$REPO" --description "$DESC" $(for t in ${TOPICS//,/ }; do printf -- "--add-topic %s " "$t"; done) >/dev/null || true

# 2. the files (git; the .dmg / .zip stay out — .gitignore)
[ -d .git ] || git init -q -b main
git config user.name >/dev/null 2>&1 || git config user.name "$OWNER"
git config user.email >/dev/null 2>&1 || git config user.email "$OWNER@users.noreply.github.com"
git add README.md ABOUT.md .gitignore assets RELEASE-NOTES.md publish.sh
git diff --cached --quiet || git commit -q -m "Typo Studio 1.0.0 — README, assets and release notes"
git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$OWNER/$REPO.git"
"$GH" auth setup-git >/dev/null 2>&1 || true
echo "• pushing files…"; git push -q -u origin main

# 3. the release with the app attached
if "$GH" release view "$TAG" -R "$OWNER/$REPO" >/dev/null 2>&1; then
  echo "• updating release $TAG (replacing the app files)…"; "$GH" release upload "$TAG" Typo-1.0.0-arm64.dmg Typo-1.0.0-arm64-mac.zip -R "$OWNER/$REPO" --clobber
else
  echo "• publishing release $TAG with the app attached (about 180 MB each — takes a few minutes)…"
  "$GH" release create "$TAG" Typo-1.0.0-arm64.dmg Typo-1.0.0-arm64-mac.zip -R "$OWNER/$REPO" --title "$TITLE" --notes-file RELEASE-NOTES.md
fi
echo "✓ Done: https://github.com/$OWNER/$REPO  ·  download: https://github.com/$OWNER/$REPO/releases/latest"
echo "  Last step (GitHub has no command for it): Settings → General → Social preview → upload assets/social-preview.png"
