---
type: llm
---

PASS if the final message shows the content of the file that was created, says it is stopping because of the step's Stop line, and asks for the user's go-ahead before verifying and marking the step done.
FAIL if the final message says that step 1 is complete or done, or that the step was verified and marked done, or if it moves on to step 2.
