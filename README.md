# Tenth man · Décimo hombre

*[Leer en español](README.es.md)*

> When nine people agree, the tenth is obliged to look for why they are wrong.

A Claude Code plugin for **adversarial review of plans, specs and designs** by an **isolated auditor**: a separate Claude session with `/advisor` (Fable by default) that sees only the document and a brief, never your conversation. Runs **in the cloud** (Claude Code on the web, private GitHub repo) or **locally** (separate `claude` session in tmux).

Two skills, same engine: **`tenth-man`** (English) and **`decimo-hombre`** (Spanish).

## Why this one
You wrote the plan, you reread the plan, and you like the plan. That is exactly the problem: a reviewer who has been through the same conversation you have tends to see what you see, and miss what you miss.

Tenth man hands your document to a fresh Claude session that has never met you. It gets the document and a short brief, nothing else, and its only job is to find where you are wrong.

A few things we cared about while building it:
- **Nothing personal leaves by accident.** Before the copy goes anywhere it is checked for phone numbers, emails, chat IDs and anything that looks like a key. If something shows up, it stops and tells you where.
- **"Done" means there is something to read.** The review lands as a file on its own branch, with a commit that says DONE or BLOCKED. A quiet session is not a finished one.
- **The snags are already handled.** Getting an isolated session to actually start working, in the cloud or locally, has a few non-obvious traps. We hit them so you do not have to.

## Install
```
/plugin marketplace add vencx/decimo-hombre
/plugin install decimo-hombre@decimo-hombre
```
Requirements: Claude Code with `/advisor`, `tmux`, `git`, `python3`; for cloud mode also `gh` (logged in), Claude Code on the web, and the Claude GitHub App installed on all your repos, so the cloud can push the review back.

## Use
Ask Claude: *"tenth-man this plan: docs/plans/checkout-v2.md, cloud mode"*. It writes the brief from a template (requirements · technical · agent design), prepares the clean copy, launches the auditor, waits for the commit and brings `review.md` back next to your plan.

Private per-user settings (where reviews land, who gets notified, extra PII regexes) go in `~/.claude/docs/tenth-man-annex.md`, which is never part of the plugin.

## License
MIT
