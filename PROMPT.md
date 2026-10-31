# Prompts

Launch a repo's site, after `install.sh`:

> Use the launch-docs skill to build this repo's docs site, then run it with docs/serve.sh and give me the URL.

Or install and launch in one prompt, from an agent running in the repo:

> Run ~/Documents/dev/docsite-harness/install.sh . then use the launch-docs skill to build this repo's docs site, run it with docs/serve.sh and give me the URL.

After launch, name the skill and the topic. Choosing the page is part of the skill.

> Use the write-docs skill: document how the worker retries a failed job.

Review in a fresh thread, with another model if the page matters:

> Use the review-docs skill to review the site. Report findings only.
