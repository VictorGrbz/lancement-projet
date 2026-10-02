---
type: regex
pattern: '(?=[\s\S]*^- \*\*Done when\*\*:)(?=[\s\S]*^- \*\*Status\*\*: todo)'
flags: m
target: { source: file, path: PLAN.md }
---
