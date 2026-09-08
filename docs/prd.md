# Product Requirements Document (PRD) — friendO
**A private notepad and reminder for friendships**

This document uses the words defined in [CONTEXT.md](../CONTEXT.md). Where a word is
capitalised, it is a defined term and it means exactly what that file says it means.

---

## 1. Executive Summary & Vision
**friendO** is an intentional, privacy-first app for looking after friendships, without the
gamification or social exhaustion of networking apps and CRM tools.

Modern social apps reward passive scrolling, surface-level reactions, and broadcast vanity metrics.
Deep friendships need something else: **regularity (Cadence)**, **recall (Topics and Updates)**,
and **absolute emotional safety (privacy)**.

friendO treats looking after a friendship as a repeating loop. Each Friend travels around the Dial
at their own Cadence, weekly, monthly, or quarterly, toward the top. When you log a Meeting, that
Friend's Bead returns to 12:00 and starts again. Notes, gift ideas, deep conversations, and
personal vulnerabilities stay in an encrypted database on the phone.

---

## 2. Target Audience & Core Problem Statement
### 2.1 Target Personas
- **The Distracted Humanist:** Someone who cares deeply about the people around them, but has
  trouble keeping track of Meetings, conversations, and dates. They want to remember a birthday or
  a Friend's kid's name, and it does not come naturally. They know that writing things down beats
  relying on a fading memory in a life full of distractions. This is our main persona.
- **The Intentional Connector:** Young professionals, creatives, and thoughtful adults whose close
  friendships have spread out across cities, busy careers, and life stages. Keeping in touch is
  genuinely hard, because they simply do not see their childhood friends often.
- **The Privacy-Conscious Individual:** People who will not put private reflections or sensitive
  notes about their friends onto cloud servers, corporate notes apps, or ad-driven platforms.

### 2.2 Core Pain Points
1. **Out of sight, out of mind:** Friendships fade through inertia, not conflict.
2. **Conversation amnesia:** Meeting again after two or three months feels awkward or repetitive,
   because the details of the last conversation are gone.
3. **Over-engineered CRMs:** Personal CRMs feel cold and transactional. Pipelines, deal stages, and
   cold outreach tactics belong to sales, not friendship.
4. **Shoulder surfing:** Reading your Notes about a Friend on a train or in a cafe risks exposing
   private thoughts to whoever is sitting next to you.

---

## 3. Product Principles & Metaphor
1. **Loops, not pipelines.** A Friend travels around the Dial and comes back. Approaching 12:00 is
   not a failure or a penalty. It is an invitation to get in touch.
2. **Local-first, zero telemetry.** No servers, no tracking, no ad brokers. Everything stays on the
   phone.
3. **Thoughtful warmth.** Deep violet, soft debossed surfaces, glowing Beads, and rounded contours.
4. **Discreet at a glance.** The app hides sensitive content behind a lock and keeps it out of the
   task switcher preview.

---

## 4. Key Screens & Architectural Scope

### 4.1 Screen 1: The Dial
* **Purpose:** The main screen, and the app's heartbeat.
* **Key Features & UX:**
  - **Three Orbits:** Each Orbit holds the Friends whose Cadence falls in its range.
    - *Inner Orbit:* Short Cadence. Family and closest friends.
    - *Middle Orbit:* Regular close friends.
    - *Outer Orbit:* Everyone else. Mentors, and friends who live far away.
  - **12:00 and the closing glow:** A glowing vertical axis at 12:00 marks the Due Date. A soft
    conic glow warms the last quarter of the lap, from 9:00 to 12:00, fading out toward 9:00.
  - **One-tap Meeting logging:** A fast button to log a coffee, a phone call, or an evening out. The
    Friend's Bead returns to 12:00 at once.
  - **Counters:** Live counts of Friends who are *near their Due Date*, *on track*, and *recently
    met*.

### 4.2 Screen 2: Friends List
* **Purpose:** A searchable list of every Friend, with quick actions.
* **Key Features & UX:**
  - **Debossed search field:** Search by Friend name, Topic, Affinity, or Orbit.
  - **Orbit filter chips:** Filter across *All*, *Inner Orbit*, *Middle Orbit*, and *Outer Orbit*.
  - **Overdue banner:** Names the Friends whose Due Date has passed, in Priority Order.
  - **Friend cards:**
    - A Phase bar showing how far through the Cadence the Friend has travelled (`28/30d`, `6/7d`).
    - The date of the last Meeting, and where it happened.
    - The Topics waiting for the next Meeting (*"Ask about the Kyoto pottery workshop and the puppy
      allergy test"*).
    - An inline one-tap button to log a Meeting.

### 4.3 Screen 3: Add a Friend
* **Purpose:** Add a new Friend and choose their Cadence.
* **Key Features & UX:**
  - **Name and Avatar picker:** A picture from the phone, or a generated Avatar badge.
  - **Cadence presets:** 7, 14, 30, 60, or 90 days, or a custom number of days.
  - **Preferred ways to meet:** Face to face, phone, messaging, or voice notes.
  - **First Facts and Milestones:** Recessed fields for birthdays, partner and children's names,
    dietary needs, and anniversaries.

### 4.4 Screen 4: Friend Notepad
* **Purpose:** What to read before a Meeting, and what to write after one.
* **Key Features & UX:**
  - **Topics and Updates:** A checklist of Topics to raise, and Updates about what has changed in
    the Friend's life. Neither is ever cleared by the app.
  - **Meeting history:** A timeline of past Meetings, where they happened, and what was said.
  - **Mood and length:** Quick labels for how a Meeting felt (*deep, light, brief*).
  - **Gift ideas and curiosities:** A scratchpad for gift ideas, book recommendations, and links.

---

## 5. Visual & Design System Guidelines
See [DESIGN.md](DESIGN.md) for the full system. In brief:

* **Colour:** deep violet canvas (`#141026`, `#0f0b21`), slate violet surfaces (`#1c182f`,
  `#211c33`), violet and lavender accents (`#d0bcff`, `#a078ff`), amber for Overdue, high-contrast
  white for titles and muted lavender for secondary text.
* **Typography:** `Plus Jakarta Sans` throughout.
* **Surfaces:** soft bevels, debossed inset shadows on fields and search, raised outer shadows on
  cards, and generous corner radii everywhere.

---
