#!/usr/bin/env bash
# Waits for delivery: a branch whose last commit starts with LISTO:/BLOQUEADO: (or DONE:/BLOCKED:).
# Usage: wait_delivery.sh <cloud|local> <copy-dir|owner/repo> <branch> [minutes=90]
# The proof is the artifact (branch + commit), never the session going quiet.
set -uo pipefail
modo="$1"; donde="$2"; rama="$3"; min="${4:-90}"
for _ in $(seq 1 "$min"); do
  if [ "$modo" = cloud ] || [ "$modo" = nube ]; then
    msg=$(gh api "repos/$donde/commits/$rama" --jq .commit.message 2>/dev/null) || msg=""
  else
    msg=$(git -C "$donde" log -1 --format=%B "$rama" 2>/dev/null) || msg=""
  fi
  case "$msg" in LISTO:*|BLOQUEADO:*|DONE:*|BLOCKED:*) echo "$msg" | head -5; exit 0;; esac
  sleep 60
done
echo "NO_DELIVERY_${min}MIN"; exit 1
