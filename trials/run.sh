#!/bin/bash
# Runs one blind launch: a fresh worktree, the bundle, and a one-line prompt.
# Usage: trials/run.sh ROUND /path/to/repo AGENT [PROMPT]
# AGENT is opus, astra, wonder or grok. Output goes to trials/logs/ROUND and the worktree to ~/Documents/dev/docsite-trials/ROUND.
set -u
round=$1; repo=$(cd "$2" && pwd); agent=$3
prompt=${4:-"Use the launch-docs skill to build this repo's docs site. Leave your changes uncommitted."}
here=$(cd "$(dirname "$0")/.." && pwd)
name=$(basename "$repo")-$agent
tree=$HOME/Documents/dev/docsite-trials/$round/$name
logs=$here/trials/logs/$round
mkdir -p "$logs" "$(dirname "$tree")"

if [ ! -d "$tree" ]; then
  git -C "$repo" worktree add -q -b "docsite-trial/$round-$agent" "$tree" HEAD || exit 1
  "$here/install.sh" "$tree" >/dev/null || exit 1
fi
cd "$tree" || exit 1

start=$(date +%s)
case $agent in
  opus)   timeout 3000 claude -p "$prompt" --model claude-opus-5-5 --permission-mode bypassPermissions ;;
  astra)  timeout 3000 codex exec -m gpt-6-astra --sandbox workspace-write "$prompt" ;;
  wonder) timeout 3000 muse exec --model muse-wonder-full-1.0 --workspace . --trust-workspace --disable-approval "$prompt" ;;
  grok)   timeout 3000 grok -m grok-4.7 -p "$prompt" --always-approve ;;
  *) echo "unknown agent $agent"; exit 2 ;;
esac > "$logs/$name.log" 2>&1
code=$?
echo "{\"agent\":\"$agent\",\"exit\":$code,\"seconds\":$(( $(date +%s) - start )),\"bundle\":\"$(git -C "$here" rev-parse --short HEAD)\"}" > "$logs/$name.meta.json"
echo "$name exit $code in $(( $(date +%s) - start ))s"
