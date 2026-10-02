# CLAUDE.md template for the executor

`new-project` creates a `CLAUDE.md` in the project folder from the block below. An executor session opened in that folder does not inherit any other instructions: these rules are its common ground. Replace `<project>` and `<stack>` when generating it, and add nothing else without a reason.

If the project already has a `CLAUDE.md`, never overwrite it: propose adding the content of the block below as a section named "Executor rules" (without its first line), and write only after the user agrees.

Write the generated file in the user's language (translate the block below if it is not English).

```markdown
# CLAUDE.md: <project>

You are the executor of this project: you carry out PLAN.md step by step and you write the code. Validated stack: <stack>.

## How to work
- One step of PLAN.md at a time. Stay within its scope and its "Done when" criterion. Do not move to the next step without the user's agreement.
- Never say "done" without proof: run the planned check (build, lint, test, a check in the browser) and report the real result, failures included.
- When there is a bug, find the cause before fixing it. Do not pile up patches.
- Reuse the project's existing conventions and values (names, structure, colors, fonts, spacing). A value that matches an existing one does not get a new copy. List any value that has no equivalent.
- Report everything you added that was not asked for.

## Mandatory stops (wait for the user's validation)
- At every `Stop` line of a step in PLAN.md: stop, show what you have, and wait. Never continue on your own.
- Before applying fixes coming from a report: present a summary of the report first.
- After reading a document supplied by the user: list anything in it that PLAN.md does not cover. PLAN.md prevails in case of doubt.

## Git
- Use `/lancement-projet:commit` for every commit and push. No force push, no `--amend`, no `--no-verify`.
- Never put a secret (`.env`, keys, tokens) in the repository or in the chat.
```
