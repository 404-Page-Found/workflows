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
   - Add repository secrets: `GH_PAT` (fine-grained PAT scoped to this repo with the repository permissions listed in Setup; used for checkout, `gh` calls, and `git push`) and `COPILOT_PAT` (fine-grained PAT with only the Account permission Copilot Requests: read; used for Copilot CLI authentication).

Never print, log, or commit secret values.
```

## Setup

1. **Add the `GH_PAT` secret.** Create a fine-grained PAT owned by your personal account (not an organization), with repository access set to only this repo and these repository permissions: **Contents** read and write, **Issues** read and write, **Pull requests** read and write, **Commit statuses** read, **Actions** read, and **Metadata** read (added automatically). It is used only outside Copilot steps: checkout, `gh` calls, `git push`, and label application. Fine-grained PATs can't call the Checks API, so `gh pr checks` may fail. coding-bot then can't see failing checks, but it still handles review threads.
2. **Add the `COPILOT_PAT` secret.** Create a separate fine-grained PAT owned by your personal account with only the Account permission **Copilot Requests** read. It is used as `COPILOT_GITHUB_TOKEN` in Copilot CLI steps. Those steps run with `--allow-all`, so this token must not have repo write access. Classic PATs are not supported by Copilot CLI.
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
| `coding-bot` | Processes one item per run from a single queue (`concurrency: coding-bot`, runs wait for the previous run). It drives an open `bot-driving` PR through review comments and failing checks if one exists, rebasing the PR branch onto its base and resolving merge conflicts when needed (force-pushing with lease); otherwise it implements the oldest issue labeled `assignee:coding-bot` as a PR labeled `bot-driving`. |
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
