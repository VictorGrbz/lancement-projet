# lancement-projet

**A repeatable way to ship projects with Claude Code: guided scoping, a step-by-step plan, safe commits, and a quality pass before release.**

*[Version française](README.fr.md)*

- **A method, not a prompt.** Scoping, plan, execution, commit and finishing are separate steps with a clear hand-off between them, so a project does not depend on one long, fragile conversation.
- **Quality before release.** Every step of the plan has a check anyone can run, and web projects go through an audit, a critique and an independent review before they ship.
- **Guardrails by default.** Nothing is committed or pushed without a separate, explicit confirmation, and the dangerous git options are never used.
- **Built for people who are not developers.** The author is not a developer and delivers projects to production this way.

## The cycle

```
/lancement-projet:new-project   scoping interview, then PLAN.md and a CLAUDE.md for the executor
            |
            v
/lancement-projet:run-step      executes the next step of PLAN.md, checks it, stops   <-- repeat
            |
            v
/lancement-projet:commit        one confirmation to commit, another one to push
            |
            v
/lancement-projet:finish-web    audit, critique, review, validated fixes   (web projects)
```

The first session scopes the project and writes the plan. A second session, opened in the project folder, executes it one step at a time. `PLAN.md` is the only state shared between them, which keeps each session short and focused.

## Install

Two commands, in Claude Code:

```
/plugin marketplace add https://github.com/VictorGrbz/lancement-projet.git
/plugin install lancement-projet@victorgrbz-plugins
```

Requirements: Git. For `finish-web`, the [Impeccable](https://impeccable.style) plugin (tested with 4.1.1). Without it, the skill stops and tells you how to install it:

```
/plugin marketplace add pbakaus/impeccable
/plugin install impeccable@impeccable
```

## The four skills

| Skill | What it does |
|---|---|
| `/lancement-projet:new-project` | Interviews you on five points (vision, use cases, measurable success criteria, out of scope, what can go wrong), proposes a simple stack, asks whether the project gets its own repository, then writes `PLAN.md` and a `CLAUDE.md` for the executor. A reviewer agent reads the plan before you validate it. |
| `/lancement-projet:run-step` | Takes the first unfinished step of `PLAN.md`, does only that step, runs its "Done when" check, marks it done, suggests a commit, and waits. |
| `/lancement-projet:commit` | Shows the files and the message, commits after your yes, then asks again before pushing. |
| `/lancement-projet:finish-web` | Chains Impeccable's audit and critique, an independent review when mockups exist, your validation, the fixes, and a final consistency check. Reports hard-coded colors before and after. |

All four are manual: Claude never starts them on its own. The skills and messages are in English, and what they write for you (the plan, the commit message) follows your language.

## Example session (illustrative)

```
> /lancement-projet:new-project booking site for a dog groomer
  ... five questions, one at a time, with options and a recommendation each time ...
  PLAN.md written: 12 steps, 5 of them with a Stop line. The reviewer agent found 9 defects, all fixed.

(new session, opened in the project folder)
> /lancement-projet:run-step
  Step 1: Ask 10 existing clients whether they prefer booking online.
  Done when: the answers are collected and summarized in docs/survey.md.
  Stop: waiting for you to bring back the answers.
```

## Guardrails

- **Two confirmations for git.** One for the commit, a different one for the push, with the remote, the branch and the number of commits spelled out.
- **Never** `git add -A` or `git add .`, `--amend`, `--no-verify`, `--force` or `--force-with-lease`.
- **Sensitive files are flagged** before anything is added, and **a branch that is behind its remote is never pushed**: the skill tells you and asks how to proceed.
- **One step at a time.** A step is marked done only after its check has really been run.
- **`Stop` lines.** When a decision is yours (before fixes coming from a report, after reading a document you supplied), the plan says so and the executor halts. A plain "ask the user" is not reliably followed; a `Stop` line is.
- **An executor `CLAUDE.md`.** The session that executes the plan inherits no instructions, so the plugin writes its ground rules into the project: one step at a time, no "done" without proof, report anything added that was not asked for.
- **The interview stays in the main conversation.** Subagents cannot ask you questions, so the plugin never delegates the interview to one.

## How it differs from `commit-commands`

Anthropic's official `commit-commands` plugin is built for speed: one command stages and commits, and another also pushes and opens a pull request, with no confirmation step. `lancement-projet` makes the opposite trade: slower, with separate confirmations and the guardrails above, and it covers the whole method around the commit (scoping, plan, execution, finishing). It does not open pull requests; the two plugins can live side by side.

## Tests

The behavior is covered by evals in [`evals/`](evals/README.md), run with `claude plugin eval`: the plan contains the risks section and the `Stop` lines, the executor does one step and pauses at a `Stop` line, and the finishing skill stops cleanly when Impeccable is missing.

## About

Made by [VictorGrbz](https://github.com/VictorGrbz). Portfolio: [jess-vic.ovh](https://jess-vic.ovh).

MIT license.
