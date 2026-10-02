#!/usr/bin/env bash
# Workspace for the case: a three-step PLAN.md, none of the steps done, no Stop line.
cat > PLAN.md <<'EOF'
# PLAN.md: one-at-a-time test

A tiny plan to test that one call executes exactly one step.

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

## Step 1: Create the first file
- **Goal**: Create `first.txt` containing the single line `one`.
- **Files**: `first.txt`
- **Destination**: project folder
- **Done when**: `first.txt` exists and its content is exactly `one`.
- **Status**: todo

## Step 2: Create the second file
- **Goal**: Create `second.txt` containing the single line `two`.
- **Files**: `second.txt`
- **Destination**: project folder
- **Done when**: `second.txt` exists and its content is exactly `two`.
- **Status**: todo

## Step 3: Create the third file
- **Goal**: Create `third.txt` containing the single line `three`.
- **Files**: `third.txt`
- **Destination**: project folder
- **Done when**: `third.txt` exists and its content is exactly `three`.
- **Status**: todo
EOF
