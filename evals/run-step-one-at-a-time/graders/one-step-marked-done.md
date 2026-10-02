---
type: regex
pattern: '^- \*\*Status\*\*: done\s*$'
flags: m
match: 'count:1'
target: { source: file, path: PLAN.md }
---
