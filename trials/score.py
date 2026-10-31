#!/usr/bin/env python3
"""Scores trial worktrees with what a script can measure. A person still reads the pages and checks facts.

Usage: trials/score.py ROUND [NAME ...]
Prints one row per trial, and saves checks and screenshots to trials/results/ROUND/NAME.
"""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parents[1]
CHECK = HERE / "bundle/review-docs/scripts/check.py"
TRIALS = Path.home() / "Documents/dev/docsite-trials"
ALLOWED = re.compile(r"^(docs/|\.agents/|\.claude/|AGENTS\.md$|CLAUDE\.md$|README)")
LEAKS = re.compile(r"Shortly|sho\.rt|x7Qp|spring-sale|\bNori\b|outer loop|inner loop|Tucson|\{\{")


def sh(*args, cwd):
    return subprocess.run(args, cwd=cwd, capture_output=True, text=True).stdout


def score(round_name, tree):
    name = tree.name
    site = tree / "docs/site"
    row = {"trial": name, "built": site.is_dir()}
    meta = HERE / f"trials/logs/{round_name}/{name}.meta.json"
    if meta.exists():
        row.update(json.loads(meta.read_text()))
    if not site.is_dir():
        return row
    status = sh("git", "status", "--porcelain", "-uall", cwd=tree)
    paths = [line[3:] for line in status.splitlines()]
    row["outside_scope"] = [p for p in paths if not ALLOWED.match(p)]
    row["committed"] = sh("git", "log", "--oneline", "HEAD", "--not", "--remotes", "--branches=main", "--branches=master", "-5", cwd=tree).strip() != ""
    env = {**os.environ, "DOCS_REPO": str(tree)}
    done = subprocess.run([sys.executable, str(CHECK), "--all", "--render"], capture_output=True, text=True, env=env)
    out = done.stdout + done.stderr
    results = HERE / f"trials/results/{round_name}/{name}"
    results.mkdir(parents=True, exist_ok=True)
    (results / "check.txt").write_text(out)
    shots = Path(tempfile.gettempdir()) / "docs-shots" / name
    if shots.is_dir():
        for shot in shots.glob("*.png"):
            shutil.copy(shot, results / shot.name)
    row["pages"] = len(list(site.glob("*.html")))
    row["fails"] = len(re.findall(r"^\s*(?:site: )?FAIL ", out, re.M))
    row["warns"] = len(re.findall(r"^\s*WARN ", out, re.M))
    words = re.search(r"site: \d+ pages, (\d+) words", out)
    row["words"] = int(words.group(1)) if words else None
    row["over_600"] = len([1 for w in re.findall(r"^[\w-]+\.html: (\d+) words", out, re.M) if int(w) > 600])
    row["rendered"] = "RENDER NOT DONE" not in out
    row["trace_page"] = any('class="trace"' in p.read_text(errors="ignore") for p in site.glob("*.html"))
    row["data_buttons"] = sum(p.read_text(errors="ignore").count("data-flow=") for p in site.glob("*.html")) + len(list(site.glob("*data*.js")))
    kit = HERE / "bundle/launch-docs/assets/site"
    row["site_js_changed"] = (site / "site.js").read_text() != (kit / "site.js").read_text()
    row["css_lines_added"] = len((site / "site.css").read_text().splitlines()) - len((kit / "site.css").read_text().splitlines())
    leaks = {}
    for path in site.iterdir():
        if path.is_file() and path.suffix in (".html", ".js", ".md"):
            hits = LEAKS.findall(path.read_text(errors="ignore"))
            if hits:
                leaks[path.name] = sorted(set(hits))
    row["leaks"] = leaks
    agents = (tree / "AGENTS.md").read_text(errors="ignore") if (tree / "AGENTS.md").exists() else ""
    row["root_pointer"] = "docs/site" in agents
    changed = subprocess.run(["diff", "-rq", str(HERE / "bundle"), str(tree / ".agents/skills")], capture_output=True, text=True).stdout
    row["bundle_edited"] = changed.strip().splitlines()
    (results / "score.json").write_text(json.dumps(row, indent=2))
    return row


def main(argv):
    round_name, names = argv[0], set(argv[1:])
    rows = [score(round_name, tree) for tree in sorted((TRIALS / round_name).iterdir()) if tree.is_dir() and (not names or tree.name in names)]
    for row in rows:
        print(json.dumps(row))


if __name__ == "__main__":
    main(sys.argv[1:])
