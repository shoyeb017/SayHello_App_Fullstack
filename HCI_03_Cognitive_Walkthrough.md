# 3. Cognitive Walkthrough (CW)

## 3.1 Methodology

- Goal: assess first‑time learnability of critical journeys.
- Approach: break each task into steps and answer the four CW questions (intent, visibility, mapping, feedback).
- Participants: evaluators acting as first‑time users; assumptions documented in System Overview.

## 3.2 Tasks

1. Find and start a conversation with a native Spanish speaker.
2. Post an image with a question to the public feed.
3. Enroll in a course and open the first material.

## 3.3 Step analysis (highlights)

- Task 1 (Find partner): Filters entry wasn’t obvious; users scanned list instead. After opening profile, “Start Chat” was discoverable, but no preview of translation capability caused hesitation.
- Task 2 (Post): “Create post” entry was discoverable, but the lack of post‑publish confirmation led to uncertainty; users scrolled to check if it appeared.
- Task 3 (Enroll): Button lacked pressed/disabled state; after enroll, route did not clearly highlight the first material.

## 3.4 Recommendations

- Make Filters salient (button/chip), add first‑use hint, and persist last filters.
- On post, show confirmation toast and insert the new post at the top or navigate to it.
- On enroll, show disabled+spinner state, success confirmation, and route to Course Detail with a prominent “Start here” CTA.

## 3.5 Success criteria and measures

- Time‑to‑apply filters < 10s; % users who use filters on first try > 70%.
- Post‑publish recognition < 2s; % users who see confirmation without manual checking > 90%.
- Post‑enroll “Start here” click‑through within 10s; > 80% discoverability.

Details and per‑step table: HCI_Cognitive_Walkthrough_Findings.md.
