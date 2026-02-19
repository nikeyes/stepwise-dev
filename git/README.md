# Stepwise Git Plugin

Git commit workflow for creating clean commits without Claude attribution.

## What's Included

### Commands (1)
- `/stepwise-git:commit` - Create git commits with user approval and no Claude attribution

## Installation

```bash
# Add marketplace
/plugin marketplace add nikeyes/stepwise-dev

# Install this plugin
/plugin install stepwise-git@stepwise-dev
```

## Usage

```bash
# Create a commit
/stepwise-git:commit
```

This will:
1. Run `git status` to see untracked files
2. Run `git diff` to see changes
3. Run `git log` to match commit message style
4. Draft a commit message focusing on "why" not "what"
5. Stage relevant files
6. Create the commit
7. Verify with `git status`

## Features

- **No Claude attribution**: Commits are attributed to you, not Claude
- **Smart staging**: Only stages relevant files, warns about secrets
- **Style matching**: Follows your existing commit message patterns
- **Pre-commit hook support**: Handles hook failures gracefully

## Related Plugins

- **stepwise-core**: Core workflow for Research → Plan → Implement → Validate
- **stepwise-web**: Web search and research capabilities

## License

Apache License 2.0 - See LICENSE file for details.
