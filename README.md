# Docsite harness

A skill bundle and a prompt that give any repo its own docs site: pictures first, plain writing, facts checked against the code.

```text
install.sh REPO  →  .agents/skills/ and .claude/skills/  →  one prompt  →  docs/site/  →  docs/serve.sh
```

## Use it

```bash
git clone https://github.com/a-barwick/docsite-harness.git
docsite-harness/install.sh /path/to/repo
```

Then open any agent in that repo and send:

> Use the launch-docs skill to build this repo's docs site, then run it with docs/serve.sh and give me the URL.

`PROMPT.md` has the prompts for adding a page and reviewing the site. After a launch, run `review-docs` on every page in a fresh thread. In our last test, sites that passed `check.py` still had 49 wrong facts across 37 pages, and only a review against the code found them. The site needs no build step or framework. It needs Python 3 to serve, and Chrome or Chromium to run the visual checks.

## What's in the bundle

| Skill | Job |
| --- | --- |
| `launch-docs` | Reads the repo, plans the pages, copies the kit, writes the site and checks it. Holds the kit and the component gallery. |
| `write-docs` | Adds or changes one page, and chooses where it goes. |
| `review-docs` | Reviews a page against the code and the rules. Holds `check.py`. |
| `plain-writing` | The sentence rules, with rejected lines from past reviews. |

The page rules are copied to `docs/site/AGENTS.md` in each repo with that project's example and colors filled in, so each repo has one copy. `site.js` and `site.css` are the same in every repo, and `site-config.js` holds the site's name and navigation.

## What `check.py` catches

| Check | Examples |
| --- | --- |
| Facts | A source path that doesn't exist, a code name that isn't in the repo, a Data panel citing a missing file |
| Layout | Sideways scrolling at 1440 and 375 px, script errors, broken images, broken links |
| Diagrams | Lines crossing boxes or text, text leaving its box, text too small on a phone, a part drawn twice on the overview |
| Writing | Slogans, praise words, long paragraphs, text describing the site itself |
| Privacy | Email addresses, API keys, home directory paths, private network addresses, deploy preview hostnames |

## Permissions

Viewing a page means starting Chrome. Muse's sandbox blocks that, and in the trials Muse shipped a diagram with lines crossing its labels until the sandbox was turned off. In Codex's sandbox the first render fails, and later renders in the same run succeeded in the trials.

| Agent | What the trials ran |
| --- | --- |
| Claude Code | `claude -p --permission-mode bypassPermissions` |
| Codex | `codex exec --sandbox workspace-write` |
| Muse | `muse exec --trust-workspace --disable-approval --disable-sandbox` |
| Grok | `grok -p --always-approve` |

## License

MIT. See `LICENSE`.

## Testing it on a repo

```bash
trials/run.sh ROUND /path/to/repo opus
trials/score.py ROUND
trials/clean.sh /path/to/repo
```

`run.sh` makes a fresh worktree under `../docsite-trials/ROUND`, next to this repo, and sends a one-line prompt. `score.py` prints what a script can measure, and saves the checks and screenshots to `trials/results/`. A person still needs to read the pages and check facts. `clean.sh` removes the worktrees and their branches.
