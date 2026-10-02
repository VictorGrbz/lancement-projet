---
description: The kickoff skill, with every interview answer given in advance, writes a PLAN.md with a Risks section and Stop lines, plus an executor CLAUDE.md.
tags: [new-project, slow]
runs: 2
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

/lancement-projet:new-project

AUTOMATED TEST: nobody can answer questions. All answers below are VALIDATED by the user. Do not wait for anything and do not ask questions: treat every answer as confirmed, and go through ALL steps of the skill until PLAN.md and CLAUDE.md are written and the review is done. Where a step asks to confirm or validate, consider it confirmed.

Project: a booking website for a freelance dog groomer.
Target folder: the current working directory (it already exists).

1. Vision: dog owners in one town cannot book a grooming slot without phoning, and the groomer loses calls while working. The site lets owners book online 24/7.
2. Use cases: (a) an owner finds a free slot on a phone and books in under 2 minutes; (b) the groomer sees tomorrow's bookings and cancels one when a dog is ill; (c) an owner gets a reminder the day before.
3. Success criteria: a booking works end to end on a phone in under 2 minutes; at least 20 online bookings in the first month; fewer than 3 missed calls per week reported by the groomer.
4. Out of scope (v1): online payment, multiple groomers, a customer account area, a mobile app.
5. Risks: (a) personal data of owners and dogs (privacy law): collect the minimum, a privacy notice, no data kept beyond 2 years; (b) dependence on an email/SMS provider for reminders: choose a provider with a free tier and test the failure case; (c) recurring cost of the SMS reminders: cap the monthly volume, default to email; (d) hypothesis never checked: owners prefer booking online to phoning: ask 10 existing clients before building.

Constraints: live in 3 weeks, budget under 20 euros per month, the groomer is not technical.
Project type: website. Visual side: yes (a simple, friendly website).
Dedicated Git repository: no.
Stack: you may propose a simple stack, it is validated as proposed. Web search is not available in this test: say so and rely on your own knowledge.
Settings: no automatic check hook wanted.
