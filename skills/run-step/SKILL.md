---
name: run-step
description: Execute the next unfinished step of PLAN.md, check its "Done when" criterion, mark it done, then suggest a commit. One step per call. Manual only.
disable-model-invocation: true
argument-hint: "[step number, optional]"
---

# /lancement-projet:run-step

Execute exactly one step of the project's `PLAN.md`, verify it, mark it done, then stop and wait for the user. Write everything you say to the user in the user's language.

This skill is the "executor" of the method: a fresh session opened in the project folder, where `PLAN.md` carries all the state. The plan is written by `/lancement-projet:new-project`.

Step requested by the user, if any: $ARGUMENTS

## 1. Find the plan

The project is the folder the session was opened in (the current working directory), not the folder this skill is stored in. Resolve every path from the step (`Files`, `Destination`) relative to the project folder, and never create or edit anything inside the plugin or the skill folder.

Read `PLAN.md` in the project folder, all of it: the scoping, the "Context for the executor" section (stack, constraints, Git rules, private files) and every step. If there is no `PLAN.md`, tell the user to open a session in the project folder or to run `/lancement-projet:new-project` first, and stop.

## 2. Pick the step

- By default, take the first step, in order, whose line is `Status: todo`. A step with no `Status` line counts as todo.
- If the user gave a step number, take that one. If earlier steps are still todo, say so and ask before continuing.
- If every step is done, say so and stop.

## 3. Announce the step

Show the user the step's Goal, Files, Destination and Done when, in a few lines. If the step has a `Stop` line, mention it too, so the user knows where you will pause.

If "Done when" cannot be verified as written (it is vague, subjective, or depends on something you cannot check), stop and ask the user how it should be checked. Do not guess and do not invent your own criterion.

## 4. Execute

- Do only this step. Touch only the files it lists, plus the `Status` line of the step in `PLAN.md`. Do not start, prepare or anticipate the next step.
- Follow the stack and constraints from the "Context for the executor" section. Follow the step's Note if it has one (for example, use Explore and Plan subagents for a heavy step).
- If the step has a `Stop` line, stop exactly at that moment: show what you have so far, then wait for the user's go-ahead. Never continue on your own, even if the rest looks obvious. After the go-ahead, carry on with the step.
- If the step needs something only the user can do (creating an account, choosing a name, providing a credential), stop and ask. Never ask the user to paste a secret (password, token, API key) in the chat: have them put it in a local file that is git-ignored, and read it from there.
- If you get blocked, stop and explain. Do not work around the blocker by changing the goal.

## 5. Verify

Run the check described in "Done when" and look at the real result: run the command, open the file, exercise the flow. Report the evidence honestly, including the output when it is short. If the check fails, fix it within the scope of the step, or report the failure. Never mark a step done on an unchecked or failed criterion.

## 6. Mark the step

Only after the check passes, change that step's `Status: todo` to `Status: done` in `PLAN.md`. Change nothing else in the plan. If the plan itself turns out to be wrong or incomplete, tell the user and propose the change instead of editing it silently.

## 7. Stop

Give a short summary: what was done, the evidence that the "Done when" check passed, the files changed, and everything you added that the step did not ask for (or, if there is nothing, say "nothing added"). Then:
- suggest the user run `/lancement-projet:commit` to save the work (you cannot run it for them; just suggest it);
- name the next step (or say the plan is finished; if the next step is the web "Finishing" step, mention `/lancement-projet:finish-web`);
- wait. Never start the next step without the user's go-ahead.

## Hard rules

- Never write inside the plugin or skill folder: the project is the current working directory.
- One step per call, never more.
- Never go past a `Stop` line without the user's go-ahead.
- Never mark a step done without a verified "Done when".
- Never move to the next step without the user's validation.
- Never ask for or store a secret in the chat.
- Never commit or push: suggest the commit skill instead.
