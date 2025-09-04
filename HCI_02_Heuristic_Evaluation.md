# 2. Heuristic Evaluation (HE)

## 2.1 Methodology

- Four evaluators applied Nielsen’s 10 Heuristics to core flows: onboarding/profile, partner matching, chat/translation, feed, course enrollment/materials.
- Each issue was logged with category, heuristic, severity (0–4), and a concrete recommendation; duplicates were merged.
- Severity: 0=none, 1=cosmetic, 2=minor, 3=major, 4=catastrophic.

## 2.2 Heuristics reference

1. Visibility of system status 2) Match between system and the real world 3) User control and freedom 4) Consistency and standards 5) Error prevention 6) Recognition rather than recall 7) Flexibility and efficiency of use 8) Aesthetic and minimalist design 9) Help users recognize, diagnose, recover from errors 10) Help and documentation

## 2.3 Snapshot of findings (sample)

Refer to HCI_Evaluation_Findings.csv for the full list. Key samples:

- Chat send lacks “sent/delivered” status [Heuristic 1,9] — Sev 2 — Add message status and resend on failure.
- Enroll button has no pressed/disabled state [1,9] — Sev 3 — Disable with spinner; success toast then navigate to course detail.
- “Give‑and‑take” matching unclear [2,6] — Sev 3 — Add concise tooltip/onboarding card; link to help.
- Filters reset after search [6,7] — Sev 2 — Persist until reset; show chips and Clear All.
- PDF vs video icon similarity [4] — Sev 1 — Use distinct icons/labels and consistent previews.

## 2.4 Distribution and prioritization

- Current logged items (sample set): 13 total (HE≈10, CW≈3). High‑severity (≥3): 3 items; Medium (2): 6; Low (1): 1; Info (0): 0.
- Prioritization axes: severity, frequency, reach (how many flows), and fix effort.
- Top fixes: global feedback states (send/post/enroll), filter persistence/discoverability, matching explanation.

## 2.5 Recommendations (prioritized)

1. System feedback and error recovery: add toasts/snackbars, inline statuses, disabled+spinner, and retry where applicable.
2. Discoverability: prominent Filters entry, saved chips, empty‑state guidance.
3. Comprehension: micro‑copy to explain matching and course states; align terms with user mental models.
4. Consistency: standardized iconography and empty/error states; platform‑appropriate patterns.

See: HCI_Evaluation_Findings.csv and HCI_Evaluation_Findings.md for details.
