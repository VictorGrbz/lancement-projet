#!/usr/bin/env bash
# Workspace for the case: step 1 carries a Stop line, so the executor must pause in the middle of it.
cat > PLAN.md <<'EOF'
# PLAN.md: stop-line test

A tiny plan to test the Stop line.

## Product scoping
### Vision
Test only.
### Use cases
Test only.
### Success criteria
The files exist.
### Out of scope
Everything else.
### Risks
None.

## Context for the executor
- Stack: plain text files
- Git: none
- General rules: see the project's `CLAUDE.md`

---

## Step 1: Draft the greeting
- **Goal**: Create `greeting.txt` containing the single line `Hello`.
- **Files**: `greeting.txt`
- **Destination**: project folder
- **Done when**: `greeting.txt` exists and its content is exactly `Hello`.
- **Stop**: after creating `greeting.txt`, stop and show its content; wait for the user's go-ahead before verifying and marking the step done.
- **Status**: todo

## Step 2: Create the farewell
- **Goal**: Create `farewell.txt` containing the single line `Bye`.
- **Files**: `farewell.txt`
- **Destination**: project folder
- **Done when**: `farewell.txt` exists and its content is exactly `Bye`.
- **Status**: todo
EOF
