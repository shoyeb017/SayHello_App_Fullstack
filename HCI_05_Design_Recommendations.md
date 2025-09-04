# 5. Design Recommendations and Comparative Insight

## 5.1 Which method identified more issues?

- HE surfaced more total issues due to breadth; CW found fewer but higher‑impact blockers in first‑use flows.

## 5.2 Unique issues by method

- HE: consistency/standards, terminology alignment, and global empty/error states.
- CW: weak affordances and missing step feedback inside flows (filters entry, post confirmation routing, post‑enroll CTA).

## 5.3 Practicality in this context

- HE was faster to execute and aggregate. CW required more time but provided deeper task‑level insights for Connect, Post, and Enroll.

## 5.4 Prioritized roadmap (Q1)

P0 (global feedback & guidance)

- Add toasts/snackbars and inline statuses for send/post/enroll/follow/translate.
- Disable+spinner on long‑running actions; show error with retry for failures.
- Add micro‑copy for matching; link to concise help.

P1 (discoverability & consistency)

- Prominent Filters entry on Connect; persist filters; add “Clear all”.
- Standardize iconography for PDFs/videos; unify empty/error states and messages.

P2 (onboarding & learnability)

- Onboarding cards for key concepts (give‑and‑take, filters, translation in chat).
- Post‑enroll routing: Course Detail with a clear “Start here” CTA; highlight first unit/material.

## 5.5 Acceptance criteria (examples)

- After sending a message, a sent/delivered indicator appears within 500ms; failure shows retry.
- After tapping Post, a confirmation toast shows and the new post appears at the top within 1.5s.
- After Enroll, the button disables with a spinner; success routes to Course Detail with “Start here” highlighted.

## 5.6 Validation plan

- Run a mini‑CW on the three tasks post‑fix; target metrics in System Overview §1.5.
- Monitor analytics: time‑to‑first‑chat, post success confirmations, post‑enroll start rate.

See also: HCI_Final_Report.md (summary), HCI_Evaluation_Findings.csv, HCI_Cognitive_Walkthrough_Findings.md.
