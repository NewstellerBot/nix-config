---
name: pr-writeup
description: Fill in a PR's description from the repo's PULL_REQUEST_TEMPLATE.md — grounded strictly in what was actually done, in my voice, at most one terse sentence per header. Use after implementing a ticket, before I mark the PR ready.
argument-hint: [pr-number]
disable-model-invocation: true
---

# PR Writeup

Rewrite the description of PR `$ARGUMENTS` (default: the PR for the current branch) so it follows the repo's PR template exactly — in my voice, precise, brief, and true to what was actually done. Nothing else about the PR changes.

## Gather first — the description must be grounded in fact, not intentions

1. **Template.** Read `.github/PULL_REQUEST_TEMPLATE.md` (or `.github/PULL_REQUEST_TEMPLATE/*`). This defines the exact headers and checklist. Keep them verbatim — only fill the content under each. If the repo has no template, stop and say so.
2. **What actually changed.** `gh pr diff <n>` and `git log main..HEAD --oneline`. Describe the diff in front of you, not what the ticket hoped for.
3. **What was actually verified.** Only checks that really ran this session — typecheck, unit tests, lint, e2e, manual. If it didn't run, it doesn't go in. If the only verification was a typecheck, the testing answer is literally `typecheck`.
4. **My voice.** `gh pr list --author @me --state merged --limit 10 --json title,body` and read several bodies. Match my tone, brevity, casing, and how terse I am.

## Write

- **At most one sentence per header.** Terse fragments are preferred where they suffice (testing: `typecheck`, or `typecheck + unit tests`). Not everything needs prose.
- Replace the template's placeholder ticket id (e.g. `# POI-XXXXXX`) with the real ticket id.
- **Screenshots / Evidence:** only if there is a real UI/behavior change and you have real evidence. Otherwise write whatever I write in past PRs for non-visual changes (e.g. `n/a — non-visual`). Never fabricate a screenshot, log, or command output.
- **Checklist:** tick a box only if it is actually true — `provided tests` only if tests were added, `ran my own AI review` only if the review loop actually ran, leave `screenshots` unticked for non-visual changes. Do not tick boxes to look complete.
- **Invent nothing.** Every line must trace to the diff, a command that ran, or the ticket. If you're unsure whether something was done, leave it out.

## Apply

- Write the final body to a file, then `gh pr edit <n> --body-file <file>`.
- Report the PR url. **Description edit only** — do not mark the PR ready for review, merge, close, or comment on it.

## Guardrails

- Keep the template's headers and checklist structure exactly; fill content only.
- One sentence (or terse fragment) per header, maximum.
- Only what was actually done — no aspirational, speculative, or invented content.
- Never mark ready, merge, close, or comment; this skill touches the description and nothing else.
