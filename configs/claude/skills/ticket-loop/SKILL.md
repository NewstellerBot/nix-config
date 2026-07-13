---
name: ticket-loop
description: Implement a Linear ticket end-to-end, open a PR, then loop an independent fresh-session reviewer against it — fixing agreed findings each round — until approval or the round cap is hit. Use when asked to take a ticket all the way through implementation and review.
argument-hint: <ticket-id> [max-rounds]
disable-model-invocation: true
---

# Ticket Loop

Arguments: `$ARGUMENTS` — the first token is the Linear ticket ID (e.g. `POI-2070`); the optional second token is the maximum number of review rounds (default **5**).

This skill depends on two project skills: `/implement-ticket` and `/review-pr`. If either is missing in the current project, stop immediately and say so instead of improvising.

## Recommended harness: pair with /goal

This skill defines the procedure; the native `/goal` command is the continuation engine. Invoke both:

```
/ticket-loop POI-1234
/goal the ticket-loop is finished: reviewer verdict is approve (or approve-with-nits with no agreed should-fixes), the review-round cap is exhausted, or a wedge/blocker was reported — hard backstop: stop after 60 turns
```

`/goal`'s independent evaluator (a separate small model) re-checks the condition after every turn and sends the session back to work if unmet — so an accidental early stop mid-loop resumes instead of stalling. The evaluator only reads the conversation, never files or logs: that is why every round must state the round number and reviewer verdict in the reply text (see Phase 2).

## Phase 1 — Implement

1. Run `/implement-ticket <ticket-id>` and complete it fully: discovery, implementation, tests, and the verification checklist.
2. Work on the branch name Linear provides for the ticket (`gitBranchName` from the issue). Create it from `main` if it doesn't exist.
3. Commit, push, and open the PR with `gh pr create`.
   - Title: `<type>: <summary> [<ticket-id>]`, matching recent commit history style.
   - Body in my voice: prose, short sentences each on their own line, casual. No evidence/test-plan section for non-visual changes.
4. Record the PR number — the loop needs it.

## Phase 2 — Review loop

Track the round counter explicitly: state "round X of N" and the reviewer's verdict verbatim in your reply text every round — the /goal evaluator judges only what appears in the conversation. For each round, up to the cap:

1. **Spawn an independent reviewer.** Never review your own work in-session; the reviewer must be a fresh headless instance with no shared context:
   - Write the reviewer prompt to a temp file (use the session scratchpad directory) for clean quoting. The prompt is: `/review-pr <pr-number>`, plus these instructions — "REVIEW ONLY: do not modify, create, or delete files; do not commit or push. End with a verdict line — exactly one of: approve, approve-with-nits, request-changes — followed by prioritized findings, each with severity (blocker / should-fix / nit) and file:line."
   - Run it in the background and wait for completion:
     `claude --dangerously-skip-permissions -p "$(cat <promptfile>)" --disallowedTools "Edit Write NotebookEdit" > <logfile> 2>&1`
   - Read the log for the verdict and findings.
2. **Reconcile before acting.** Not every finding gets fixed:
   - The Linear ticket is the source of truth. If the reviewer flags behavior the ticket explicitly asks for as a bug/regression, the ticket wins — record the rejection with reasoning, don't "fix" it.
   - Reject findings that conflict with repo coding standards or clear local convention.
   - Nits are optional: apply the cheap ones alongside real fixes, but never spend a round on nits alone.
3. **Exit check.** If the verdict is `approve`, or `approve-with-nits` with no blocker/should-fix findings you agree with → the loop is done.
4. **Fix.** Address the agreed findings. Run the relevant tests, typecheck, and lint before every push — never push a broken round. Commit and push to the same branch so the PR updates.
5. **Leave a trail.** Post one PR comment per round: what the reviewer flagged, what was fixed, what was rejected and why (one line each).

## Exit

- **On approval:** report the final verdict, rounds used, and anything deliberately not addressed (with the reasoning).
- **Cap reached without approval:** stop — do not keep iterating. Summarize the unresolved findings, your position on each, and hand back to me for a decision.
- **Wedged?** If the same finding survives two consecutive rounds of attempted fixes, or a fix breaks tests you can't repair within the round, stop early and report rather than burning the remaining rounds.

## Guardrails

- Never merge the PR; never close the ticket. My job.
- Hard cap on reviewer rounds — the argument or the default 5, no exceptions.
- Every reviewer invocation must be a fresh headless session; never reuse a reviewer session across rounds.
- The headless reviewer runs with permissions skipped, so the `--disallowedTools "Edit Write NotebookEdit"` guard and the REVIEW ONLY instruction are both mandatory, every round.
