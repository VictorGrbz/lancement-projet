---
name: commit
description: Safely commit the current changes, then push them, with two separate confirmations. Manual only.
disable-model-invocation: true
allowed-tools: Bash(git status *) Bash(git diff *) Bash(git log *) Bash(git branch *) Bash(git remote *) Bash(git fetch *) Bash(git rev-list *)
---

# /lancement-projet:commit

Commit the current changes, then push them. The commit and the push each need their own explicit confirmation from the user. Write everything you say to the user in the user's language.

## 1. Inspect (run in parallel)

- `git status`
- `git diff` and `git diff --staged`
- `git log --oneline -10`
- `git remote -v`
- `git fetch`, then `git status -sb` (or `git rev-list --left-right --count HEAD...@{u}` when an upstream is set), to see how far ahead of or behind the remote the branch is

## 2. Nothing to do

If there is nothing to commit AND nothing to push (branch up to date with its remote), say so and stop.

## 3. Sensitive files

If any changed or untracked file looks sensitive (keys, tokens, passwords, `.env` files, private data not meant for the repository), flag it before going any further and ask for confirmation. Never stage it silently.

## 4. Staging rule

Never run `git add -A` or `git add .`. Stage files by name only.

## Commit part (if there are changes to commit)

5. Write a short commit message that explains the why rather than the what. Match the language and style of the existing commits (look at the last ~10). If the repository has no commits yet, or the history mixes languages, write in English. Use a type prefix (Conventional Commits) only if the existing commits already do.
6. Show the user the list of files you will stage and the message, and wait for their confirmation. This is confirmation number 1.
7. Once confirmed: `git add <files>`, `git commit`, then run `git status` to check the tree is clean.

## Push part (if the branch has commits ahead of its remote)

8. Before proposing the push, check and show:
   - the target remote and its URL (`git remote -v`);
   - the current branch;
   - whether the push would create a new remote branch;
   - whether the local branch is behind the remote.
9. If the local branch is behind the remote, do not push. Tell the user and ask how to proceed. Never resolve it on your own: no merge, no rebase, no pull decided by you.
10. Ask for a confirmation that is explicit and distinct from the commit one, for example: "I am about to push N commit(s) to `<remote>/<branch>`. Confirm?" This is confirmation number 2. A yes given for the commit never covers the push.
11. Once confirmed: `git push` (use `git push -u <remote> <branch>` only when the branch has no upstream and the user confirmed the new remote branch), then run `git status` to check the branch is up to date with its remote.

## Hard rules

- Never commit or push without a separate, explicit confirmation for each action.
- Never use `--amend`, `--no-verify`, `--force`, `--force-with-lease` or `-f`, whatever the reason. If a hook fails, report it and let the user decide.
- Never push when the local branch is behind the remote.
- Never stage with `git add -A` or `git add .`.
- If the user asks for something these rules forbid (for example a force push), explain that this skill refuses it and that they can run it themselves in their terminal.
