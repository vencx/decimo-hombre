---
name: tenth-man
description: "Adversarial review of a plan, spec, design or document by an ISOLATED auditor (a separate Claude session with /advisor, none of your context), in the cloud or locally, on a PII-scanned clean copy, with an auditable delivery (a DONE:/BLOCKED: commit). Use it when asked for an \"adversarial review\", \"tenth man\", \"red-team this plan\", \"send it to cloud review\", \"have the advisor/Fable audit it\", \"stress-test the plan\", \"find holes before we build\", or right after planning and before building something expensive to undo. Not for reviewing a code diff (use code-review) nor for a quick second opinion inside the same session."
---

# Tenth man

The tenth-man rule: when nine people agree, the tenth is obliged to look for why they are wrong. Here the tenth is a separate Claude session with a strong advisor that **does not share your context**: it only sees the document and a brief. That isolation is the point; a review in your own session inherits the same blind spots that wrote the plan.

## When to invoke it
Worth it when being wrong is costly to undo (production, money, customer data, migrations, agents that talk to customers on their own) and the document is already written. One per document: requirements and technical plan are two separate reviews.
| Workflow | Moment |
|---|---|
| Compound Engineering | After `/ce-brainstorm` if requirements are large or contentious; **always after `/ce-plan`**, after whatever quick review you already do (a second model, a teammate, `/ce-doc-review`), and before `/ce-work`. Repeat if the plan is heavily rewritten. |
| Superpowers | After `writing-plans` and before `executing-plans` / `subagent-driven-development`; optionally on the design coming out of `brainstorming`. |
| No framework | On the PRD/spec, RFC/ADR, migration plan, an agent's system prompt or a runbook, before work starts. |
Do not use it for: small or reversible changes, bugs (diagnose first), code already written (`code-review`), or as a replacement for a quick review: the isolated auditor finds what shared context hides, not the obvious.

## Modes
| Mode | Where it runs | When |
|---|---|---|
| `cloud` (default) | Claude Code cloud session, private GitHub repo | Long reviews; keeps your machine and session free |
| `local` | A separate `claude` session in tmux on your machine, local git repo | No GitHub, or the copy must not leave the machine |

Same guarantees in both: clean copy, PII scan = 0, `/advisor <model>` set before the prompt, same brief, same deliverable.

## Local annex
If `~/.claude/docs/tenth-man-annex.md` exists, read it before step 1: it holds the user's own rules and paths (where the review goes, who gets notified, extra PII regexes). The annex overrides the defaults here.

## One-time requirement (cloud mode)
Let the cloud push to new repos: run `/web-setup` once, or install the Claude GitHub App with access to all your repos. Without it the review still happens but stays inside the session.

## Procedure
1. **Pick what goes in the copy.** Only the document under review (plus 1–2 annexes the document cites as authority). No dumps, logs or conversations: the auditor does not need them and that is where personal data lives.
2. **Write `REVIEW-BRIEF.md`** from the matching template in `references/brief-templates.md` (requirements · technical · agent design · other). The brief states what is already decided and not up for debate, what to review as a numbered focus list, and the output format. Write it for a cold reader: no "as you know", real section names from the document.
3. **Prepare the copy** (it refuses unless the scan is 0; clean and retry, never skip):
   `bash scripts/prepare_copy.sh <slug> <cloud|local> <doc> REVIEW-BRIEF.md`
   Prints `DIR …` and, in cloud mode, `REPO owner/dh-<slug>`.
4. **Launch** (the advisor goes as a slash command on its own; the prompt goes separately):
   `bash scripts/launch.sh <cloud|local> <DIR> "Read and follow REVIEW-BRIEF.md in this repo in full. Deliver: review.md on the new branch review/<slug>, a commit starting with DONE: (or BLOCKED: and the reason)<, and push if cloud>. Do not edit the reviewed document or open a PR." [model=fable]`
   Cloud: prints `SESSION` and `VIEW <url>`; give the URL to the user. Local: prints the tmux session.
5. **Wait for the artifact, not for silence:**
   `bash scripts/wait_delivery.sh <cloud|local> <owner/dh-slug | DIR> review/<slug> 90` in the background. Only a `DONE:`/`BLOCKED:` commit counts as delivery.
6. **Bring the review back** next to the original document (e.g. `docs/plans/<date>-review-<slug>.md`) and summarize for the user: verdict, one line per critical finding, and how much work it asks for before building.

## When something fails
- Cloud: no session or an error: repeat step 4 once; if it fails again, offer `local` mode on the same folder (it is already a git repo).
- The cloud session does not start after step 4: resend the prompt with `claude -p "<prompt>" --cloud <session_id>` from the folder. Do not use cross-session messages (SendMessage): they arrive as text and do not start the work.
- The cloud push fails with a 403 ("repo not authorized"): with no Claude GitHub App on the new repo, `--cloud` uploads a bundle, and a bundle can push back only if your GitHub connection has access to that repo. One-time fix: `/web-setup` (shares your `gh` token) or install the Claude GitHub App on "All repositories". Then `claude -p "push the branch" --cloud <id>`. Meanwhile the review can be read in the session.
- 90 min without delivery: open the URL or `tmux attach -t dh-…` and look; tell the user what you see, not what you assume.

## What it does not do
- It never ships customer data: if the document only makes sense with real data, replace it with synthetic data before step 3.
- It does not decide for the user: the review proposes; whoever owns the plan decides what to accept.
- It is not for code already written (that is `code-review`) nor for a quick opinion (that fits in the session).
