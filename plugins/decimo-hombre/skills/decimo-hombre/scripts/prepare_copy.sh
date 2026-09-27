#!/usr/bin/env bash
# Clean copy for the review: its own folder and git repo, outside ~/.claude, PII scan = 0.
# Usage: prepare_copy.sh <slug> <cloud|local> <file> [<file> ...]
#   Copies the files to $DH_BASE/<slug>/ (DH_BASE defaults to ~/decimo-hombre).
#   Write the brief (BRIEF-REVISION.md / REVIEW-BRIEF.md) BEFORE calling this and pass it as one more file.
#   cloud: also creates the PRIVATE repo <gh-user>/dh-<slug> and pushes.
#   Extra PII: DH_PII_EXTRA=<file with one regex per line> (customer names, own domains…).
set -euo pipefail
slug="$1"; modo="$2"; shift 2
base="${DH_BASE:-$HOME/decimo-hombre}"
dir="$base/$slug"
case "$dir" in "$HOME/.claude"*) echo "ERROR: the copy cannot live inside ~/.claude (claude --cloud refuses to upload it)"; exit 2;; esac
[ -e "$dir" ] && { echo "ERROR: $dir already exists; use another slug"; exit 2; }
mkdir -p "$dir"
for f in "$@"; do cp "$f" "$dir/"; done
extra=(); [ -n "${DH_PII_EXTRA:-}" ] && extra=(--extra "$DH_PII_EXTRA")
if ! python3 "$(dirname "$0")/scan_pii.py" "$dir" ${extra[@]+"${extra[@]}"}; then
  echo "ERROR: personal data or secrets found in the copy; clean them and retry (folder left at $dir)"; exit 1
fi
# Auditor defaults (recommended: Opus 5.5 at max effort advising with Fable). A project-level
# .claude/settings.json applies in local sessions and in cloud sessions (docs: model-config, cloud).
# Override with DH_MODEL / DH_EFFORT / DH_ADVISOR.
mkdir -p "$dir/.claude"
# `max` effort only persists through CLAUDE_CODE_EFFORT_LEVEL (docs: model-config), so it goes in `env`.
printf '{\n  "model": "%s",\n  "advisorModel": "%s",\n  "env": { "CLAUDE_CODE_EFFORT_LEVEL": "%s" }\n}\n' \
  "${DH_MODEL:-claude-opus-5-5}" "${DH_ADVISOR:-fable}" "${DH_EFFORT:-max}" > "$dir/.claude/settings.json"
cd "$dir"; git init -q -b main; git add -A; git commit -qm "decimo-hombre: clean copy for review ($slug)"
if [ "$modo" = cloud ] || [ "$modo" = nube ]; then
  user=$(gh api user --jq .login)
  gh repo create "$user/dh-$slug" --private --source . --push >/dev/null
  echo "REPO $user/dh-$slug"
fi
echo "DIR $dir"
