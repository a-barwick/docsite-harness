---
name: launch-docs
description: Build this repo's first docs site in docs/site from its code, with visual-first pages and plain writing. Proposes the site's outline for approval before writing pages. Use when asked to launch, create, bootstrap or set up a docs site for a repo. If docs/site already exists, use write-docs instead.
---

# Launch docs

Build a static docs site from the code. A reader should get each idea from a picture, understand it from a few short lines, and open details only if they want them. Paths are from the repo root. `SKILL_DIR` means `.agents/skills/launch-docs`.

Stop and report if `docs/site/` already exists. Change only `docs/`, the root `AGENTS.md`, and one link in the README. Don't change code, and don't move or delete existing docs.

## 1. Read the rules

Read these in full before anything else:

- `SKILL_DIR/assets/site/AGENTS.md`, the page rules
- `.agents/skills/plain-writing/SKILL.md`, the sentence rules
- `SKILL_DIR/references/patterns.html`, every component with its markup and how to choose one

The app in `patterns.html` is made up. Copy its markup and none of its names or content.

## 2. Read the repo

Facts come from the code on this branch. Older docs tell you where to look and what people intended, and the code decides what's true. Notes or memory from other sessions aren't sources.

- Read the README, any `AGENTS.md` or `CLAUDE.md`, the manifests and the file tree, then the entry points, and follow the main path through the code by hand.
- Open each top-level directory and package, and note what it holds and what runs from it. The outline needs every area, beyond the main path.
- Read the existing docs and the last 30 commit subjects. Note where they disagree with the code.
- Tests show intended behavior. Don't document test files.
- Don't open `.env` or credential files, and don't run anything that deploys, costs money or moves hardware.
- Keep a list of the files behind each fact, for the Sources sections.

## 3. Propose the outline and get it approved

The outline is the nav groups, the pages in each, and the question each page answers. Every later page hangs on it, so the repo owner approves it before you write any page.

### Decide the basics

| Decide | How |
| --- | --- |
| **Parts** | The 3 to 8 running pieces of the system, in the code's own names. Pick colors `c1`, `c2`, `c3` for the three a reader must tell apart. Storage and infrastructure stay gray. |
| **Default example** | One concrete input to follow on every page, such as one specific request, command or file. Invent the values and keep the path true to the code. |
| **Glossary** | The project's own nouns with one meaning each. Use them on every page and add no synonyms. |

### List the topics

Go through the code and list every topic a reader might look up on its own. Look for each of these:

- Each running piece: a service, process, worker, app or client
- Each loop, pipeline or lifecycle, and each thing that moves through states
- Each record or store a reader would query or change
- Each interface other code or people use: an API, CLI, config file, event, plugin or extension point
- Each concern with its own code: permissions, limits, errors and retries, scheduling, logging and metrics, deployment
- Each top-level directory or package. Every one lands on at least one page, or the outline says why it's left out.

### Group them into pages

- Give each topic a page if a reader would look it up on its own and it has a visual. Merge a topic that would fill less than about 200 words into the page next to it. Split a topic that won't fit in 800 words, or that answers two questions.
- Group the pages by area of the system, in the code's names, such as one group per service or layer. Aim for 3 to 10 pages per group. Put `Start` first, with Overview and the example page, then the area groups, then `Planned` if needed, then `Reference`.
- Use the page types in the table below. An area group usually holds several subsystem pages.

Use these ranges to check the outline, not to cap it. Below the range, look for listed topics with no page. Above it, look for pages that answer the same question.

| Tracked source files | Pages, including reference |
| --- | --- |
| Under 50 | 6 to 10 |
| 50 to 500 | 10 to 25 |
| Over 500 | 25 to 50 |

| Page | File | Answers | Visual |
| --- | --- | --- | --- |
| **Overview** | `index` | What is this, and what are its parts? | One connected picture with every part in color, each part shown once, and an arrow for what passes between them. The sequence of steps belongs on the example page. If the app has a screen and the repo has a screenshot, copy it to `docs/site/img/` and show it first. Then the example as a short list. If the repo records what has run for real, add a table of that |
| **Following the example** | your choice, such as `request` | What happens to one input, step by step? | `.trace`: numbered steps with a step map that follows the scroll. A Data button on each step if data crosses a boundary |
| **System** | `system` | What does each part own, and how do they connect? | Parts diagram, then one table row per part |
| **Subsystem pages**, several per area group | your choice | How does this part work? | Flow, state diagram or table, whichever shows it |
| **Running it**, if it's deployed or has hardware | `deploy` | Where does it run, and what happens when it fails? | Flow or table. This describes the system, and setup steps stay in the README |
| **Decisions** | `decisions` | What was chosen, why, and what was rejected? | Table: decision, why, rejected, date. Take these only from commits and docs that state them, and skip the page if there are none |
| **Open questions** | `open-questions` | What couldn't be confirmed? | List. Include everything you found and couldn't verify |
| **Code map** | `code` | Where do I look to change something? | `.map` table: "If you're looking for", "Look in" |
| **Words we use** | `words` | What does this word mean here? | Table |
| **Sources** | `sources` | What else exists, and where does it disagree with the code? | Table of existing docs with their state, then the mismatches |

Code on this branch counts as built, even if the branch is ahead of the default branch. Work that exists only in docs or issues goes in a `nav` group named `Planned`, or is marked `designed` on the page it belongs to. Never describe it as running.

### Show the outline and wait

Send the outline in chat, in this form:

```markdown
**Parts:** Gateway (c1), Worker (c2), Scheduler (c3); Postgres and the queue in gray
**Example:** `POST /jobs` with a 40 MB CSV export
**Size:** 5 groups, 27 pages, for 640 tracked source files (range 25 to 50)

**Start**
- Overview (`index`): What is this, and what are its parts? · parts diagram · `cmd/`, `README.md`
- Following a job (`job`): What happens to one export, step by step? · trace · `gateway/jobs.go`, `worker/run.go`

**Worker**
- Running a job (`worker`): ...

**Left out:** `tools/bench/`, because it's a local benchmark with no reader outside the team.
```

Each page line has its title, its file name, the question it answers, its visual and the main paths behind it. Then ask the owner to approve the outline or change it, and stop. Don't set up the kit or write a page until they answer.

Apply the owner's changes. If they move groups, or add or remove more than a few pages, send the new outline and wait again. The approved outline sets `nav` in `site-config.js`.

If the request says not to wait for approval, or nobody can answer, as in a non-interactive run, go on with your outline and put it in the report.

## 4. Set up the kit

```bash
mkdir -p docs
cp -R .agents/skills/launch-docs/assets/site docs/site
cp .agents/skills/launch-docs/assets/serve.sh docs/serve.sh
chmod +x docs/serve.sh
```

- Fill `site-config.js` with the project name and the approved `nav`.
- Fill every `{{...}}` in `docs/site/AGENTS.md`, including the example, the colors and what decides what's planned.
- Don't edit `site.js`. Add CSS to the end of `site.css` only if a page needs something the patterns can't do.

## 5. Write the pages

Write in this order, so each page can link to what exists and use the same words: Words we use, System, Following the example, subsystem pages one area group at a time, Running it, Decisions, Code map, Open questions, Sources, and Overview last.

If you run out of time or context before every approved page is written, finish the page you're on, remove the unwritten pages from `nav`, and list them in the report so they can be added with the write-docs skill.

For each page:

1. Read the code for the facts on that page. Don't guess a name, limit, endpoint or default. If you can't confirm one, leave it out and add it to Open questions.
2. Draw the visual first. Each box names a system part and each arrow says what passes.
3. Write the `h1`, one sentence of lede, the visual, then two to four short sections that each answer a different question. Aim for 300 to 600 words.
4. For each number, name or setting, ask what a reader would do with it, and cut it if there's no answer.
5. End with `details.sources`, listing repo paths in `<code>`.

Run the check script as you go, so a mistake doesn't repeat across pages:

```bash
python3 .agents/skills/review-docs/scripts/check.py docs/site/page.html --render
```

## 6. Point the repo at the site

Add this section to the root `AGENTS.md`, creating the file if it's missing, and add one line linking to `docs/site/` in the README:

```markdown
## Documentation

Documentation lives in `docs/site/`. Check it first when you need to understand the system, and put new or updated documentation there. Read `docs/site/AGENTS.md` before changing a page, and run the site with `docs/serve.sh`. Use the `write-docs`, `review-docs` and `plain-writing` skills in `.agents/skills/`.
```

## 7. Check the whole site

```bash
python3 .agents/skills/review-docs/scripts/check.py --all --render
```

- Fix every `FAIL`. Fix each `WARN` unless you can say why it's fine.
- Open the screenshots at both widths if your tools can read images, starting with Overview and the example page. Fix anything clipped, overlapping, crossing or stretched empty. If a sandbox stops Chrome, ask to run the command outside the sandbox. If you still can't render, say so, and don't claim you looked.
- Follow `.agents/skills/review-docs/SKILL.md` for at least the Overview, System and example pages. Check five claims on each against the code, and the direction of every arrow in the Overview and System diagrams.
- Start `docs/serve.sh` in the background, fetch the index page once to confirm it responds, and stop the server unless you were asked to leave it running.

## 8. Report

State the pages built, any approved pages not written, the outline if nobody approved it, the command that runs the site, what you couldn't verify, and whether you viewed the rendered pages at both widths. Don't link to a temporary local server unless you left it running. Commit only if you were asked to.
