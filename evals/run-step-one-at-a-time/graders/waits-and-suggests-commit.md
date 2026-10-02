---
type: llm
---

PASS if the final message reports that step 1 is done with some evidence, suggests running the commit skill (`/lancement-projet:commit`), names step 2 as the next step, and waits for the user before doing it.
FAIL if the final message says that steps 2 or 3 were also executed, or if it commits or pushes by itself, or if it does not say what the next step is.
