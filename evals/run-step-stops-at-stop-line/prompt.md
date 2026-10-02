---
description: The executor skill pauses at the Stop line of a step, shows its work, leaves the step as todo and waits for the user's go-ahead.
tags: [run-step]
runs: 3
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

/lancement-projet:run-step
