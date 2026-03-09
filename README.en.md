# Stand By Me

A system that automatically processes GitHub issues using the Claude Code agent feature.

## Overview

Define the repositories to monitor in `repositories.yaml`, and Claude Code will periodically check issues, then automatically handle analysis, implementation, and PR creation.

## Setup

### Prerequisites

- [Claude Code](https://claude.ai/code) installed
- [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated

```bash
gh auth login
```

### Repository Configuration

Edit `repositories.yaml` to add the repositories you want to monitor.

```yaml
repositories:
  - owner: your-org
    repo: your-repo
    labels:
      - claude       # Issues with this label will be processed
    priority: high   # high | normal | low
```

To make an issue eligible for processing, attach the label specified in `labels` to the issue on GitHub.

## Usage

Launch Claude Code from the project directory.

```bash
cd stand-by-me
claude
```

### Check Issues

```bash
/check-issues
```

Lists all target issues across every repository defined in `repositories.yaml`.

### Periodic Monitoring

```bash
/loop 5m /check-issues
```

Automatically checks for issues every 5 minutes.

### Process an Issue

```
Use issue-analyzer to analyze m0cchi/emacsenv#42, then use issue-implementer to fix it
```

## File Structure

```
stand-by-me/
├── repositories.yaml              # Monitored repository definitions
├── example_repositories.yaml      # Configuration example
├── CLAUDE.md                      # Rule definitions for agents
└── .claude/
    ├── agents/
    │   ├── issue-fetcher/         # Reads YAML and fetches issue list
    │   ├── issue-analyzer/        # Analyzes individual issues and creates implementation plans
    │   └── issue-implementer/     # Implements changes and creates PRs
    └── skills/
        └── check-issues/          # Entry point for issue checking
```

## Agent Roles

| Agent | Role |
|---|---|
| `issue-fetcher` | Reads `repositories.yaml` and fetches issues from all repositories |
| `issue-analyzer` | Analyzes a specified issue and creates an implementation plan |
| `issue-implementer` | Applies code changes based on the analysis result and creates a PR |
