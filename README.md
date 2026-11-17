# Workflows

Scheduled and event-driven GitHub Actions bots that maintain this repository: they find bugs and refactorings, implement requested issues, label and triage issues, and merge ready PRs. The original brief is in [docs/PROMPT.md](docs/PROMPT.md).

## Installation

Paste the prompt below into any coding agent (Copilot CLI, Claude Code, OpenCode, Codex, etc.) while it is open in the target repository:

```text
You are installing the maintenance bot workflows into the current repository.

Source: https://github.com/404-Page-Found/workflows (default branch).

Steps:
1. Confirm the current directory is a git repository with a GitHub remote. If not, stop and tell me.
2. Shallow-clone the source into a temporary directory outside this repo (e.g. `git clone --depth 1 https://github.com/404-Page-Found/workflows <tmp>`).
3. Copy every `.github/workflows/*.yml` file from the source into this repo's `.github/workflows/`, creating the directory if needed. Do not modify the file contents. If a file with the same name already exists, stop and ask me before overwriting it.
4. Do not copy `docs/PROMPT.md` or `README.md`. Do not copy `LICENSE`.
5. Create a new branch named `add-maintenance-bots`, commit the workflow files with the message "Add maintenance bot workflows", and push it. Do not push to the default branch.
6. Open a pull request into the default branch with `gh pr create`, using a body that lists the six workflows and the setup steps below.
7. Delete the temporary clone.
8. Report back in 100 words or fewer, and include these one-time setup steps for me to run (do not run them without confirmation):
   - Create labels: `gh label create "assignee:coding-bot" --force` and `gh label create "bot-driving" --force`
   - Add repository secrets: `GH_PAT` (a PAT with access to this repo, used for checkout and `gh` calls) and `OPENCODE_API_KEY` (for the `opencode/hy4-flash-free` model).

Never print, log, or commit secret values.
```

## Setup

1. **Add the `GH_PAT` secret.** Use a fine-grained PAT (or a classic PAT with `repo`) that has access to this repo. All bots use it for checkout and `gh` calls, so their actions are attributed to that account.
2. **Add the `OPENCODE_API_KEY` secret** for the `opencode/hy4-flash-free` model.
3. **Create the labels** used by the bots:

   ```bash
   gh label create "assignee:coding-bot" --force
   gh label create "bot-driving" --force
   ```

Every workflow also has a `workflow_dispatch` trigger for manual runs.

## Bots

| Bot | What it does |
| --- | --- |
| `bug-bot` | Every 3 hours, files up to 5 non-duplicate bug issues, sharing the budget with `refactor-bot`. |
| `refactor-bot` | Every 3 hours, files up to 5 non-duplicate refactor issues, sharing the same budget. |
| `coding-bot` | Implements issues labeled `assignee:coding-bot` as PRs labeled `bot-driving`, then drives those PRs through review comments and failing checks. |
| `label-bot` | Applies existing labels to new issues and PRs. Adds `assignee:coding-bot` only to implementation-ready issues from writers. |
| `triage-bot` | Posts one triage comment on each new issue: validity, location, severity, and next step. |
| `merge-bot` | Squash-merges non-draft PRs that have green checks, no conflicts, and no unresolved review threads. |

Bug and refactor issues are titled `[bug-bot]` or `[refactor-bot]`. The split shifts toward whichever bot has fewer open issues.

## Structure

```
.github/workflows/   one workflow per bot
docs/PROMPT.md       the brief the workflows were built from
LICENSE
```
