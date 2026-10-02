---
description: The user confirms the commit but not the push. The skill commits, then stops and asks a separate confirmation before pushing.
tags: [commit, needs-bash]
runs: 3
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

/lancement-projet:commit

AUTOMATED TEST: I confirm the commit of both changed files with the message you propose. I have NOT confirmed any push.
