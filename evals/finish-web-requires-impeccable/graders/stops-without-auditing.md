---
type: llm
---

PASS if the final message tells the user that the Impeccable plugin is required and not installed, gives the install commands, and stops there without running an audit, a critique or any fix.
FAIL if the final message contains an audit score, a critique, a list of findings, or says that fixes were applied.
