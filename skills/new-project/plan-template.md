# PLAN.md contract

`new-project` writes this format, `project-manager` checks it, `run-step` reads it. Do not change it without updating all three.

Write the content in the user's language (translate the headings below if it is not English). Keep the line `Status: todo` or `Status: done` exactly as written, in English, so it stays easy to find.

## Structure

```
# PLAN.md: <project name>

<one sentence describing the project>

## Product scoping
### Vision
### Use cases
### Success criteria
### Out of scope
### Risks

## Context for the executor
- Stack: <validated stack, and why>
- Reference documentation: <links>
- Constraints: <deadline, budget, technical limits>
- Git: <who manages Git, which commit skill to use>
- Private files: <files never to commit, if any>
- General rules: see the project's `CLAUDE.md`

---

## Step 0: Git repository setup     (only if a dedicated repository was asked for)
## Step 1: <title>
## Step N: <title>
## Step <last>: Finishing            (only for web projects)

---

## Automatic check
- [ ] <proposed PostToolUse hook, tailored to the stack>
```

## Step format

Every step MUST contain all of these lines, not just a title:

```
## Step N: <title>
- **Goal**: <one sentence>
- **Files**: <files concerned>
- **Destination**: <where the deliverable ends up>
- **Done when**: <a check anyone can run, not an opinion>
- **Status**: todo
```

Two optional lines may follow:

```
- **Note**: <for example, suggest Explore and Plan subagents for a heavy step>
- **Stop**: <the moment where the executor stops and waits for the user's validation>
```

`run-step` flips `Status: todo` to `Status: done` when a step is finished. At a `Stop` line it halts, shows what it has, and waits for the user's go-ahead.

## Rules

- Product scoping is the validated scoping sheet, copied as is. It chooses no technology: it may name an external service the project depends on (as a risk), never a stack, hosting provider or library.
- Every moment where a decision of the user is required gets a `Stop` line, because a plain instruction such as "ask the user" is not reliably followed. The usual moments: before applying fixes coming from a report (for example a review or an audit), and after reading a document supplied by the user (list what it contains that the plan does not, then wait for the decision; the plan prevails in case of doubt). Do not add a `Stop` line to a step that needs no decision.
- "Done when" must be verifiable: a command to run, a file that exists, a flow that works. Reject "looks good" or "works well".
- Keep steps small enough to be done and checked in one go. Split anything larger.
- If a dedicated repository was requested, the first step is "Step 0: Git repository setup": `git init` in the project folder, then `gh repo create <exact name> --public --source=. --remote=origin --push` (or `--private` if asked), with an initial commit once there is at least one file. If `PLAN.md` was declared private, `.gitignore` lists it from that initial commit, which then holds only `.gitignore` and the project settings. State that from this step on, the executor manages Git for the project, using `/lancement-projet:commit` for every commit and push.
- For a web project, add a final step "Finishing" that runs `/lancement-projet:finish-web` before any release. It requires the Impeccable plugin.
- Close with the "Automatic check" section: a checkbox proposing a PostToolUse hook tailored to the stack. It is merged into the project's `.claude/settings.json` by adding only the `hooks` key, and only if the user agrees.
- Do not hard-code a default stack, a hosting provider, or personal paths.

## Review checklist (used by `project-manager`, or by `new-project` if the agent is unavailable)

1. The scoping has all five sections: vision, at least one concrete use case, measurable success criteria, out of scope, risks (each risk with what limits it, or an explicit "no risk identified" with the reason).
2. The scoping chooses no technology (stack, hosting, libraries). Naming an external service as a dependency in a risk is fine.
3. Every step has Goal, Files, Destination, Done when, and Status.
4. Every "Done when" is verifiable.
5. No step is too large to be done and checked in one go.
6. `Stop` lines are in the right places: before fixes coming from a report, and after reading a document supplied by the user. No `Stop` line on a step that needs no decision.
7. If a dedicated repository was requested, Step 0 exists and matches the rule above.
8. A `CLAUDE.md` exists next to `PLAN.md`. If it does not, the plan contains a step that creates it from the executor rules.
9. If the project is a web project, the final "Finishing" step exists.
10. The "Automatic check" section is present.
11. If the plan is declared private, `.gitignore` handling appears in Step 0.
