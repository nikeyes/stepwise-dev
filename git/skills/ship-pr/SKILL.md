---
name: ship-pr
description: Take the current work to a pull request that is ready to merge, unattended. Commits, pushes, opens the PR, waits for its checks, fixes the failures and answers the review comments, in up to 3 fix rounds. Never merges.
model: inherit
disable-model-invocation: false
allowed-tools: Bash(git status:*) Bash(git branch:*) Bash(git switch:*) Bash(git log:*) Bash(git diff:*) Bash(git add:*) Bash(git commit:*) Bash(git push:*) Bash(gh repo view:*) Bash(gh pr view:*) Bash(gh pr create:*) Bash(gh pr edit:*) Bash(gh pr checks:*) Bash(gh run view:*) Bash(gh api:*) Read Glob Grep Edit Write Skill
argument-hint: "[plan file (optional)]"
---

# Ship PR

Take the work in this repository to a pull request that is ready to merge: commit it, push it, open the PR, wait for its checks, fix what fails and answer the review comments.

Nobody will answer questions while you run. Do not ask for confirmation at any step: the report you write at the end is the user's control point. Never merge the PR and never force-push.

## Your Role: Orchestrator

You coordinate; the delegated skills do the work and own their rules. Invoke each one with the `Skill` tool:

- `/stepwise-git:commit` creates the commits
- `/stepwise-git:open-pr` pushes, opens the PR and waits for the checks
- `/stepwise-git:review-pr-comments` decides on the comments, implements, pushes and replies
- `/stepwise-core:tdd` fixes behavior test-first, when it is available

If a delegated skill fails, stop and report what happened. Do not work around it by doing its job yourself.

## Getting Started

- **Plan**: if a plan file is given, pass it to `tdd` and to `review-pr-comments` as context. Do not look for one yourself.
- **Nothing to ship**: if the working tree is clean, the branch has no commits ahead of the default branch and it has no open PR, say so and stop.
- **Branch first**: if you are on the default branch and there are changes to commit, create `type/short-description` with `git switch -c` before committing.
- **Commit**: if there are uncommitted changes, invoke `/stepwise-git:commit`.

Then run the round cycle. Keep a count of fix rounds, starting at 0.

## Round Cycle

### Step 1 — Push and wait

Invoke `/stepwise-git:open-pr`. It pushes whatever is not on the remote yet, so the fixes of the previous round are verified here.

Stop with **timeout** if checks are still pending when it returns.

Stop with **round limit** if the fix-round count is 3. The comments that arrived after the last push have not been processed: say so in the report.

### Step 2 — Fix the failed checks

Skip this step if no check failed.

Stop with **no progress** if a check fails with the same error as in the previous round.

Read the log of each failed check and decide what kind of failure it is:

| Failure | What to do |
|---|---|
| A reviewer that only reports findings it posted as PR comments | Nothing here: Step 3 handles them |
| Behavior or a failing test | Fix it test-first, without weakening or skipping tests. Invoke `/stepwise-core:tdd` with the log if it is available; otherwise write the failing test yourself first |
| Lint, format, version, generated file or configuration | Edit directly |
| PR title, body or labels | `gh pr edit` |
| Nothing in the repository can fix it (infrastructure, secrets, permissions, an external service) | Stop with **blocked** |

If any file changed, invoke `/stepwise-git:commit`. Do not push: the next step or the next round does it.

### Step 3 — Answer the review comments

Invoke `/stepwise-git:review-pr-comments` with the PR number and the plan file, if any. It pushes its own changes together with the commits from Step 2.

### Step 4 — Decide whether to go again

- Something changed in this round (a commit or a PR edit): add 1 to the fix-round count and go back to Step 1.
- Nothing changed and every check passed: stop with **clean**.
- Nothing changed and a check is still failing: stop with **no progress**.

## Final Report

```
PR: {url}
Result: {clean | round limit | no progress | timeout | blocked} — {one line saying why}
Fix rounds used: {n} of 3

Checks:
- {name}: {passed | failed | pending}

Check failures fixed:
- {check}: {what was wrong and what you changed}

Comments:
- Accepted: {claim} — {commit}
- Rejected: {claim} — {reason}
- Repeated, not answered again: {claim}

Left for you:
- {failing checks with the end of their log, comments not processed, files left out of the commits}

The PR has not been merged.
```

Omit a section that has nothing in it.
