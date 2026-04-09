# MVM Pulse — Full 10-Phase Build

## Overview

A premium AI-powered business and life health auditor. Users complete a 40-question assessment across 8 dimensions, receive a Pulse Score out of 100, get detailed analysis, and follow a personalized 12-week roadmap. Built by M5CAIRO (M5 Capital Partners LLC).

**Theme:** Follows system light/dark mode. Primary teal (#097770) accent. Dark navy backgrounds in dark mode, clean light surfaces in light mode.

---

## Features

### Onboarding (3 screens)

- Welcome screen with app name, tagline "Know your number. Own your trajectory.", and continue button
- Value proposition screen: "8 Dimensions. 40 Questions. One Score." with Diagnose/Understand/Improve icons
- Profile setup: first name, role selector, industry picker, company size picker — stored locally

### Assessment Engine

- 40 questions across 8 weighted dimensions (Financial Health, Operations, Leadership, Team & Culture, Technology & AI, Customer & Market, Personal Wellness, Growth & Learning)
- One question at a time with smooth crossfade transitions
- Progress bar, category label, 5 tappable answer cards per question
- Auto-advance after selection with back button
- Weighted scoring algorithm producing a Pulse Score 0–100

### Results Experience

- Email collection screen before results reveal
- Animated score ring with large number reveal (Apple Fitness-style)
- Level badge (Critical / At Risk / Developing / Strong / Elite)
- AI-generated executive summary based on strongest/weakest categories, role, and industry
- 8 expandable category cards with analysis: What This Means, Pain Points, Opportunities, Potential Impact, Next Step
- Unique analysis text for Low/Mid/High tiers per category
- Download PDF Report and Share Score buttons

### Dashboard (Daily Home Screen)

- Empty state with hero CTA when no assessment exists
- Hero score card with animated ring, score, level, date
- 8 mini category progress bars
- Score history chart (when 2+ assessments exist, using Swift Charts)
- 3 stat cards: Strongest, Weakest, Trend Direction
- Today's Task card with one-tap open and checkbox
- Streak counter card

### 12-Week Roadmap

- Auto-generated from user's two weakest categories
- 3–5 micro-tasks per week, 5–15 minutes each
- Weekly progress ring, task list with checkboxes
- Week themes: Diagnostic → Foundation → Implementation → Optimization
- Haptic feedback on task completion
- Celebration moment when week completes

### Streaks & Reassessment

- Consecutive day streak tracking with comeback messages
- Milestone badges at 7, 30, 90 days
- Monthly reassessment prompt at 30 days
- Old vs new score comparison with per-category deltas
- Roadmap regeneration after reassessment

### Subscriptions (RevenueCat)

- Free tier: full assessment, overall score, basic category numbers, one share style
- Premium: detailed analysis, roadmap, PDF report, score history, all share styles, reassessment insights, streaks, weekly insights
- $9.99/month, $79.99/year with 7-day free trial
- Premium paywall with clear Free vs Premium comparison table
- Restore purchases in Settings

### PDF Report

- Professional multi-page report: cover page, executive summary, score breakdown, detailed category analysis, top 5 recommendations, roadmap overview, disclaimer
- Generated with PDFKit, shareable via system share sheet

### Share Cards

- 3 visual styles: Light, Dark, Bold
- Shows Pulse Score, level, strongest dimension, MVM Pulse branding
- Style picker with live preview, share and save buttons

### Widget (WidgetKit)

- Small: score + level
- Medium: score + level + streak + today's task

### Siri Shortcuts (App Intents)

- "What's my Pulse Score?"
- "Start my daily task"

### Settings

- Profile editing (name, role, industry, company size)
- Notification preferences
- Appearance (system/light/dark)
- Subscription management
- Legal pages: Privacy Policy, Terms of Use, Disclaimer, Accessibility Statement, EULA
- Contact support ([m5cp@proton.me](mailto:m5cp@proton.me))
- Reset data with confirmation

---

## Design

- **Color palette:** Primary teal (#097770), dark navy (#07101e) for dark mode backgrounds, light surface (#F6F6F6) for light mode, body text #595959 light / adaptive dark, heading text #111111 light / white dark
- **Score colors:** Red (Critical), Amber (At Risk), Teal (Developing), Green (Strong/Elite)
- **Typography:** SF Pro with varied weights — bold/heavy for headings, regular for body. No custom fonts.
- **Cards:** Rounded corners, subtle shadows in light mode, elevated surfaces in dark mode
- **Animations:** Spring animations for transitions, animated score ring reveal, haptic feedback on completions, smooth crossfade between assessment questions
- **Dark mode:** Full support following system setting, all colors adaptive
- **Accessibility:** VoiceOver labels, Dynamic Type, 44×44pt minimum tap targets, Reduce Motion support, semantic colors

---

## Pages / Screens

1. **Onboarding Welcome** — Logo, app name, tagline, continue button on calm premium background
2. **Onboarding Value** — Bold headline with three icon cards (Diagnose, Understand, Improve)
3. **Profile Setup** — Form with name field, role segmented control, industry and company size pickers
4. **Dashboard (Empty)** — Hero card with "Take Your First Assessment" CTA
5. **Assessment** — Progress bar, category label, question text, 5 answer cards, back button
6. **Email Gate** — Clean email field with privacy reassurance before results
7. **Results Hero** — Large animated score ring, level badge, executive summary, PDF/Share CTAs
8. **Results Categories** — Scrolling accordion cards with expandable detailed analysis
9. **Dashboard (With Data)** — Score card → category bars → chart → stats → today's task → streak
10. **Roadmap** — Week header, theme, progress ring, task cards with checkboxes, weekly insight
11. **Streak Milestone** — Centered badge animation with supportive message
12. **Reassessment Compare** — Old vs new score side-by-side, category deltas, new roadmap CTA
13. **Premium Paywall** — Premium header, comparison table, plan options, trial messaging, restore
14. **Settings** — Grouped iOS-style rows: Profile, Notifications, Appearance, Subscription, Legal, Support, Reset
15. **Share Card Composer** — Card preview, style picker (Light/Dark/Bold), share and save buttons
16. **PDF Preview** — Report preview with export and share buttons

---

## App Icon

- Abstract pulse/wave mark on a dark teal gradient background
- Clean, premium feel matching the app's professional diagnostic tone

