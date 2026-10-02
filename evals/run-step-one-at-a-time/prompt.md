---
description: One call of the executor skill does the first unfinished step only, marks it done, and leaves the other steps untouched.
tags: [run-step]
runs: 3
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

/lancement-projet:run-step
