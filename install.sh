#!/bin/sh
# Installs the docs skills into a repo. Usage: install.sh [--force] /path/to/repo
set -eu

force=0
if [ "${1:-}" = "--force" ]; then force=1; shift; fi
repo=${1:?usage: install.sh [--force] /path/to/repo}
here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$repo" && pwd)
git -C "$repo" rev-parse --show-toplevel >/dev/null

mkdir -p "$repo/.agents/skills" "$repo/.claude/skills"
for path in "$here"/bundle/*/; do
  skill=$(basename "$path")
  target="$repo/.agents/skills/$skill"
  if [ -e "$target" ] && [ "$force" -eq 0 ]; then
    if ! diff -rq "$path" "$target" >/dev/null; then
      echo "$target exists and differs. Rerun with --force to replace it." >&2
      exit 1
    fi
  fi
  rm -rf "$target"
  cp -R "$path" "$target"
  # Claude Code reads .claude/skills. Codex, Muse and Grok read .agents/skills.
  link="$repo/.claude/skills/$skill"
  [ -L "$link" ] || [ ! -e "$link" ] || { echo "$link exists and isn't a link." >&2; exit 1; }
  rm -f "$link"
  ln -s "../../.agents/skills/$skill" "$link"
done
chmod +x "$repo/.agents/skills/launch-docs/assets/serve.sh" "$repo/.agents/skills/review-docs/scripts/check.py"

echo "Installed launch-docs, write-docs, review-docs and plain-writing in $repo"
if git -C "$repo" check-ignore -q .agents/skills/write-docs/SKILL.md .claude/skills/write-docs 2>/dev/null; then
  echo "Note: .gitignore hides .agents/skills or .claude/skills, so future agents won't get them from a clone." >&2
fi
echo
echo "Next, open an agent in that repo and send:"
echo "  $(sed -n 's/^> //p' "$here/PROMPT.md" | head -1)"
