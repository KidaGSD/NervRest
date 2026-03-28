# CONTINUITY — NervRest iOS App

## [PLANS]

- **2026-03-28T00:00Z** `[USER]` Build NervRest: a native iOS app (SwiftUI + ActivityKit + HealthKit) that detects evening nervous system overstimulation during phone use and guides users to calmer content before sleep. Spec: `NervRest-Xcode-Build-Spec.md`.
- **2026-03-28T00:00Z** `[CODE]` Build priority: Phase 1 (models/protocols/engines) → Phase 2 (Dynamic Island/notifications/scheduler) → Phase 3 (screens/navigation) → Phase 4 (testing/demo).

## [DECISIONS]

- **2026-03-28T00:00Z** `[USER]` Architecture: strict 3-layer (UI/Logic/Data) with protocol-driven data providers and DI via AppContainer. UI is placeholder-only; designer delivers visuals later.
- **2026-03-28T00:00Z** `[USER]` Hackathon mode: use simulated data (WESAD dataset + synthetic generation) instead of real HealthKit/ScreenTime APIs.

## [PROGRESS]

- **2026-03-28T00:00Z** `[CODE]` Project initialized. Spec document placed in repo root. Ready to begin Xcode project creation.

## [DISCOVERIES]

(none yet)

## [OUTCOMES]

(none yet)
