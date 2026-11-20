Create GitHub Actions workflows and docs for repo maintenance in this repository. Keep files concise.

Global rules:
- Bot workflows, except merge-bot, install GitHub Copilot CLI via npm without pinning the version (`npm i -g @github/copilot`) - Bot workflows, except merge-bot, install GitHub Copilot CLI via npm without pinning the version (`npm i -g @github/copilot`) and run it non-interactively with `copilot -p "<prompt>" --model claude-haiku-5.5 --allow-all`.
- Two repo secrets are used, and the Copilot CLI token must be isolated from the repo-write token. `GH_PAT` (my GitHub PAT) is used for checkout, all `gh`/API calls, label application, and `git push`, and never in a step that runs Copilot CLI. It must be a fine-grained PAT owned by my personal account, scoped to this repo, with repository permissions Contents, Issues, Pull requests, Commit statuses, Checks, Actions (read), and Metadata (read). `COPILOT_PAT` is used only as `COPILOT_GITHUB_TOKEN` in Copilot CLI steps. It must be a fine-grained PAT owned by my personal account with only the Account permission Copilot Requests: read. Classic PATs are not supported by Copilot CLI. Copilot steps get job-scoped `GITHUB_TOKEN` (`${{ github.token }}`) for `gh` calls, with least-privilege `permissions`.
- Use `persist-credentials: false` on every checkout so the token is not written to `.git/config`.
- Every workflow has a `workflow_dispatch` trigger as a manual fallback.
- Use least-privilege `permissions` and a `concurrency` group per workflow.

Docs:
1. `README.md`: a concise summary of the repo (purpose, structure, setup, and the list of maintenance bots with one line each).
2. `docs/PROMPT.md`: a verbatim copy of this entire prompt.

Workflows (`.github/workflows/`):
1. `bug-bot.yml`: Hunt for bugs in the codebase and file at most 5 non-duplicate GitHub issues per run. Run every 3 hours starting at 00:00 UTC (`0 */3 * * *`). Share a dynamic issue ratio with refactor-bot: the combined budget of 5 issues per run is split between bugs and refactors, and the split shifts toward whichever category has fewer open bot issues. Check existing open and closed issues to avoid duplicates.
2. `refactor-bot.yml`: Suggest code refactorings in the codebase and file at most 5 non-duplicate GitHub issues per run. Same schedule and shared dynamic ratio as bug-bot. Check existing issues to avoid duplicates.
3. `coding-bot.yml`: Process one item per run from a single queue (concurrency group `coding-bot`, cancel-in-progress false, so each run waits for the previous one). Prefer the oldest open PR labeled `bot-driving` and address its review comments and failing checks. If none exists, implement the oldest open issue labeled `assignee:coding-bot` and open a PR for it with the label `bot-driving`. No PR cap. Trigger on issue label events, PR review/check events, and schedule.
4. `label-bot.yml`: On `issues` and `pull_request` opened events, apply labels from the existing repo labels only. Never create labels. Add `assignee:coding-bot` to an issue only if it is implementation-ready. The Copilot step only writes a decision file (`labels.json`) and cannot write labels. A separate step validates the decision against the repo label list, never applies `bot-driving`, and applies labels with `GH_PAT`, so `assignee:coding-bot` still triggers coding-bot.
5. `triage-bot.yml`: On `issues` opened, verify the issue against the codebase and post one concise triage comment (validity, likely location, severity, and next step).
6. `merge-bot.yml`: Merge open PRs that are not drafts, have green checks, have no merge conflicts, and have no unresolved review threads. Use the PAT secret. Does not use Copilot CLI. Trigger on PR review, check, and status events, on schedule, and on `workflow_dispatch`.

Setup (one-time, manual):
- Create the labels `assignee:coding-bot` and `bot-driving` if they do not exist.
- Add the secret `GH_PAT`.
- Add the secret `COPILOT_PAT`.

Output: the files above, each complete and ready to commit.
