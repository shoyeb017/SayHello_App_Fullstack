# Human-Computer Interaction (HCI) Evaluation Report: SayHello App

Date: September 4, 2025

## 1. System Overview

SayHello is a full‑stack, mobile‑first language exchange platform that unifies real conversation practice with structured learning and cultural immersion. Learners discover and chat with native speakers, follow and contribute to a social feed, and enroll in instructor‑led courses—all in one app.

Primary user roles and goals:

- Learner: find suitable partners, communicate with translation support, participate in the feed, enroll in courses, and track progress.
- Instructor: create/manage courses, upload materials (PDF, video, links), guide learners via group chat, track and feedback on performance.

Core feature areas evaluated:

- Language Exchange & Matching
- Chat & Translation
- Social Feed (Public/Followed)
- Course Discovery, Enrollment, and Content Access

## 2. Heuristic Evaluation (HE)

### Methodology

Four evaluators conducted a heuristic inspection using Nielsen’s 10 Usability Heuristics. Each evaluator independently reviewed critical flows (onboarding/profile, partner matching, chat/translation, feed interactions, course enrollment/materials). Findings were consolidated, de‑duplicated, categorized, and rated for severity on a 0–4 scale.

Heuristics reference:

1. Visibility of system status 2) Match between system and the real world 3) User control and freedom 4) Consistency and standards 5) Error prevention 6) Recognition rather than recall 7) Flexibility and efficiency of use 8) Aesthetic and minimalist design 9) Help users recognize, diagnose, and recover from errors 10) Help and documentation

Severity scale (0–4): 0=Not a problem, 1=Cosmetic, 2=Minor, 3=Major, 4=Catastrophe

### Summary of Findings (HE)

The HE surfaced multiple issues across visibility/feedback, control, and terminology. Highlights (see full list in HCI_Evaluation_Findings.md):

- Feedback gaps after actions (send message, follow, enroll) [1,9] — severity 2–3.
- Unclear “give‑and‑take” matching concept and criteria [2,6] — severity 3.
- Filter persistence and discoverability issues [6,7] — severity 2.
- Content type icon consistency (PDF vs video) [4] — severity 1.

Top recommendations (HE):

- Add non‑intrusive confirmations and loading/disabled states across interactive flows.
- Explain matching model via micro‑copy/onboarding and inline helper text.
- Persist filters until reset; surface “Saved filters” chips; add “Clear all”.
- Standardize media icons and labels; ensure consistent empty/error states.

## 3. Cognitive Walkthrough (CW)

### Methodology

We selected three representative tasks for first‑time users and walked through each step against the four CW questions (will the user try to achieve the right effect; notice that the correct action is available; associate action with effect; receive feedback indicating progress/completion).

Tasks:

1. Find and start a conversation with a native Spanish speaker.
2. Post an image with a question to the public feed.
3. Enroll in a course and open the first material.

### Summary of Findings (CW)

Key breakdowns (details in HCI_Cognitive_Walkthrough_Findings.md):

- Filter affordances on Connect were not obvious; users may overlook advanced filters and default to scrolling (discoverability) — add visible “Filters” chip/button and entry‑point hint.
- After posting, success state was ambiguous (feedback) — show toast + navigate to the posted item or inject into top of feed.
- During enrollment, button state and post‑enroll cue were unclear — disable + spinner on press, then confirmation route to course detail with a “Start here” affordance.

## 4. Comparative Analysis (HE vs CW)

Overlap:

- System feedback gaps appeared in both methods across chat send, post publish, enroll actions.
- Explanatory micro‑copy needs (matching model) surfaced in HE and was reinforced by CW confusion during partner search.

Differences:

- HE found global consistency issues (iconography, empty states) and information architecture clarity (terminology).
- CW exposed step‑level discoverability and sequencing problems (where to find filters, what happens after enroll/post) that HE alone might not reveal.

Complementary insight:

- HE provided breadth against established principles; CW provided depth on first‑use learnability and flow clarity. Combined, they produced a prioritized, actionable backlog spanning system‑wide polish and task‑level fixes.

## 5. Design Recommendations and Comparative Insight

Which method identified more issues?

- HE surfaced more total items due to its breadth; CW revealed fewer but higher‑impact flow blockers for new users.

Unique issues per method?

- HE uniquely flagged consistency/standards and terminology alignment. CW uniquely revealed missing step feedback and weak affordances within flows (e.g., filters, post confirmation routing).

Practicality in our context:

- HE was faster to execute and aggregate. CW required more coordination but delivered richer guidance for critical journeys (Connect, Post, Enroll).

Priority recommendations:

- Elevate system feedback and progress states (send/post/enroll/follow/translate) with toasts, inline statuses, and disabled + spinner states.
- Improve discoverability for Connect filters and post‑enroll next steps (“Start learning” CTA).
- Clarify matching concepts via onboarding cards and inline help; ensure terminology matches user mental models.
- Standardize iconography and empty/error states; persist user filters and preferences.

## 6. Conclusion

Applying both HE and CW gave a comprehensive view of SayHello’s UX. Addressing feedback visibility, filter and routing affordances, and explanatory copy will meaningfully improve learnability and satisfaction for both learners and instructors. The attached findings and recommendations form a clear, prioritized path to elevate usability in the next iteration.
