---
name: new-project
description: Scope a new project with a guided interview, then write a step-by-step PLAN.md. Manual only.
disable-model-invocation: true
argument-hint: "[project name, or path to an existing brief]"
---

# /lancement-projet:new-project

Run a guided project kickoff: scope the project with the user, pick a simple stack, then write a `PLAN.md` that a separate session can execute step by step with `/lancement-projet:run-step`.

Talk to the user in the user's language. Ask questions with the `AskUserQuestion` tool when it fits (several questions per call), and always leave room for a free-text answer.

You never write application or production code in this skill. You only write `PLAN.md`, the project's `CLAUDE.md` and light files (README, specs, `.gitignore`, project settings).

Project name or brief given by the user: $ARGUMENTS

## 0. Existing material

If the user points to existing documents (a brief, notes, a spec, a folder), read them fully first. From them, prepare:
- a draft of the five scoping sections (vision, use cases, success criteria, out of scope, risks);
- a draft of the answers to the constraint questions of step 2.

If there is nothing, or the user says there is no brief, go straight to step 1.

## 1. Scoping interview

Read `${CLAUDE_SKILL_DIR}/interview.md` and follow it. Run the interview yourself, in this conversation. Never delegate it to a subagent: subagents cannot ask the user questions, so their questions would never arrive.

If step 0 produced a draft, pass it along as the starting point: confirm it with the user instead of interviewing from scratch. Wait for the validated scoping sheet before going on. It becomes the "Product scoping" section of the PLAN.md.

## 2. Constraints

Ask what the interview does not cover:
- constraints: deadline, budget, technical limits;
- project type: website, application, automation, other;
- whether the project has a visual or frontend side.

If step 0 produced a draft of these answers, present it for confirmation instead of asking again.

## 3. Dedicated Git repository

Always ask whether the project should have its own Git repository with a GitHub remote.
- If yes, ask for the exact repository name. Never choose it yourself.
- The repository is public by default. Say so, and let the user pick private instead.
- If it is public, also ask whether `PLAN.md` may be published: a plan can contain personal details, goals or client names. If not, `PLAN.md` and any other private document (demo script, personal notes) go in the project's `.gitignore` from step 0 of the plan and are never committed.

## 4. Stack proposal

From the scoping sheet and the constraints, propose a simple stack that fits the project, with one sentence on why it suits the user's level. There is no default stack: derive it from the needs.
- Before settling, run one targeted web search to check that the choice is still current.
- For each precise business need the scoping reveals (booking, payment, auth, ...), run one targeted web search to find an existing building block instead of reinventing it. Families to consider: copy-paste component kits, focused libraries, standalone modules, curated "awesome" lists. Check that a library is maintained before retaining it (downloads, last release date). One search per identified need is enough, no open-ended research.
- If the existing material from step 0 already holds explicit architecture decisions, mention them and check them for consistency rather than ignoring them.

Wait for the user to validate or adjust the stack before continuing.

## 5. Target folder

Ask where the project lives. Never choose the path yourself. Create the folder if it does not exist. Use the absolute path from here on, and never write inside the plugin or skill folder.

## 6. Project settings

Do not impose a model or an effort level in the project's `.claude/settings.json`: those are personal choices. If the user wants the automatic check described in `plan-template.md`, add only the `hooks` key to that file (create it if needed, never touch other keys), and only after the user agrees. Commit this file with the project, never put it in `settings.local.json`.

## 7. Executor CLAUDE.md

The executor session opened in the project folder inherits no instructions from this one, so give it a common ground. Read `${CLAUDE_SKILL_DIR}/executor-claude-template.md` and create `CLAUDE.md` in the target folder from the block it contains, replacing the project name and the validated stack.

If a `CLAUDE.md` already exists, never overwrite it. Show the user the section "Executor rules" you would add, and write it only after the user agrees.

## 8. Write PLAN.md

Read `${CLAUDE_SKILL_DIR}/plan-template.md` and write `PLAN.md` in the target folder, following that contract exactly. If a `PLAN.md` already exists, show the planned changes first and write only after the user agrees.

Where a step is heavy on research or architecture, add a note suggesting the executor use Explore and Plan subagents for it.

Place a `Stop` line on every step where a decision of the user is needed: before fixes coming from a report (for example the "Finishing" step, where `/lancement-projet:finish-web` already waits for validation before correcting), and after the executor reads a document supplied by the user. A plain instruction to "ask" is not reliably followed, a `Stop` line is.

## 9. Review before validation

Before showing the plan, get a second look: call the `project-manager` agent (`lancement-projet:project-manager`) and give it the path of the `PLAN.md` and the path `${CLAUDE_SKILL_DIR}/plan-template.md`. It reads the plan and returns a list of defects; it never rewrites and never asks questions. If the agent is unavailable or fails, run the same checks yourself using the checklist in `plan-template.md`.

Fix or report every defect. Then present the plan to the user and ask for validation. Do not present a plan that is missing a scoping section or a "Done when" criterion.

## 10. Closing

Remind the user to open a new session in the project folder and run `/lancement-projet:run-step` to execute the plan one step at a time. This session does not execute any step.

## Hard rules

- Never write application or production code.
- Never run the interview in a subagent.
- Never choose the repository name or the folder path yourself.
- Never overwrite an existing `PLAN.md` or `CLAUDE.md` without showing the changes first.
- Never touch `model` or `effortLevel` in a project's settings.
