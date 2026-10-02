#!/usr/bin/env bash
# Workspace for the case: a git repository with a bare local remote where someone else has
# already pushed a commit, so the local branch is behind once fetched. One new uncommitted file.
set -e
git init -q -b main
git config user.email "test@example.com"
git config user.name "Eval Test"
printf '.remote.git/\n.other/\n' >> .git/info/exclude
git init -q --bare -b main .remote.git
git remote add origin "$PWD/.remote.git"
printf 'notes\n' > notes.txt
git add notes.txt
git commit -q -m "Add notes"
git push -q -u origin main
git clone -q .remote.git .other
(
  cd .other
  git config user.email "other@example.com"
  git config user.name "Other Person"
  printf 'from someone else\n' > other.txt
  git add other.txt
  git commit -q -m "Add other file"
  git push -q origin main
)
rm -rf .other
printf 'my local change\n' > mine.txt
