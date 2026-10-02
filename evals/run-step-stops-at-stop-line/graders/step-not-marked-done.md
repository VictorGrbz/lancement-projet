---
type: regex
pattern: '^- \*\*Status\*\*: todo\s*$'
flags: m
match: 'count:2'
target: { source: file, path: PLAN.md }
---
