---
name: review-pr-comments
description: Review PR comments unattended, deciding on each one, implementing the accepted changes, pushing them and replying in every thread
model: inherit
disable-model-invocation: false
allowed-tools: Bash(gh pr view:*) Bash(gh api:*) Bash(git status:*) Bash(git diff:*) Bash(git log:*) Bash(git add:*) Bash(git commit:*) Bash(git push:*) Read Glob Grep Edit Write Skill
argument-hint: "[PR number] [plan file] (both optional)"
---

# Review PR Comments

Review the pending comments on a PR, decide on each one, implement the accepted changes, push them and reply in every thread. Do not ask for confirmation: the report at the end is how the user learns what you decided.

## Rules

- **PR target**: the PR number if given, otherwise the PR of the current branch. If there is none, say so and stop.
- **Plan**: if a plan file is given, read it. It is the agreed design: a comment that asks to go against it needs a stronger reason to be accepted.
- **Scope**: comments from anyone, bots and people alike. "Yours" below means written by the authenticated GitHub user.
- **Pending**:
  - An inline thread is pending when it is not resolved, not outdated, and its last comment is not yours.
  - A general comment or a review body is pending when it is not yours and was created or edited after your last comment on the PR. If you never commented, all of them are.
  - If nothing is pending, say so and stop.
- **Bias**: defend the existing code. Only accept a change with a concrete technical reason (bug, violated principle, demonstrable readability gain). Reject style preferences without objective justification.
- **Context**: before evaluating, read the full files affected plus related files (tests, types, direct dependencies).
- **Severity**: take it from the comment's prefix when present (`[SECURITY — CRITICAL]`, `[CODE QUALITY — HIGH]`, `[TESTS — LOW]`, `[SUGGESTION]`, etc.). Otherwise infer it: correctness or security bugs are HIGH; performance, tests or missing error paths are MEDIUM; style, docstrings, naming and "for consistency" nits are LOW.
- **Decision**: one of these for every pending comment.
  - `ACCEPT`: you will make the change.
  - `REJECT`: you will not, and you can say why.
  - `REPEATED`: it raises a point you already answered on this PR and adds no new argument. Do not reply again.
- **Implementing**: change only what the accepted comments ask for.
  - A change in behavior goes test-first. If `/stepwise-core:tdd` is available, invoke it with the `Skill` tool: describe the accepted comment as the behavior to implement and pass the plan file if you have one. If it is not available, write the failing test yourself before the fix.
  - A change that does not alter behavior (naming, comments, docs, configuration) is a direct edit.
  - If you cannot make an accepted change, do not pretend: reply saying what blocked it and list it in the report.
- **Publishing the code**: if any file changed, invoke `/stepwise-git:commit` with the `Skill` tool, then `git push`. Never force-push. Do this before replying. If the commit or the push fails, do not post any reply that says a change is done: stop and report.
- **Replying**: one reply per `ACCEPT` and per `REJECT`, posted after the code is pushed.
  - Inline threads get a reply in the thread. General comments and review bodies get a general PR comment that links to the comment it answers.
  - `ACCEPT`: what changed and the commit that changed it.
  - `REJECT`: the technical reason, and what you propose instead if anything. One line is enough for LOW.
  - Always in English, whatever the comment's language. No Claude attribution.
  - Never resolve a thread: that belongs to whoever opened it.
- **Report**: every comment grouped by severity, one block each, and then whether you pushed code (with the commits), so a caller knows a new round of checks has started.

  ```
  N. [ACCEPT|REJECT|REPEATED] {path}:{line or "general"} @{user} — {the claim in one sentence, in your own words}
     Reason: {1-2 lines, technical}
     Commit: {sha}                          # only if ACCEPT
     Alternative: {what you proposed}       # only if REJECT
     Link: {comment.html_url}
  ```
