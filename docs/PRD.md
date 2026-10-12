# Clarity — Product Requirements Document

| | |
| --- | --- |
| **Product** | Clarity (working name) — places review app |
| **Platform** | iPhone first (Flutter). Android in Phase 3 from the same codebase. Small web share page. |
| **Owner** | Bodhisatwa Chakraborty |
| **Status** | Phase 1 in progress — all MVP screens built on mock data; backend integration starting |
| **Last updated** | 2026-10-10 |
| **Related** | [`ARCHITECTURE.md`](./ARCHITECTURE.md) · [`DESIGN_SYSTEM.md`](./DESIGN_SYSTEM.md) · [`feature-brief.pdf`](./feature-brief.pdf) (original brainstorm) · [`../AGENTS.md`](../AGENTS.md) |

---

## 1. Summary

A personal map of every place you've actually been, each pin carrying your own
short review, shared with friends as one link.

> **"Your friends' honest opinions, on a map, for any kind of place."**

**Positioning:** any place, not just food · friends, not strangers · proof you
were there, not just a wishlist.

**Core hook:** sign up with your phone number, sync your contacts, instantly see
which friends are already on the app, and open their map to see every place
they've been.

## 2. Problem

- Google Maps reviews come from strangers. They're numerous but impersonal,
  gamed by businesses, and say nothing about whether *you* would like a place.
- Friends' recommendations — the ones people actually trust — are buried in
  WhatsApp chats, Instagram saves and memory. They can't be searched, mapped or
  reused.
- People who travel or explore a lot become the friend everyone asks *"where
  should I go?"*, and answer the same question again and again.
- Existing apps each solve one slice (see §5); none combines **any place +
  friends' reviews + proof of visit + travel memory**, and none is built
  India-first.

## 3. Vision and goals

**Vision:** your map becomes the answer to "where should I go?" — for you, and
for everyone who trusts you.

### Goals

| # | Goal | Measured by |
| --- | --- | --- |
| G1 | Make logging a place fast enough to do on the spot | Median time from "Add" to saved visit < 60 s |
| G2 | Make friends' opinions discoverable | % of new users who open at least one friend's map in week 1 |
| G3 | Build a habit of logging after every outing | Weekly active loggers; visits per active user per month |
| G4 | Grow through friends, not ads | Invites sent per user; % of sign-ups from an invite or share link |
| G5 | Earn trust | Share of visits that are verified; reported/removed content stays near zero |

### Non-goals (for now)

- A public review platform competing with Google on volume.
- Algorithmic feeds, ads, or paid ranking for businesses — ever.
- Curated city guides by a central team (Platrr's model).
- Android and web app beyond the share page until Phase 3.
- Monetisation before people use the app weekly.

### Phase gates

Each phase starts only when the one before has real users. A social feed with no
friends on it is empty.

| Phase | Gate to move on |
| --- | --- |
| Phase 1 · iPhone MVP | **20 friends use it weekly** |
| Phase 2 · Social | **People post without being prompted**; App Store public launch |
| Phase 3 · Android + AI | Then business pages, printed books |

## 4. Target users

| Persona | Description | What they need |
| --- | --- | --- |
| **The explorer** (primary) | Travels, treks, rides, eats out a lot; the friend everyone asks for recommendations. | A fast way to log places, a map that shows off where they've been, one link to send instead of typing lists. |
| **The asker** | Planning a trip or a night out; trusts friends far more than star ratings. | See which friends have been somewhere and what they said; save their pins to a Want to go list. |
| **The group planner** | Organises trips with friends ("Goa trip 2027"). | A shared list several friends add to and vote on. |
| **The memory keeper** | Wants a record of where they've been over the years. | Revisits, trips, "on this day", yearly recap. |

**First users (open question):** college friends, a travel or biker group, or
one city such as Agartala.

**Market:** India-first — Indian phone numbers (+91), rupee budgets (₹–₹₹₹₹),
categories that fit Indian travel (temples, dhabas, viewpoints, hostels),
India's DPDP Act.

## 5. Competitive landscape

| App | What it does well | Gap we exploit | Idea worth borrowing |
| --- | --- | --- | --- |
| **Beli** | Ranked restaurant lists, friends' feed, Match Score | Food only; some find ranking inaccurate | Compare-to-rate; friend-rating average; streaks |
| **Mapstr** | Personal map of saved places, browser share link | Caps free users' places; mostly a wishlist | No-app-needed share link; To try / Tried status |
| **Corner** | Personalised map that learns taste | Discovery-led, not friends-led | Paste an Instagram/TikTok link → pin |
| **Polarsteps** | Auto-tracked trips, printed travel book | Trips only, not everyday places | Scratch map; trip → book |
| **Platrr** | Dish-level logs, verified visits, curated cafés | One city, cafés only, curated | Verified visit badge; mood filters |
| **Google Maps** | Huge place database | Reviews from strangers | Use its Places API for search; don't compete on data |

**Our edge:** breadth (any place, anywhere) and the personal, shareable map
built from people you know.

## 6. Core concepts

| Term | Meaning |
| --- | --- |
| **Place** | A real-world location (name, category, coordinates, address). Shared by everyone. Never holds opinions. |
| **Visit** | One person's experience of one place on one date: status, rating, the required tip, review text, photos, tags, companions. Many visits per place — yours, friends', revisits. |
| **Recommend** | Every review answers "Would you recommend it?"; No shows as *Not recommended*. *Want to go* is a save, not a review. |
| **Tip ("one thing to know")** | Required one-liner on every visit: the single thing a friend needs ("go before 7am, parking fills up"). |
| **Verified visit** | A visit backed by proof: an on-site GPS check-in, or photo EXIF location/time matching the place. |
| **Friend** | A mutual connection (request → accept). Contacts who are on the app are suggested as friends. |
| **Map** | Everything one person has logged, as pins coloured by category, plus a list view. |
| **List** | A named collection of places; collaborative lists have several members who add places together. |
| **Feed** | Chronological stream of friends' visits, asks and lists. No algorithm. |

> **Keep Place and Visit separate.** It is what makes friends' reviews of the
> same place, revisits, verified visits and trips possible.

## 7. Scope by phase

### Phase 1 · iPhone MVP — *in progress*

Phone OTP + Sign in with Apple · profile · contact sync · add a place · write a
review · your map and list · place detail · share links · privacy controls ·
friends and requests · feed · search · collaborative lists · notifications ·
TestFlight to 20 friends.

> The UI for every Phase 1 screen is built and runs on mock data. The remaining
> Phase 1 work is the backend (see [`ARCHITECTURE.md`](./ARCHITECTURE.md) §12).

### Phase 2 · Social

Friend rating on every place · "Who's been here?" · save from a friend ·
verified visit badge · reactions, comments and "Thanks, went there!" ·
ask for recs · shareable story cards · App Store public launch · push
notifications.

### Phase 3 · Android + AI

Android app (same code) · Taste Match % · natural-language search over friends'
reviews · AI trip draft · Year in places recap · Pro plan.

### Backlog (unprioritised ideas)

Review freshness fade · revisit log with rating history · compare-to-rate ·
context tags (solo-friendly, safe for women at night, washroom, network signal,
wheelchair access, pet-friendly, good for work) · voice reviews · trips with
route lines · scratch map of states/countries · on this day · printed travel
book · time capsule notes (unlock on-site) · blind recommendation (unlocks
within 1 km) · hidden-gem score · import from Google Maps / Takeout · paste a
reel link · friend city guides · offline mode · home-screen widget · yearly goal,
explorer level, friendly challenges (badges themselves: §9.15) · "rate it while it's
fresh" nudges · helpful credit ("3 friends visited because of you").

★ Strongest bets from the brief: verified visit badge, compare-to-rate, Taste
Match %, Year in places, time capsule notes.

## 8. Screens

The design (`Clarity App Design.html`, 390×844 artboards) defines 24 screens.
All are built in `lib/features/`.

| # | Screen | Feature folder | Phase |
| --- | --- | --- | --- |
| 01 | Splash | `onboarding` | 1 |
| 02 | Welcome | `onboarding` | 1 |
| 03 | Phone number | `onboarding` | 1 |
| 04 | OTP | `onboarding` | 1 |
| 05 | Create profile | `onboarding` | 1 |
| 06 | Permissions explainer | `onboarding` | 1 |
| 07 | My map (tab 1) | `map` | 1 |
| 08 | List view | `map` | 1 |
| 09 | Add a place | `add_place` | 1 |
| 10 | Place detail | `place` | 1 |
| 11 | Write / edit review | `review` | 1 |
| 12 | Feed (tab 2) | `feed` | 1 |
| 13 | Find friends | `friends` | 1 |
| 14 | Friends & requests (tab 3) | `friends` | 1 |
| 15 | Friend profile | `friends` | 1 |
| 16 | Search | `search` | 1 |
| 17 | Share sheet | `share` | 1 |
| 18 | Collaborative list | `lists` | 1 |
| 19 | My profile (tab 4) | `profile` | 1 |
| 20 | Settings | `profile` | 1 |
| 21 | Contacts consent | `onboarding` | 1 |
| 22 | Notifications | `notifications` | 1 |
| 23a–c | Empty states: map, friends, place with no reviews | `map`, `friends`, `place` | 1 |
| 24a–c | System states: offline, feed error, feed loading | `system`, `feed` | 1 |
| 26–35 | Badges: unlock (first, level up, two at once), progress toast, profile badges, all badges, badge detail, friend's badges, Get started checklist, badge share card | `badges`, `profile`, `friends` | 1 |

**Primary flow:** splash → welcome → phone → OTP → create profile →
permissions → contacts consent → find friends → my map → add a place → write a
review → place detail → share.

## 9. Functional requirements (Phase 1)

Priority: **P0** = required for TestFlight to 20 friends · **P1** = should ship
in Phase 1 · **P2** = can slip to Phase 2.

### 9.1 Sign-up and authentication

| ID | Requirement | Priority |
| --- | --- | --- |
| AUTH-1 | Sign up and log in with an Indian phone number (+91 default; country picker) and a 6-digit SMS OTP. | P0 |
| AUTH-2 | OTP can be resent after a cooldown; wrong codes show a clear error; rate limits protect against abuse. | P0 |
| AUTH-3 | Sign in with Apple as an alternative (App Store rule when offering third-party login). A phone number must still be verified before contact sync. | P0 |
| AUTH-4 | Sessions persist across app launches and refresh silently. | P0 |
| AUTH-5 | "I already have an account" path logs in and restores the user's map. | P0 |

*Acceptance:* a new user reaches their (empty) map in under 2 minutes; a
returning user opening the app lands on their map with no login prompt.

### 9.2 Profile

| ID | Requirement | Priority |
| --- | --- | --- |
| PROF-1 | Create profile: name and unique username. The username becomes the share link (`<domain>/<username>`). | P0 |
| PROF-2 | Profile header shows places visited, cities, top categories. | P0 |
| PROF-3 | Edit name, username, avatar. | P1 |

### 9.3 Contact sync — the core feature

| ID | Requirement | Priority |
| --- | --- | --- |
| CON-1 | Ask for contacts permission only when the user taps **Find friends** (after sign-up or later), never on launch. A consent screen first explains what is sent and that non-users are never stored. | P0 |
| CON-2 | Read numbers from the device, normalise to E.164 (`+91XXXXXXXXXX`), send to the server over TLS. | P0 |
| CON-3 | Server matches against verified users' numbers, returns the matches, and **discards every other number immediately**. Nothing about non-users is stored or logged. | P0 |
| CON-4 | Show "N of your contacts are here"; tap a person to open their map; send friend requests. | P0 |
| CON-5 | Support iOS limited contacts access: show matches from what was shared plus an "Add more contacts" button. | P0 |
| CON-6 | Contacts not on the app get an **Invite** button that opens WhatsApp with the user's map link. Installing from that link auto-connects the two. | P1 |
| CON-7 | Re-sync quietly when contacts change; notify "Rahul from your contacts just joined." | P2 |
| CON-8 | Setting **"Let people who have my number find me"** — on by default; when off, the user never appears in anyone's matches. | P0 |

### 9.4 Add a place

| ID | Requirement | Priority |
| --- | --- | --- |
| ADD-1 | Search places via Google Places (autocomplete, India coverage including small towns). | P0 |
| ADD-2 | **I'm here:** use GPS to suggest nearby places. | P0 |
| ADD-3 | **Drop a pin** for places with no listing (a hidden waterfall, a roadside dhaba). | P0 |
| ADD-4 | Category: food, café, stay, trek, viewpoint, temple, beach, shop, other. | P0 |
| ADD-5 | If the place already exists in Clarity (same Google place ID), reuse it — never duplicate. | P0 |

### 9.5 Write a review (a visit)

| ID | Requirement | Priority |
| --- | --- | --- |
| REV-1 | Reviews are only for places you visited. "Would you recommend it?" Yes / No (No shows as *Not recommended*). "Want to go" is a save, not a review (PLC-4). | P0 |
| REV-2 | Rating 1–5, required. | P0 |
| REV-3 | **"One thing to know"** — required one-line tip. | P0 |
| REV-4 | Optional longer review text. | P0 |
| REV-5 | Up to 5 photos from the camera roll or camera. | P0 |
| REV-6 | Date visited (defaults to today) and who you went with (friends, family, solo). | P0 |
| REV-7 | Quick tags (built-in set) plus **custom tags** typed by the reviewer — up to 10, 24 characters each. | P0 |
| REV-9 | **Budget per person** in ₹ (whole rupees, 0 = free). The ₹–₹₹₹₹ level is derived: under ₹250 · under ₹750 · under ₹2,000 · above. | P0 |
| REV-8 | Edit and delete your own visits. Logging the same place again creates a new visit (revisit), not an overwrite. | P0 |

### 9.6 Your map and list

| ID | Requirement | Priority |
| --- | --- | --- |
| MAP-1 | Native map of all your pins, colour-coded by category. | P0 |
| MAP-2 | List view of the same places. | P0 |
| MAP-3 | Filter by category, city, rating, year. | P0 |
| MAP-4 | Pins cluster when zoomed out. | P1 |
| MAP-5 | Empty state for new users guides them to add their first place. | P0 |

### 9.7 Place detail

| ID | Requirement | Priority |
| --- | --- | --- |
| PLC-1 | Photos, your visit(s) and tip, address, category. | P0 |
| PLC-2 | **Who's been here:** friends who visited and what they said. | P0 |
| PLC-3 | Friend rating: the average of friends' scores, never the public score. | P1 |
| PLC-4 | Save to Want to go in one tap. | P0 |
| PLC-5 | Empty state when no friend has reviewed the place. | P0 |

### 9.8 Friends and feed

| ID | Requirement | Priority |
| --- | --- | --- |
| FRD-1 | Send, accept, decline and cancel friend requests; remove friends. | P0 |
| FRD-2 | Friend profile: their map, list, stats and taste match (taste match is Phase 3; show placeholder or hide). | P0 |
| FEED-1 | Chronological feed of friends' visits ("Rahul visited Dzükou Valley, 5/5"), asks and new lists. No ranking algorithm. | P0 |
| FEED-2 | Like a post; tap through to the place or the friend. | P1 |
| FEED-3 | Loading, error and empty states. | P0 |

### 9.9 Search

| ID | Requirement | Priority |
| --- | --- | --- |
| SRCH-1 | Search across your places, friends' places and people by name. | P0 |
| SRCH-2 | Recent searches and suggestions. | P2 |

### 9.10 Share

| ID | Requirement | Priority |
| --- | --- | --- |
| SHR-1 | Share sheet: send your map, a place or a list to WhatsApp, Instagram, or copy link. | P0 |
| SHR-2 | Links open in the app if installed (Universal Links), otherwise on a simple web page with the map/place and a "Get the app" button. | P1 (web page) |
| SHR-3 | Shared links respect privacy settings: a private profile's link shows nothing beyond the name. | P0 |

### 9.11 Collaborative lists

| ID | Requirement | Priority |
| --- | --- | --- |
| LST-1 | Create a list ("Agartala food crawl"), invite friends, everyone adds places. | P1 |
| LST-2 | Members see who added what and each place's status. | P1 |

### 9.12 Notifications

| ID | Requirement | Priority |
| --- | --- | --- |
| NTF-1 | In-app notifications: contact joined, friend request, like, thanks, list invite, nudge. | P0 |
| NTF-2 | Mark all as read; unread badge. | P0 |
| NTF-3 | Push notifications (APNs). | P2 (Phase 2) |

### 9.13 Privacy controls and account

| ID | Requirement | Priority |
| --- | --- | --- |
| PRV-1 | Profile visibility: **Public**, **Friends only (default)**, **Private**. | P0 |
| PRV-2 | Hide individual pins (home, workplace) from everyone else. | P0 |
| PRV-3 | "Let people who have my number find me" toggle (CON-8). | P0 |
| PRV-4 | Delete account and all data from Settings, in-app (App Store and DPDP requirement). | P0 |
| PRV-5 | Export my data. | P2 |
| PRV-6 | Privacy policy and terms linked from onboarding and Settings. | P0 |

### 9.14 System states

| ID | Requirement | Priority |
| --- | --- | --- |
| SYS-1 | Offline screen/banner; cached map stays viewable. | P0 |
| SYS-2 | Every data screen has loading, error-with-retry, and empty states. | P0 |

### 9.15 Badges and milestones

Badges reward **exploring different kinds of places, honest reviews and
helping friends — never posting more.** No daily streaks, countdowns, lost
progress or public leaderboards; friends see your badges, nobody is ranked.
Design: canvas *Clarity — App Screens*, boards 26–35.

| ID | Requirement | Priority |
| --- | --- | --- |
| BDG-1 | A fixed catalogue of 27 badges in 7 groups (table below). Each has a title, a one-sentence "how to earn it", an icon, a colour and 1–3 levels with thresholds. | P0 |
| BDG-2 | The **database awards badges** (triggers on visits, lists, friendships and map sharing), so they can't be faked from the app. The app predicts unlocks from the same rules to celebrate instantly; the server's record wins on reload. | P0 |
| BDG-3 | **Progress never goes backwards.** Deleting a review or a list doesn't take a badge or a level away. | P0 |
| BDG-4 | Five states: earned, newly earned, in progress (mint arc + "3/5"), locked (dashed outline), secret ("?" until earned). Levels I / II / III shown by the ring (thin → double → mint) and a numeral pill. | P0 |
| BDG-5 | **Unlock celebration** right after the action that earned it: full-screen, the badge drops into the glass circle, the mint ring fills, light confetti, a soft haptic. Says what counted ("Your map starts with one place: Neermahal.") and the next badge. *Keep exploring* / *Share badge*. Level-up and two-at-once variants; never more than two at once — a third waits for the next action. Reduce Motion: cross-fades only. | P0 |
| BDG-6 | **Progress toast** after posting a review that earned nothing: "2 more viewpoints to *Viewpoint chaser*". 4 s, never blocks, tap opens the badge. At most one per post. | P0 |
| BDG-7 | **Profile:** "Your next badge" (closest by percentage, with the exact thing to do), a row of badges (earned first), "N of 24", *See all badges*. | P0 |
| BDG-8 | **All badges** screen grouped by kind, filters All / Earned / In progress. For new users *Getting started* is a checklist; everything else stays visible but greyed. | P0 |
| BDG-9 | **Badge detail** sheet: how to earn it, the level track with thresholds, your progress, the places that counted, date earned, friends who have it (never ranked), *Share badge*. | P0 |
| BDG-10 | **Get started checklist** (Add your first place · Write one thing to know · Add a friend · Make a list · Share your map), each step unlocking a starter badge. Shows on the empty map and Profile until all five are done. | P0 |
| BDG-11 | **Friend's badges** on their profile: a recently earned badge (last 14 days) with one *Congrats* reaction, "Badges you share", and their badges. Congrats are stored; no counts or comparison. | P1 |
| BDG-12 | **Share card** for a badge, square or Story (9:16), drawn as the emblem or a passport stamp: the badge, "Bodhi is now *Trekker II*", the places that counted and the map link. *Share image* exports it at 1080 px wide to the system share sheet; *Copy* copies the link. | P1 |
| BDG-13 | **Badges in the friends feed** ("Rahul earned *Trekker I*", with Congrats instead of a like) — new badges and levels only, never the starter badges or ones backfilled/seeded. **Passport stamps** (title and the place · month curved around the badge) on the badge detail sheet and share cards; the emblem everywhere else. **"Thanks, went there!"** on a friend's review of a place you went to after them, which notifies them and counts toward Trusted voice. | P1 |

| Group | Badge (id) | Earned by | Levels |
| --- | --- | --- | --- |
| Getting started | First pin (`first_pin`) | Reviewing your first place | 1 |
| | One-thing writer (`one_thing`) | Your first "One thing to know" | 1 |
| | First friend (`first_friend`) | Your first accepted friend | 1 |
| | List maker (`list_maker`) | Making your first list | 1 |
| | Map sharer (`map_sharer`) | Sharing your map link | 1 |
| Explorer | Places (`places`) | Different places reviewed | 10 / 25 / 50 |
| | Cities (`cities`) | Different cities | 3 / 10 / 25 |
| | States (`states`) | Different Indian states | 3 / 10 / 20 |
| | Seven Sisters (`seven_sisters`) | All 8 North-East states (incl. Sikkim) | 8 |
| Specialists | Café hopper, Food trail, Trekker, Temple trail, Viewpoint chaser, Beach bum, Homestay hopper (`cafe_hopper` … `homestay_hopper`) | Different places in that category (Café, Food, Trek, Temple, Viewpoint, Beach, Stay) | 3 / 10 / 25 |
| Honest voice | Straight talker (`straight_talker`) | Your first honest *Not recommended* | 1 |
| | Tip master (`tip_master`) | Friends saved 10 places you reviewed | 10 |
| Together | Taste twin (`taste_twin`) | 80%+ taste match with a friend | 80 |
| | Squad explorer (`squad_explorer`) | A list with 3 or more friends | 3 |
| | Regular (`regular`) | 3 visits to the same place | 3 |
| Seasons | Monsoon wanderer (`monsoon_wanderer`) | 3 visits in June–September | 3 |
| | Winter hills (`winter_hills`) | 3 treks or viewpoints in December–February | 3 |
| Explorer | Been there (`been_there`) | Different places with a GPS- or photo-verified visit | 1 / 10 / 50 |
| Honest voice | Trusted voice (`trusted_voice`) | 5 friends said "Thanks, went there!" on your reviews | 5 |
| Seasons | Festival lights (`festival_lights`) | A visit during a festival (Holi, Bihu, Durga Puja, Diwali, Hornbill, Christmas; calendar in `public.festivals`) | 1 |
| Secret | Hidden gem (`hidden_gem`) | Reviewing a place before any of your friends, who then go too | 1 |

## 10. Non-functional requirements

| Area | Requirement |
| --- | --- |
| **Performance** | Cold start to map < 2 s on iPhone 12 or newer. Map pans at 60 fps with 500 pins. Feed first page < 1 s on 4G. |
| **Offline** | Your own map and visits are readable offline; writes made offline sync later (Phase 2 for full offline mode). |
| **Reliability** | No data loss on a failed upload: photo uploads retry; a review saves even if photos are still uploading. |
| **Privacy** | DPDP Act: explicit consent, purpose limitation, deletion on request, clear policy. Apple guidelines: no uploading contacts for unrelated purposes; no profiles of non-users. Permissions asked at the moment of use with an explainer. |
| **Security** | Row-level security on every table; only the publishable key in the app; secrets server-side only; TLS everywhere. See `ARCHITECTURE.md` §9. |
| **Accessibility** | Dynamic Type up to XXL without clipped text; VoiceOver labels on all controls; 44 pt touch targets; colour is never the only signal (pin categories also have icons/labels). |
| **Localisation** | English first. Rupee formatting, Indian phone formats, dates as "12 Mar 2026". Strings centralised for Hindi/Bengali later. |
| **Compatibility** | iOS 16+ (to confirm), iPhone only, portrait. |
| **Cost** | ₹0 running cost until real users: Supabase free plan, Google Maps within free quotas, SMS test numbers during development. |
| **Quality** | CI must pass (format, analyze with zero issues, tests, iOS build) before any merge. Every screen has a render test. |

## 11. Privacy and data handling

| Data | Collected? | Stored? | Visible to |
| --- | --- | --- | --- |
| Your phone number | Yes (verified via OTP) | Yes, in Supabase Auth | Nobody else; used only for matching (CON-3) |
| Contacts' numbers | Read on device after consent | **No** — matched in memory, discarded | Nobody |
| Name, username, avatar | Yes | Yes | Per profile visibility |
| Visits, ratings, tips, photos | Yes | Yes | Per profile visibility; hidden pins only to you |
| Precise location | Only when you tap "I'm here" or verify a visit | Only the place coordinates / a verified flag, not a location history | — |
| Photo EXIF | Read on device to verify a visit | Location/time stripped from uploaded photos | — |

**Deletion:** deleting the account removes the profile, visits, photos, list
memberships and friendships within 30 days, including backups' retention
window.

## 12. Monetisation (not before weekly use)

| Model | How it works | Rule |
| --- | --- | --- |
| Freemium (Pro) | Free core; Pro unlocks AI trip planner, year recap export, offline maps, unlimited photos | **Never cap the number of places** |
| Printed books | A year or trip as a printed photo book | Needs a print partner |
| Business pages | Places claim their page, reply, see visit stats | **Never pay to rank higher** |
| Affiliate bookings | "Book a stay" on hotels/hostels | Clearly labelled |
| Creator guides | Popular reviewers sell city guides | Later stage only |

In-app subscriptions must use Apple in-app purchase (15% commission under the
Small Business Program).

## 13. Success metrics and analytics

| Metric | Target for the Phase 1 gate |
| --- | --- |
| Weekly active users | 20 friends, 4 weeks running |
| Visits logged per active user per week | ≥ 1 |
| Contact-sync opt-in at "Find friends" | ≥ 70% |
| Users who open a friend's map in week 1 | ≥ 60% |
| Share links sent per active user per month | ≥ 1 |
| Crash-free sessions | ≥ 99.5% |

**Events to track** (analytics tool is a later decision; nothing is added
without asking): `sign_up_completed`, `contacts_permission_result`,
`friend_request_sent/accepted`, `place_added` (source: search / here / pin),
`visit_saved` (status, has_photos, verified), `friend_map_opened`,
`share_link_created` (type), `share_link_opened`, `list_created`,
`feed_viewed`.

## 14. Release plan

| Milestone | Contents | Exit criteria |
| --- | --- | --- |
| M0 · UI complete | All 24 screens on mock data, CI/CD, branch protection | ✅ Done |
| M1 · Backend foundation | Config, Supabase client, schema + RLS, auth (test numbers) | Sign up → empty map against staging |
| M2 · Core loop | Add place (Places search, I'm here, pin), visits, photos, real map | Log 10 real places end to end |
| M3 · Social | Contact sync, friends, feed, place "who's been here", share links | Two real accounts see each other's maps |
| M4 · TestFlight | Apple Developer account, Sign in with Apple, privacy policy, real SMS + DLT | 20 friends installed |
| M5 · Phase 2 | See §7 | Public App Store launch |

## 15. Costs (first year, approximate)

| Item | When | Cost |
| --- | --- | --- |
| Apple Developer Program | Before TestFlight | $99/year (~₹8,700) |
| Domain | Before App Store submission | ~₹700–1,200/year |
| Supabase | Free until public launch; Pro for prod after | $25/month (~₹2,200) |
| Google Maps Platform | Card from day 1; free within quotas up to ~3,000 users | ₹0 early |
| Phone OTP SMS | From first real sign-up | ~₹0.15–0.25 per OTP (MSG91) |
| Privacy policy review | Before App Store submission | ~₹5,000–15,000 |

**Lean first year:** ~₹12,000–20,000. **Comfortable** (Supabase Pro, AI,
lawyer-checked policy): ~₹65,000–80,000.

## 16. Risks and mitigations

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Cold start: friends aren't on the app | Empty feed, no reason to return | The map is useful alone (memory, sharing); invites via WhatsApp; seed with one tight group first |
| App Review rejects contact use | Launch blocked | Specific `NSContactsUsageDescription`, consent screen, match-and-discard, permission at point of use |
| DLT registration delays SMS | Can't onboard real users | Start DLT early; Twilio Verify as a fallback; test numbers until then |
| Google Places costs grow | Unexpected bill | Cache by place ID, field masks, session tokens, quota caps and budget alerts |
| Supabase free project pauses | Staging down after a quiet week | One-click restore; prod on Pro at launch |
| Spam or fake reviews | Trust erodes | Friends-first visibility; verified visits; explorer level based on verified visits only |
| Privacy incident | Legal and trust damage | RLS everywhere, no non-user data stored, secrets server-side, leak scanning in CI |

## 17. Open questions

- [ ] **Name and domain** — something short that works as a verb ("just check my ___").
- [ ] **First 20 users** — college friends, a travel/biker group, or one city like Agartala?
- [ ] **SMS provider for India** — Twilio Verify (simplest) or MSG91 + DLT via Send SMS Hook (cheaper, local)?
- [ ] **Friends-only, or also public profiles anyone can follow?** (Public visibility exists as a setting; following strangers is undecided.)
- [ ] **Google Places vs Apple Maps search** — Google has better India coverage; Apple is free but thinner in small towns. *Current choice: Google.*
- [ ] **Minimum iOS version.**
- [ ] **When to start Android** — after how many iPhone users?
- [x] Flutter or SwiftUI → **Flutter** (Android later from the same code).
- [x] One Supabase project or two → **one now (staging)**, prod before launch.
- [x] Mac for builds → yes, local Xcode; CI builds on GitHub's macOS runners.
