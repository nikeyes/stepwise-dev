---
name: open-pr
description: Push the current branch, open its pull request if it has none, and wait for every PR check to finish. Reports the result without fixing anything.
model: inherit
disable-model-invocation: false
allowed-tools: Bash(git status:*) Bash(git branch:*) Bash(git switch:*) Bash(git log:*) Bash(git diff:*) Bash(git push:*) Bash(gh repo view:*) Bash(gh pr view:*) Bash(gh pr create:*) Bash(gh pr checks:*) Bash(gh run view:*) Read Glob
---

# Open PR

Push the current branch, make sure it has a pull request, wait until every check on it has finished, and report the result. Do not ask for confirmation and do not change any file.

## Rules

- **Uncommitted changes**: they are not part of the PR. List them in the report and carry on with what is committed.
- **Nothing to open**: if the branch has no commits ahead of the default branch and no open PR, say so and stop.
- **Branch**: if you are on the repository's default branch, create `type/short-description` from the main commit with `git switch -c`; the commits come with it. Do not reset the local default branch: report that it is still ahead of its remote. On any other branch, use it as it is.
- **Push**: `git push -u origin <branch>`. Never force-push. If the push is rejected, stop and report why.
- **Existing PR**: if the branch already has an open PR, leave its title and body alone.
- **New PR**: ready for review (not a draft), against the default branch.
  - **Title**: one Conventional Commits subject (`type(scope): description`) that covers the whole branch. With a single commit, use its subject. It becomes the squash commit in many repos.
  - **Body**: if the repo has a pull request template, fill it in. Otherwise write `## Summary` (what changes and why) and `## Testing` (what was run and its result; only what actually ran).
  - **Never include**: ticket identifiers, Claude attribution, "Generated with" lines.
- **Waiting**:
  - Checks take a few seconds to register after a push. If none are reported, retry for up to 2 minutes before concluding that the repo has no checks.
  - Wait with `gh pr checks <pr> --watch`, in stretches shorter than your command timeout, repeating until no check is pending or 30 minutes have passed in total.
  - A check that failed, was cancelled or timed out has finished. Do not wait for reviews that are not checks.
- **Failed checks**: for each one, get the end of its log with `gh run view <run-id> --log-failed`. If it is not a GitHub Actions run, give its details URL instead.
- **Report**:
  - the PR URL, and whether you created it or it already existed
  - every check with its result
  - for each failed check, the end of its log
  - the checks still pending if the 30 minutes ran out
  - uncommitted changes you left out
