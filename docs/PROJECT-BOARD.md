# Project board

HermesKey uses GitHub Issues and Milestones as the primary planning system.

If you also want a GitHub Project board, use the helper script:

```bash
./scripts/setup-project-board.sh
```

## Important

The GitHub CLI needs the `project` scope for this to work:

```bash
gh auth refresh -h github.com -s project
```

## What the script does

- creates a project titled **HermesKey Roadmap** if it does not exist
- links the repository to the project
- adds the current roadmap issues
- attempts to set their status to **Todo**

## Source of truth

Use these layers together:

- `README.md` — short entry point
- `docs/ROADMAP.md` — high-level plan
- GitHub Milestones — release buckets
- GitHub Issues — concrete work items
- optional GitHub Project board — visual workflow tracking
