#!/usr/bin/env bash
# Starts the auditor session with the advisor already set, then hands it the prompt.
# Usage: launch.sh <cloud|local> <copy-dir> "<prompt>" [advisor-model=fable]
# Why this way (measured 2026-09-26):
#   · '/advisor X <prompt>' in one message does NOT set the advisor: the slash command must be alone.
#   · A cross-session message to a cloud session ARRIVES but does not start work; what works:
#     'claude -p "<prompt>" --cloud <session_id>'.
#   · 'claude --cloud <id>' (attach) may not be enabled for your account.
#   · A new folder opens the 'trust this folder' dialog with 'No, exit' preselected.
set -euo pipefail
modo="$1"; dir="$2"; prompt="$3"; modelo="${4:-fable}"
ses="dh-$(basename "$dir" | tr -cd 'a-zA-Z0-9-' | cut -c1-30)"
tmux kill-session -t "$ses" 2>/dev/null || true
pane() { tmux capture-pane -pt "$ses" 2>/dev/null | grep -v '^\s*$' || true; }
confiar() {  # accept the trust dialog if it shows up
  for _ in $(seq 1 15); do
    sleep 2
    if pane | grep -q 'Yes, I trust'; then
      tmux send-keys -t "$ses" Down; sleep 1
      pane | grep -q '❯ Yes, I trust' && tmux send-keys -t "$ses" Enter
      return 0
    fi
    pane | grep -qE 'Created cloud session|\? for shortcuts|Error' && return 0
  done
}
if [ "$modo" = cloud ] || [ "$modo" = nube ]; then
  tmux new-session -d -x 200 -y 50 -s "$ses" -c "$dir" "claude --cloud '/advisor $modelo'; sleep 600"
  confiar
  id=""
  for _ in $(seq 1 45); do
    id=$(pane | grep -oE 'session_[A-Za-z0-9]+' | head -1 || true)
    [ -n "$id" ] && break
    pane | grep -q 'Error' && { pane; exit 1; }
    sleep 2
  done
  [ -z "$id" ] && { echo "ERROR: the cloud session did not appear"; pane; exit 1; }
  # Measured 2026-09-26: the uploaded working tree arrives WITHOUT a git remote, so the push fails.
  # Tell the auditor where to push.
  remoto=$(git -C "$dir" remote get-url origin 2>/dev/null || true)
  [ -n "$remoto" ] && prompt="$prompt If the repo has no git remote, add it first: git remote add origin $remoto"
  echo "SESSION $id"
  echo "VIEW https://claude.ai/code/$id"
  (cd "$dir" && claude -p "$prompt" --cloud "$id" 2>&1 & p=$!; sleep 60; kill $p 2>/dev/null || true) | grep -E 'Sent|Error|error' || true
else
  tmux new-session -d -x 200 -y 50 -s "$ses" -c "$dir" \
    "claude --allowedTools 'Bash(git:*)' Read Write Edit Glob Grep; sleep 600"
  confiar
  for _ in $(seq 1 30); do pane | grep -qE '\? for shortcuts|❯' && break; sleep 2; done
  tmux send-keys -t "$ses" -l "/advisor $modelo"; tmux send-keys -t "$ses" Enter
  sleep 6
  tmux send-keys -t "$ses" Escape 2>/dev/null || true; sleep 1
  tmux send-keys -t "$ses" -l "$prompt"; sleep 1; tmux send-keys -t "$ses" Enter
  echo "TMUX $ses  (watch: tmux attach -t $ses)"
fi
