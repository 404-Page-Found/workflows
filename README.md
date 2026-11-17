# workflows

Scheduled and event-driven GitHub Actions bots that maintain this repository: they find bugs and refactorings, implement requested issues, label and triage issues, and merge ready PRs. The original brief is in [docs/PROMPT.md](docs/PROMPT.md).

## Structure

```
.github/workflows/   one workflow per bot
docs/PROMPT.md       the brief the workflows were built from
LICENSE
```

## Setup

1. Create a fine-grained PAT (or classic PAT with `repo`) with access to this repo and add it as the secret `GH_PAT`. All bots use it for checkout and `gh` calls, so their actions are attributed to that account.
2. Add the secret `OPENCODE_API_KEY` for the `opencode/hy4-flash-free` model.
3. Create the labels used by the bots:

   ```bash
   gh label create "assignee:coding-bot" --force
   gh label create "bot-driving" --force
   ```

Every workflow also has a `workflow_dispatch` trigger for manual runs.

## Bots

- **bug-bot**: every 3 hours, files up to 5 non-duplicate bug issues, sharing the budget with refactor-bot.
- **refactor-bot**: every 3 hours, files up to 5 non-duplicate refactor issues, sharing the same budget.
- **coding-bot**: implements issues labeled `assignee:coding-bot` as PRs labeled `bot-driving`, and drives those PRs through review comments and failing checks.
- **label-bot**: applies existing labels to new issues and PRs; adds `assignee:coding-bot` only to implementation-ready issues from writers.
- **triage-bot**: posts one triage comment on each new issue (validity, location, severity, next step).
- **merge-bot**: squash-merges non-draft PRs with green checks, no conflicts, and no unresolved review threads.

Bug and refactor issues are titled `[bug-bot]` / `[refactor-bot]`; the split shifts toward whichever has fewer open issues.
