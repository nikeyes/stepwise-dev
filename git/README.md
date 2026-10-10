# Stepwise Git Plugin

Git and GitHub workflow: unattended commits, pull requests, CI checks and PR comment review.

## What's Included

### Commands (4)
- `/stepwise-git:ship-pr [plan]` - Take the current work to a PR that is ready to merge: commit, push, open the PR, wait for checks, fix failures and answer review comments, in up to 3 fix rounds. Never merges
- `/stepwise-git:commit` - Create git commits without asking, with no Claude attribution
- `/stepwise-git:open-pr` - Push the branch, open its PR if it has none and wait for every check to finish
- `/stepwise-git:review-pr-comments [PR] [plan]` - Decide on each pending PR comment, implement the accepted changes, push them and reply in every thread

## Installation

```bash
# Add marketplace
/plugin marketplace add nikeyes/stepwise-dev

# Install this plugin
/plugin install stepwise-git@stepwise-dev
```

## Usage

```bash
# Take the current work to a PR that is ready to merge
/stepwise-git:ship-pr [plan-file]
```

This will, without asking anything:
1. Create a branch if you are on the default branch, and commit what is pending (`commit`)
2. Push, open the PR if it has none and wait for every check to finish (`open-pr`)
3. Fix the failed checks: behavior test-first, lint/version/configuration by direct edit, PR title or body with `gh pr edit`
4. Decide on the pending review comments, implement the accepted ones, push them and reply in every thread (`review-pr-comments`)
5. Go again while something changed, then write a report with the PR, the checks, what was accepted and rejected, and what is left for you

It stops with one of five results:
- **clean**: nothing changed in the round and every check passed
- **round limit**: 3 fix rounds were used
- **no progress**: a check fails with the same error as in the previous round, or is still failing after a round that changed nothing
- **timeout**: checks are still pending after 30 minutes
- **blocked**: nothing in the repository can fix the failure (infrastructure, secrets, permissions, an external service)

```bash
# Create a commit
/stepwise-git:commit
```

This will:
1. Look at the uncommitted changes in the working tree
2. Group them into one or more commits by purpose
3. Stage each file by name, leaving out secrets, large binaries and generated artifacts
4. Create the commits in semantic commit format
5. Report the commits it created and every file it left out, with the reason

```bash
# Push the branch and open its PR
/stepwise-git:open-pr
```

This will:
1. Create a branch if you are on the default branch
2. Push it, never with force
3. Open the PR if the branch has none, with a Conventional Commits title and a `Summary` / `Testing` body (or the repo's PR template)
4. Wait until every check has finished, up to 30 minutes
5. Report the PR, every check with its result and the end of the log of each failed one

It does not change any file.

```bash
# Review PR comments
/stepwise-git:review-pr-comments [PR-number] [plan-file]
```

This will:
1. Auto-detect the PR from the current branch (or use the given number)
2. Fetch the pending comments (inline and general), ignoring resolved, outdated and already answered ones
3. Read the full affected files plus related files (tests, types, dependencies)
4. Decide `ACCEPT`, `REJECT` or `REPEATED` for each comment, with a technical reason
5. Implement the accepted changes, test-first when they change behavior (via `/stepwise-core:tdd` if stepwise-core is installed)
6. Commit and push
7. Reply individually in English to each accepted or rejected comment, without resolving any thread

## Features

- **Unattended**: No skill asks for confirmation; the report at the end is your control point
- **Never merges, never force-pushes**: The PR is left ready for you to merge
- **No Claude attribution**: Commits, PRs and replies are attributed to you, not Claude
- **Smart staging**: Stages each file by name and leaves out anything that looks like a secret
- **Rigorous PR review**: Defends existing code, only accepts changes backed by a concrete technical reason
- **Individual inline replies**: Publishes each response directly to the correct comment thread on GitHub
- **Soft dependency on stepwise-core**: Behavior fixes go through `/stepwise-core:tdd` when it is available; otherwise the fix starts with a failing test

> **Permissions**: whether the flow runs without stopping at a permission prompt depends on the session's permission mode. The project's tests are arbitrary commands, so they cannot be pre-approved by the skills.

## Related Plugins

- **stepwise-core**: Core workflow for Research → Plan → Implement → Validate
- **stepwise-web**: Web search and research capabilities

## License

Apache License 2.0 - See LICENSE file for details.
