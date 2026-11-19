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
3. Copy every `.github/workflows/*.yml` file from the source into this repo's `.github/workflows/`, creating the directory if needed. Do not modify the file contents. If a file with the same name already exists:
   - If it is identical to the source, leave it unchanged.
   - If it differs, update it by replacing it with the source version, and record it as updated.
   - Never touch files in `.github/workflows/` that do not exist in the source.
4. Do not copy `docs/PROMPT.md` or `README.md`. Do not copy `LICENSE`.
5. If no workflow files were added or updated, stop and tell me they are already up to date. Otherwise, create a new branch named `add-maintenance-bots` (or `update-maintenance-bots` if it already exists on the remote), commit the workflow files with the message "Add or update maintenance bot workflows", and push it. Do not push to the default branch.
6. Open a pull request into the default branch with `gh pr create`, using a body that lists each workflow as added or updated, and the setup steps below.
7. Delete the temporary clone.
8. Report back in 100 words or fewer, and include these one-time setup steps for me to run (do not run them without confirmation):
   - Create labels: `gh label create "assignee:coding-bot" --force` and `gh label create "bot-driving" --force`
   - Add repository secret: `GH_PAT` (a fine-grained PAT owned by a personal account, scoped to this repo, with the repository permissions listed in Setup and the Account permission Copilot Requests: read; used for checkout, `gh` calls, and Copilot CLI authentication).

Never print, log, or commit secret values.
```

## Setup

1. **Add the `GH_PAT` secret.** Create a fine-grained PAT owned by your personal account (not an organization), with repository access set to only this repo and these permissions:
   - Repository: **Contents** read and write, **Issues** read and write, **Pull requests** read and write, **Commit statuses** read, **Actions** read, and **Metadata** read (added automatically).
   - Account: **Copilot Requests** read.

   Classic PATs are not supported by Copilot CLI. Fine-grained PATs can't call the Checks API, so `gh pr checks` may fail. coding-bot then can't see failing checks, but it still handles review threads.
2. **Create the labels** used by the bots:

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
| `coding-bot` | Implements issues labeled `assignee:coding-bot` as PRs labeled `bot-driving` (only while at most 5 `bot-driving` PRs are open), then drives those PRs through review comments and failing checks. |
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
