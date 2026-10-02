---
name: finish-web
description: Web finishing pass before release, chaining Impeccable audit, critique, independent review, validated polish and doctor. Requires the Impeccable plugin. Manual only.
disable-model-invocation: true
argument-hint: "[target: page, route or component]"
---

# /lancement-projet:finish-web

Run a quality pass on a web project before it ships: technical audit, UX critique, an independent review against the approved mockups when they exist, validated fixes, then a consistency check of Impeccable's own artifacts. It drives the Impeccable plugin, whose skill is `impeccable:impeccable`. Write everything you say to the user in the user's language.

Target given by the user, if any: $ARGUMENTS

## 1. Check that Impeccable is installed

Look at the skills available in this session. If `impeccable:impeccable` is not there, stop now and tell the user, in their language:

- this skill needs the Impeccable plugin;
- to install it, run these two commands, then restart the session (or run `/reload-plugins`):
  ```
  /plugin marketplace add pbakaus/impeccable
  /plugin install impeccable@impeccable
  ```
- more information: https://impeccable.style

Do not continue, do not try to replace Impeccable with your own checks.

## 2. Choose the target

The project is the folder the session was opened in. If it has a single page or one main route, use it as the target. If the user gave a target, use that. Otherwise ask which page, route or component to finish. If the folder does not look like a web project (no pages, components or stylesheets), say so and stop.

## 3. Audit (report only)

Invoke the skill `impeccable:impeccable` with the arguments `audit <target>`. It produces a technical report: accessibility, performance, responsive behavior, theming, implementation integrity. Do not fix anything at this stage.

## 4. Critique (report only)

Invoke `impeccable:impeccable` with the arguments `critique <target>`. It produces a UX review with heuristic scoring. Do not fix anything at this stage.

## 5. Independent review (report only)

Get a fresh pair of eyes on the build from the Impeccable reviewer agent, `impeccable:impeccable-finish-reviewer`. Launch **one** instance only, never several: this is a single review, not a swarm, and each run costs quota. It reads files and edits nothing.

Skip this step, and say so in the synthesis with the reason, in any of these cases:
- the agent is not available in this session;
- there is no approved mockup to compare with: look for `.impeccable/mocks/` in the project and ignore its `decision/` subfolder;
- there are no review captures: look for `.impeccable/review/desktop.png` and `.impeccable/review/mobile.png`. The reviewer has no browser and cannot take screenshots itself: without valid captures it only answers `disposition: recapture`. Do not take the captures yourself to fill the gap.

Otherwise, give the agent the paths that exist, and only those: the project direction files (`PRODUCT.md`, `DESIGN.md`), the approved mockups under `.impeccable/mocks/`, the captures in `.impeccable/review/`, and the project's `PLAN.md`. Relay its disposition word (`ship`, `fix`, `rebuild` or `recapture`) to the user exactly as returned, and do not soften it. If it asks for a recapture, report that the captures are missing or invalid and carry on without it.

## 6. Count hard-coded colors

Count the color values written directly in the project's code (hex, `rgb()`, `hsl()`), leaving out the tokens or theme file where colors are meant to be defined. Note the method (the pattern and the folders searched) and the figure: you will repeat the exact same count after the fixes, so the two numbers are comparable.

## 7. Synthesis and validation

Present a combined summary of the reports: the audit score (out of 20), the findings ranked P0 to P3, the result of the critique, and the gaps found by the independent reviewer (or the reason it was skipped). Then **stop** and wait for the user's explicit validation before changing anything. The user may ask to skip some findings.

## 8. Polish

Once validated, invoke `impeccable:impeccable` with the arguments `polish <target>` to apply the fixes, P0 first. Impeccable enforces its own limit on the number of passes: do not push it beyond what it announces as its limit.

## 9. Doctor

Invoke `impeccable:impeccable` with the argument `doctor` to check the consistency of Impeccable's artifacts (product and design files, configuration, hook).
- Fixes of severity `auto` are applied directly, without asking (documented behavior of doctor).
- Findings of severity `mention` are reported to the user.
- Never run a command of severity `route` (such as `init` or `document`) without the user's separate, explicit confirmation.

## 10. Recap

Finish with a recap: audit score before and after, findings fixed versus remaining, the state of doctor, the number of hard-coded colors before and after (same method as step 6), and the files changed. If files changed, suggest the user run `/lancement-projet:commit` (you cannot run it for them, just suggest it). Never commit or push yourself.

## Hard rules

- Never run `polish` or any other fix without the user's explicit validation at step 7.
- Never launch more than one reviewer agent, and never let it fix anything.
- Never run a `route` command of doctor without a separate confirmation.
- Never write inside the plugin or skill folder: the project is the current working directory.
- Never commit or push.
