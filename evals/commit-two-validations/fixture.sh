#!/usr/bin/env bash
# Workspace for the case: a git repository with a bare local remote, one pushed commit,
# and one new uncommitted file.
set -e
git init -q -b main
git config user.email "test@example.com"
git config user.name "Eval Test"
printf '.remote.git/\n' >> .git/info/exclude
git init -q --bare -b main .remote.git
git remote add origin "$PWD/.remote.git"
printf 'notes\n' > notes.txt
git add notes.txt
git commit -q -m "Add notes"
git push -q -u origin main
printf 'a new line\n' >> notes.txt
printf 'second file\n' > todo.txt
