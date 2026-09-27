# REVIEW-BRIEF.md templates

All share the header and the output block; only "Task" changes. Fill in what is between ‹›. Drop the focus items that do not apply and add the document's own, always citing real sections.

## Common header
```markdown
# Brief: adversarial review of ‹document name›

‹Private/local› repo: a clean copy with no history, only `‹file›`. You have no database, servers, messaging or keys, and you do not need them. Files, builds or systems the document cites live elsewhere: do not look for them; if a finding depends on them, mark it "inferred".

## Context
‹2–4 sentences: what the system is, who it is for, what this document aims at›. ‹What the owner has ALREADY decided and is not up for debate (e.g. decisions D‹n›, approved requirements R‹n›)›: do not argue it; check whether the document honors it.
```

## Task — requirements plan
```markdown
## Task
Adversarial review with `/advisor` counsel. Look for, citing section or R/AE:
1. Requirements that contradict each other.
2. Cases the plan does not cover: ‹the domain's own edges: someone never answers, answers twice, comes back days later, several requests out of order…›.
3. Risks that the system lies, makes things up or acts without permission despite the requirements.
4. Acceptance criteria that cannot be verified or do not cover their requirement.
5. What is missing to go from plan to build.
```

## Task — technical plan
```markdown
## Task
Adversarial review with `/advisor` counsel, focused on ‹Planning Contract, units U0–Un, Verification Contract›. Look for, citing section, U or R:
1. Requirements with no unit that builds them, or units that trace to no requirement.
2. Order and dependencies: what breaks if a unit ships without the next one; entry blockers the rest takes as solved.
3. Concurrency and time: clocks, duplicates, late or out-of-order replies, retries, overlapping crons, idempotency.
4. Risks that the system lies, makes things up or speaks when it should stay quiet that the design does not close with a deterministic guard.
5. Verification: tests that cannot run or do not prove what they claim, tests that would touch real users or data, gaps between the Definition of Done and the acceptance criteria.
6. What a developer would still need to ask before starting tomorrow.
```

## Task — agent design (bot, operational session, multi-agent)
```markdown
## Task
Adversarial review with `/advisor` counsel. Look for, citing section:
1. Where the agent can claim something it did not verify, or report "done" without evidence from the authoritative source.
2. Instructions that clash with each other or with deterministic guards; which one wins when they do.
3. Channels between agents: messages that get lost, duplicated or reach the wrong party; what happens if an agent restarts midway.
4. Cost and loops: what can trigger unbounded calls; what breaks the loop.
5. How anyone would know the agent is failing silently, and who finds out.
```

## Common output (always last)
```markdown
## Output
A single new file `review.md` at the root: a 5-line verdict; then a table finding · section/U/R · severity (critical/high/medium) · basis (read/inferred) · one-line proposal. Do not edit the reviewed document.

Finish with a commit on the new branch `review/‹slug›` whose message starts with `DONE:` (or `BLOCKED:` and the reason)‹; push›. Do not open a PR.
```

Optional (idea from robertoecf/adversarial-review): if the requester already has their own list of doubts, pass it as `own-doubts.md` and ask for a "matches" column (auditor · us · both) to separate what only the auditor saw.
