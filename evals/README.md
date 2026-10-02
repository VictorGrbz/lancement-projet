# Evals

Behavior tests for the plugin, run with `claude plugin eval`. Each folder is one case: a `prompt.md`, its `graders/`, and a `fixture.sh` when the case needs files in the workspace.

## Run the cases that need no shell

From the repository root:

```bash
claude plugin eval . --tag new-project run-step finish-web --ablation none --trust-plugin --no-publish --scaffold --allow-tools Write Edit
```

- `--scaffold` runs each `fixture.sh`, which builds the workspace of the case. Only use it on suites you trust.
- `--allow-tools Write Edit` lets the skills write files. Without it, the cases that create files fail.
- `--ablation none` skips the no-plugin comparison and halves the cost. Drop it to see what the plugin adds.
- Expect about 2 USD of model calls and 2 to 3 minutes.

## The two `commit` cases

`commit-two-validations` and `commit-behind-branch` are tagged `needs-bash`. They make the skill run real git commands, so they need a shell granted to the run, and Claude Code only grants one inside an OS sandbox. That sandbox is available on Linux and macOS (and WSL2), not on native Windows, where these two cases are refused before they start.

```bash
claude plugin eval . --tag commit --ablation none --trust-plugin --no-publish --scaffold --allow-tools "Bash(git *)" Write Edit
```

The `fixture.sh` of both cases only needs `git` and `bash`.

## Notes

- A case passes when its score reaches `--threshold` (1.0 by default). Results are written to `evals/results/`, which is git-ignored.
- A slash command typed by the user loads the skill directly, without a `Skill` tool call, so the cases do not grade tool use of the `Skill` tool.
