# 1. System Overview

Date: September 4, 2025

## 1.1 Purpose and vision

SayHello is a full‑stack, mobile‑first language exchange platform that unifies real conversation practice with structured learning and cultural immersion. It addresses three core problems: (1) limited access to real, native‑speaker interaction; (2) weak linkage between courses and real‑world practice; (3) lack of cultural/social immersion in learning tools.

## 1.2 Users and contexts of use

- Learner (primary): finds partners, communicates with translation assistance, engages in the feed, enrolls in courses, tracks progress.
- Instructor (secondary): creates/manages courses, uploads materials (PDF, video, live links), mentors via group chat, evaluates and gives feedback.

Contexts: mobile usage on the go (public transport, campus), intermittent connectivity, short session bursts (1–10 minutes) for chat and feed; longer sessions (15–45 minutes) for course content.

## 1.3 Key features and workflows

- Language Exchange & Matching: native/target language pairing; search filters (country, gender, age); follow to see feeds.
- Chat & Translation: real‑time messaging with tap‑to‑translate messages; visibility of translate states and errors.
- Social Feed: public and followed views; create posts with text/images; like/comment/translate.
- Courses: discovery with ratings; enroll; access materials (PDF/video/links), group chat, session links; track performance; rate instructor.

Primary journeys evaluated: (a) find and message a native speaker; (b) post to feed; (c) enroll and open first course material.

## 1.4 Product and technical scope

- Platforms: Flutter mobile app (Android/iOS), with web support; backend services (e.g., Supabase/REST).
- Not in scope: voice/video calls; proctoring; advanced analytics dashboards.

## 1.5 Success criteria and metrics

- Time‑to‑first‑chat under 3 minutes for new users.
- Post‑publish confirmation recognized within 2 seconds; bounce after posting < 10%.
- Post‑enroll “start learning” action within 10 seconds, > 80% discoverability.
- Reduction in HE/CW high‑severity issues by > 60% after iteration.

## 1.6 Assumptions and constraints

- New users have basic familiarity with social apps (feeds, likes, follows).
- Intermittent network; must provide robust feedback and recovery.
- Privacy: learners may prefer anonymity initially (optional profile picture).

## 1.7 Evaluation scope and references

- Usability of key learner/instructor flows
- First‑time learnability (CW) and principle alignment (HE)
- See: HCI_Final_Report.md (summary), HCI_Evaluation_Findings.csv (all findings)
