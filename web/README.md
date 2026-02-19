# Stepwise Web Plugin

Web search and research capabilities for gathering external context and information.

## What's Included

### Agents (1)
- `web-search-researcher` - Deep web research agent that searches and analyzes web content to answer questions

## Installation

```bash
# Add marketplace
/plugin marketplace add nikeyes/stepwise-dev

# Install this plugin
/plugin install stepwise-web@stepwise-dev
```

## Usage

The `web-search-researcher` agent is automatically invoked by Claude when you ask questions that require external information:

```
"What are the best practices for implementing OAuth 2.0?"
"How do other projects handle rate limiting?"
"What's the current state of React Server Components?"
```

You can also invoke it explicitly via the Task tool when you need Claude to perform deep web research on a specific topic.

## Features

- **Deep research**: Performs thorough web searches to find relevant information
- **Source analysis**: Fetches and analyzes web pages for accurate answers
- **Citation support**: Provides sources for all information gathered
- **Context-aware**: Integrates findings with your existing codebase context

## Related Plugins

- **stepwise-core**: Core workflow for Research → Plan → Implement → Validate
- **stepwise-git**: Git commit workflow without Claude attribution

## License

Apache License 2.0 - See LICENSE file for details.
