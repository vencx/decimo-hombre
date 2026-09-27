# Tenth man · Décimo hombre

*[Leer en español](README.es.md)*

> When nine people agree, the tenth is obliged to look for why they are wrong.

A Claude Code plugin for **adversarial review of plans, specs and designs** by an **isolated auditor**: a separate Claude session with `/advisor` (Fable by default) that sees only the document and a brief, never your conversation. Runs **in the cloud** (Claude Code on the web, private GitHub repo) or **locally** (separate `claude` session in tmux).

Two skills, same engine: **`tenth-man`** (English) and **`decimo-hombre`** (Spanish).

## Why another review skill
Most "devil's advocate" skills critique inside the same session, so the critic inherits the blind spots that wrote the plan. This one:
- **Isolates the auditor** — separate session, no shared context.
- **Scans for PII and secrets** before anything leaves your machine (phones, emails, WhatsApp IDs, key-like strings, plus your own regexes); it refuses to continue unless the scan is 0.
- **Delivers an auditable artifact** — `review.md` on its own branch, closed by a `DONE:`/`BLOCKED:` commit. Silence never counts as done.
- **Works around real gotchas** we measured: the slash command must go alone, a cross-session message does not start a cloud session (`claude -p "<prompt>" --cloud <id>` does), new folders need the trust dialog accepted, copies inside `~/.claude` are refused for upload.

## Install
```
/plugin marketplace add vencx/decimo-hombre
/plugin install decimo-hombre@decimo-hombre
```
Requirements: Claude Code with `/advisor`, `tmux`, `git`, `python3`; for cloud mode also `gh` (logged in) and Claude Code on the web.

## Use
Ask Claude: *"tenth-man this plan: docs/plans/checkout-v2.md, cloud mode"*. It writes the brief from a template (requirements · technical · agent design), prepares the clean copy, launches the auditor, waits for the commit and brings `review.md` back next to your plan.

Private per-user settings (where reviews land, who gets notified, extra PII regexes) go in `~/.claude/docs/tenth-man-annex.md`, which is never part of the plugin.

## License
MIT
