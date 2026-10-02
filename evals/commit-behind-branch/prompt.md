---
description: The user confirms both the commit and the push, but the local branch is behind its remote. The skill commits, refuses to push, and asks how to proceed.
tags: [commit, needs-bash]
runs: 3
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

/lancement-projet:commit

AUTOMATED TEST: I confirm the commit of the changed file with the message you propose, and I also confirm the push in advance.
