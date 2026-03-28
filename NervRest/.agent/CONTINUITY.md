# NervRest Continuity

## [PROGRESS]
- **2026-03-28T24:30Z** [CODE] RampDownScreen redesigned with rich media cards (3 files):
  - `RampDownSuggestion.swift` — Added `coverImageName: String` and `durationMinutes: Int` properties with manual init (defaults: "headphones", 30).
  - `RampDownViewModel.swift` — Mock data updated: Podcast (headphones), YouTube Longform (play.rectangle.fill), Spotify Lofi (music.note), all 30min.
  - `RampDownScreen.swift` — Replaced old accent-edge card with rich media layout: 80x80 rounded cover art (SF Symbol in accent.secondary), app name + "Xm to calm" caption + play pill ("▶ 30min"), 36pt score ring (trimmed arc, score/10). Added "Or" divider + full-width "Chat with Luna" button in accent.secondary. Gradient card background with 0.5px border preserved. Build succeeded (iPhone 17 Pro Simulator). Committed `203669c`.
- **2026-03-28T23:30Z** [CODE] Luna chat screen redesigned with message bubbles and conversation state (2 files):
  - `LunaChatViewModel.swift` — Added `ChatMessage` struct (Identifiable, with text/isUser/timestamp), `@Published messages: [ChatMessage]` array, `sendMessage()` method (appends user message, clears input, 1s delayed Luna reply).
  - `LunaChatScreen.swift` — Two-state UI: empty state (centered AgentCharacter + greeting + subtitle + input) vs conversation state (back button "< Chat" in accent.secondary, greeting title top-left, ScrollView of message bubbles with ScrollViewReader auto-scroll, bottom input). User bubbles right-aligned with dusk border fill, Luna bubbles left-aligned with 24pt moon avatar. Input bar uses Capsule shape with send button wired to `sendMessage()`. Build succeeded (only pre-existing RampDownScreen errors). Committed `bb9b2ed`. xcodeproj NOT modified.
- **2026-03-28T23:00Z** [CODE] LunaSplashScreen created: `UI/Screens/LunaSplashScreen.swift` — Full-screen splash with 3-stop linear gradient (black→#171120→#402959), radial glow circle using NervRestTheme.Accent.glow with breathing pulse animation (0.15↔0.3 opacity, 3s easeInOut repeat), moon_waxing_crescent image with spring scale-in (0.5→1.0). Build succeeded (iPhone 17 Pro Simulator). Committed `80db2d4`. xcodeproj NOT modified.
- **2026-03-28T22:00Z** [CODE] Onboarding flow wired into app entry point:
  - `NervRestApp.swift` — Added `@State showOnboarding` (checks `OnboardingViewModel.hasCompletedOnboarding()`), `@StateObject onboardingVM`. Body wraps existing NavigationStack in `if showOnboarding / else` conditional. New `onboardingFlow` computed property switches on `currentStep`: 0→OnboardingSplashScreen, 1→wind-down preferences, 2→content preferences (completes onboarding + animated dismiss). Existing code untouched. Build succeeded (iPhone 17 Pro Simulator). Committed `c11acb7`.
- **2026-03-28T21:30Z** [CODE] Onboarding UI screens created (2 new files):
  - `UI/Screens/OnboardingSplashScreen.swift` — Luna welcome splash with black→dusk purple gradient, moon image spring-in animation, breathing radial glow, auto-advances after 2.5s or on tap.
  - `UI/Screens/OnboardingPreferencesScreen.swift` — Reusable 2-column grid selector with step progress bar, staggered card entrance animations, selection toggle with spring animation, disabled Continue button until minSelections met. Build succeeded (iPhone 17 Pro Simulator). Committed `252e4ca`.
- **2026-03-28T21:00Z** [CODE] Onboarding system foundation created (2 new files):
  - `Data/Models/UserPreferences.swift` — Codable struct with `windDownMethods`/`contentInterests` (Set<String>), `hasCompletedOnboarding` flag, static option arrays, `.empty` factory.
  - `Logic/ViewModels/OnboardingViewModel.swift` — ObservableObject with 3-step onboarding (welcome→windDown→content), min 3 selections per step, `completeOnboarding()` persists to UserDefaults, `hasCompletedOnboarding()` static check. Added `import Combine` alongside `import SwiftUI` to match project convention. Build succeeded (iPhone 17 Pro Simulator). Committed `ef6174e`.
- **2026-03-28T19:00Z** [CODE] Demo flow orchestration wired up (5 files changed):
  - Created `UI/Screens/DemoFlowScreen.swift` — master demo screen orchestrating TikTok→ShieldTransition→ShieldOverlay→RampDown→Recovery. DemoPhase enum (Equatable) drives ZStack switching with animations. arousalScore >= 80 triggers transition chain (dimming 0s → moonReveal 2s → shieldReady 3.5s → overlay 4.5s). "5 more minutes" resets to TikTok. "Show alternatives" loads mock suggestions and moves to RampDown.
  - Modified `AppRouter.swift` — added `.demoFlow` and `.lunaChat` routes to AppRoute enum.
  - Modified `AppContainer.swift` — added `lunaChatViewModel: LunaChatViewModel` property, instantiated in init().
  - Modified `NervRestApp.swift` — added `.demoFlow` and `.lunaChat` navigation destinations. DemoFlow passes homeViewModel, rampDownViewModel, alarmTime. LunaChat passes lunaChatViewModel.
  - Modified `HomeScreen.swift` — added `@EnvironmentObject var router: AppRouter`, "Launch Demo" button (starts monitoring + navigates to .demoFlow), "Chat with Luna" button (navigates to .lunaChat). Updated preview with .environmentObject(AppRouter()).
  - xcodeproj NOT modified. Build succeeded (iPhone 17 Pro Simulator).
- **2026-03-28T17:00Z** [CODE] Widget Extension target files created in `NervRestWidgetExtension/`. 5 Swift files: `NervRestLiveActivityBundle.swift` (@main entry point), `NervRestLiveActivityWidget.swift` (ActivityConfiguration with lock screen + Dynamic Island views), `SharedTypes.swift` (duplicated NervRestActivityAttributes + Color hex extension), `IslandViews.swift` (compact leading/trailing/minimal views). Plus `Info.plist`, `Assets.xcassets/Contents.json`, and copied `MoonPhases/` SVG assets. Committed `7e08427`. xcodeproj NOT modified — requires manual Xcode target setup.
- **2026-03-28T14:41Z** [CODE] TikTok mock screen created (2 new files + assets):
  - `UI/TikTokMock/VideoFeedView.swift` — Adapted from open-source ShortVideoApp. Contains `MockVideo` model, `VideoCarouselView` (vertical paging via rotated TabView, auto-play/loop, social sidebar with like/comment/share/bookmark, caption overlay), `VideoPlayerRepresentable` (AVPlayerViewController wrapper), `VideoCarouselWrapper` convenience view. Uses GeometryReader (no deprecated UIScreen.main.bounds), modern onChange. 4 videos only.
  - `UI/Screens/TikTokMockScreen.swift` — Full-screen ZStack: VideoCarouselWrapper + biometric overlay (HR pill, arousal score pill, HRV pill). Uses Color(hex:) from existing extension. Arousal color thresholds 0-100 scale.
  - Copied 4 video files (video-1/5/8/9.mp4) to `Resources/Videos/`.
  - Copied 6 image assets (home-white, comment-white, profile-white, search-white, image-profile-1, Hot-linear-button-1) to Assets.xcassets.
  - xcodeproj NOT modified. Build succeeded (iPhone 17 Pro Simulator).
- **2026-03-28T14:40Z** [CODE] ShieldTransitionView created: `UI/Screens/ShieldTransitionView.swift` — 3-phase cinematic overlay (dimming/moonReveal/shieldReady) with theater-light dimming (multi-layer vignette + curtain gradient), spring-animated AgentCharacter("worried", 120) entrance with vertical float, dual-layer breathing radial glow (outer atmospheric + inner warm ember), phase-driven opacity/vignette progression. Parent controls phase via `@Binding var phase: TransitionPhase`. Includes `resetState()` for replay. Build succeeded (iPhone 17 Pro Simulator). xcodeproj NOT modified.
- **2026-03-28T14:39Z** [CODE] Luna Chat greeting screen created (2 files):
  - `Logic/ViewModels/LunaChatViewModel.swift` — ObservableObject with time-based greeting ("Good Morning/Afternoon/Evening/Night, {userName}"), staggered animation triggers (showGreeting at 0.6s, showInput at 1.2s).
  - `UI/Screens/LunaChatScreen.swift` — Dark dusk background with subtle radial glow, AgentCharacter("happy", 80) springs in, greeting+subtitle fade in, frosted-glass chat input bar slides up from bottom with "Chat with Luna" placeholder. All styling via NervRestTheme. Includes SwiftUI Preview. Build succeeded (iPhone 17 Pro Simulator). xcodeproj NOT modified.
- **2026-03-29T06:36Z** [CODE] Glassmorphism BiometricCard: replaced `.fill(NervRestTheme.Surface.cardBackground)` with `.fill(.ultraThinMaterial).environment(\.colorScheme, .dark)`, reduced border stroke to `opacity(0.4), lineWidth: 0.5`. Build succeeded (iPhone 17 Pro Simulator). Committed `bfb9fbd`.
- **2026-03-28T24:00Z** [CODE] Glassmorphism comparison card on MismatchDetailScreen: `.fill(NervRestTheme.Surface.cardBackground)` → `.fill(.ultraThinMaterial).environment(\.colorScheme, .dark)`; stroke opacity reduced to 0.4, lineWidth to 0.5. Only comparisonCard changed; currentAppSection, reasonSection, windDownButton untouched. Build succeeded. Committed `2221575`.
- **2026-03-28T23:55Z** [CODE] HomeScreen visual polish: Replaced single radial gradient background with 3-layer gradient system (accent glow top-right, status-color radial center, linear fade bottom). Replaced uniform `VStack(spacing: lg)` with `spacing: 0` + per-section padding via `SectionSpacing` (dramatic/tight/normal/breathe). Build succeeded. Committed `0d68dbe`.
- **2026-03-28T23:45Z** [CODE] Typography update: Switched 6 font definitions from SF Rounded (`.rounded`) to SF Pro (`.default`) in `NervRestTheme.Fonts`; kept `score` font as `.rounded`. Added `SectionSpacing` enum (tight/normal/breathe/dramatic) after `Spacing` enum. Build succeeded (iPhone 17 Pro Simulator). Committed `4366eb9`.
- **2026-03-28T23:30Z** [CODE] V2 alignment Task 4: ShieldOverlayScreen redesigned to match V2 Figma design.
  - `ShieldOverlayScreen.swift` — replaced AgentCharacter+subtitle pills layout with ArousalGauge hero gauge, alarm info bar (HStack with "Alarm" / time), body text, V2 button styling. Added `alarmTime: String` parameter. `arousalLevel` computed property uses 0-100 thresholds. Kept cinematic entrance animation (curtain drop + content reveal + breathing glow) but simplified from 4 phases to 3. Preview updated to 0-100 scale (score: 87).
  - `NervRestApp.swift` — `.shieldOverlay` case now passes `alarmTime: container.contextProvider.currentContext.alarmTime?.hourMinute ?? "7:00 AM"` to ShieldOverlayScreen. `contextProvider` is public `let` on AppContainer, no access change needed.
  - Build succeeded (iPhone 17 Pro Simulator).
- **2026-03-28T23:00Z** [CODE] V2 alignment Tasks 1+2: Scoring scale changed from 1-10 to 0-100 and biometric weights fixed across 5 files.
  - `ArousalScore.swift` — level thresholds updated to 0-100 (0/<30/<50/<70/<90), comment updated.
  - `StimulationEngine.swift` — `updateScore()` rewritten: biometric-first scoring (HR 50%, HRV 30%, RR 20%), respiratory rate support, output 0-100. Guard no longer requires app/stim; stim lookup is now optional.
  - `ArousalGauge.swift` — arc progress `/10` → `/100`, score format `"%.1f"` → `"%.0f"`, preview value 6.2 → 62.
  - `IslandCompactTrailing.swift` — format `"%.1f"` → `"%.0f"`, color thresholds to 0-100 scale, preview values updated.
  - `IslandMinimal.swift` — color thresholds to 0-100 scale, preview values updated.
  - Note: `IslandExpandedView.swift` still has `/ 10.0` on line 67 and `ShieldOverlayScreen.swift` has `"%.1f"` on line 138 — both owned by other agents, not touched.
- **2026-03-28T22:22Z** [CODE] Moon mascot integration: Replaced emoji text with moon phase SVG images from asset catalog in AgentCharacter.swift, IslandCompactLeading.swift, IslandExpandedView.swift. Build succeeded (iPhone 17 Simulator). Committed `59cec60`.
- **2026-03-28T16:00Z** [CODE] Task 4 (mechanism refinement): Connected InterventionScheduler phase changes to UI navigation.
  - `AppContainer.swift` — added `@Published var pendingNavigation: AppRoute?`; added Combine sink on `scheduler.$currentPhase` mapping `.strongNudge`→`.mismatchDetail`, `.intervention`→`.shieldOverlay`; wired `rampDownVM.onSuggestionSelected` to `scheduler.userChoseRampDown()`.
  - `RampDownViewModel.swift` — added `onSuggestionSelected` callback and `selectSuggestion(_:)` method.
  - `NervRestApp.swift` — added `.onChange(of: container.pendingNavigation)` to drive `router.navigate(to:)`; added `.onAppear` on `.rampDown` case to call `loadMockSuggestions()`.
- **2026-03-28T15:20Z** [CODE] Task 5 (mechanism refinement): Added notification tap handling to `NervRestApp.swift`.
  - Added `import UserNotifications` and `NotificationDelegate` class (file-level, before `NervRestApp` struct) implementing `UNUserNotificationCenterDelegate` with `didReceive` (routes WIND_DOWN / default tap to `onWindDown` closure) and `willPresent` (shows banner+sound for foreground notifications).
  - Added `@StateObject private var notificationDelegate` property to `NervRestApp`.
  - Wired delegate in `.task` modifier: sets `UNUserNotificationCenter.current().delegate` and `onWindDown` closure to `router.navigate(to: .mismatchDetail)`.
  - Did NOT touch navigation destinations or onChange code (reserved for mech-task4 agent).
- **2026-03-28T15:10Z** [CODE] Task 2 (mechanism refinement): Synced SimulatedAppUsageProvider timeline with biometric playback.
  - `SessionManager.swift` — added `appUsageProvider: SimulatedAppUsageProvider?` property + init param; in `tick()`, computes simulated date (19:00 + tickCount minutes) and calls `appUsageProvider.advanceToEvent(at:)` before `stimEngine.updateScore()`.
  - `AppContainer.swift` — passed `appUsageProvider: app` to SessionManager init.
- **2026-03-28T15:00Z** [CODE] Task 1 (mechanism refinement): Wired InterventionScheduler into SessionManager tick loop.
  - `SessionManager.swift` — added `interventionScheduler` property, init parameter, and `interventionScheduler.evaluate()` call in `tick()`.
  - `AppContainer.swift` — passed `interventionScheduler: scheduler` to SessionManager init.
- **2026-03-28T13:35Z** [CODE] Shield + RampDown intervention screens created (5 files):
  - `Logic/ViewModels/MismatchViewModel.swift` -- HR/HRV comparison state with elevation/depression percentages
  - `Logic/ViewModels/RampDownViewModel.swift` -- 3 mock suggestions + free text input state
  - `UI/Screens/MismatchDetailScreen.swift` -- "Your body isn't resting" detail with comparison card, StimScoreBadge, reason banner
  - `UI/Screens/RampDownScreen.swift` -- "Let's wind down" with 3 suggestion cards (teal accent edge) + free text input
  - `UI/Screens/ShieldOverlayScreen.swift` -- Cinematic full-screen dark overlay with 4-phase entrance animation (curtain->agent spring->content reveal->breathing glow)
- **2026-03-28T14:00Z** [CODE] Home Screen + reusable UI components created (5 files):
  - `UI/Components/ArousalGauge.swift` — Hero circular gauge with animated arc, glow shadow, HR/HRV pills with pulsing heart
  - `UI/Components/BiometricCard.swift` — Glass-morphism card for single biometric metric
  - `UI/Components/StimScoreBadge.swift` — Capsule pill showing app name + colored stim score
  - `Logic/ViewModels/HomeViewModel.swift` — ObservableObject with published state, update(score:reading:app:), session callbacks
  - `UI/Screens/HomeScreen.swift` — Main screen composing all components with night-sky radial gradient background
- **2026-03-28T13:33Z** [CODE] Task 6 complete: Created all 3 manager classes in `Logic/Managers/`.
  - `LiveActivityManager.swift` — wraps ActivityKit Live Activity lifecycle (start/update/end), defines `NervRestActivityAttributes` with `ContentState`.
  - `NotificationManager.swift` — handles UNUserNotification permission, nudge/strong-nudge firing, and category registration.
  - `SessionManager.swift` — ObservableObject orchestrating session state (idle/monitoring/paused), tick-based timer driving `StimulationEngine.updateScore()` and `MismatchDetector.check()`, optional `SimulatedBiometricProvider` playback.

## [DECISIONS]
- **2026-03-28T13:35Z** [CODE] MismatchDetailScreen uses existing `StimScoreBadge` component. ShieldOverlayScreen uses 4-phase staggered animation + breathing radial glow for dramatic cinematic entrance. RampDownScreen cards have 4px teal left-edge accent via inline RoundedRectangle. xcodeproj NOT modified.
- **2026-03-28T14:00Z** [CODE] All UI colors/fonts/spacing sourced from `NervRestTheme`. ArousalGauge uses 270-degree arc (0.75 trim rotated 135deg). Heart pill pulses when HR > 80. HomeScreen uses ScrollView + radial gradient overlay for night-sky glow. xcodeproj NOT modified.
- **2026-03-28T13:33Z** [CODE] xcodeproj not modified per task instructions. Files must be added to Xcode project manually or via future task.

## [OUTCOMES]
- **2026-03-28T15:10Z** [CODE] Dynamic Island Dusk/Ember color update complete across all 4 Island component files. arousalColor switches: #1D9E75→#402959, #4CAF50→#52312F, #EF9F27→#D35200, #D85A30→#842B00, #E24B4A→#E18050. biometricRow: #E24B4A→#D35200, #4CAF50→#402959. actionButton: #1D9E75→#D35200. IslandPreview bg: #0D1117→#171120. Build succeeded (iPhone 17 Simulator). Committed `91dd9de`.
- **2026-03-28T15:00Z** [CODE] Task 3 (demo timing) complete: InterventionScheduler thresholds lowered for 2-min demo. nudgeThreshold 6.0→5.5, strongNudgeThreshold 7.5→7.0, interventionThreshold 8.5→8.0, nudgeCooldownSeconds 300→15s. xcodeproj NOT modified.
- **2026-03-28T14:12Z** [CODE] RampDownScreen color update complete: suggestionCard left accent bar Arousal.calm→Accent.secondary, HR icon color Arousal.calm→Accent.secondary, text field focus border Arousal.calm.opacity(0.5)→Accent.secondary.opacity(0.5), send button Arousal.calm→Accent.primary. Build succeeded (iPhone 17 Simulator). Committed `7092fdd`.
- **2026-03-28T14:10Z** [CODE] HomeScreen color update complete: session button start fill Arousal.calm→Accent.primary, stop fill Arousal.high→Arousal.elevated (+ matching shadows). BiometricCard HR color Arousal.high→Arousal.elevated, HRV color Arousal.calm→Accent.secondary. Build succeeded (iPhone 17 Simulator). Committed `b69ac7f`.
- **2026-03-28T14:07Z** [CODE] Task 1 complete: NervRestTheme.swift palette replaced.
  - Arousal: teal→red replaced with Dusk/Warmth/Ember warm sleep-safe colors.
  - Surfaces: midnight blue-grays replaced with dusk purples (#171120, #281C38, #402959, #1C0508).
  - Text: cool grays replaced with dusk lavender tones (#CFBEDB, #A27DBC, #52312F).
  - New `Accent` enum added (primary=#D35200, secondary=#A27DBC, glow=#F8C8A3).
  - `color(for:)` signatures and switch logic unchanged. Build succeeded (iPhone 17 Simulator).

## [DISCOVERIES]
- **2026-03-29T08:00Z** [TOOL] Deep UI Inspiration Research (Round 2) — Comprehensive cross-platform research across Pinterest, Dribbble, Behance, Mobbin, Oura, WHOOP, Calm, Rise, Kryo/MetaLab. Compiled into detailed design reference with hex values, SwiftUI parameters, and technique-specific breakdowns organized by: Background & Depth, Card & Container Patterns, Typography Hierarchy, Data Visualization, Color Usage, Micro-interactions. Full report in chat history.
- **2026-03-28T17:30Z** [TOOL] UI Premium Design Research completed. Key findings for eliminating "vibe-coded" feel:
  1. Typography: Replace all-SF-Rounded with DM Serif Display (headings) + DM Sans (body), keep .rounded for numeric scores only
  2. Background: Single-color #171120 → multi-layer radial gradient + ~3% opacity noise overlay
  3. Card diversity: Mix full-bleed sections, glassmorphism, floating pills, edge-accented cards (not uniform cards everywhere)
  4. Color shadows: Use ember/dusk colored shadows instead of black shadows for warmth and depth
  5. Layout asymmetry: Vary section spacing (24/40/32 not uniform 24), hero elements get extra breathing room
  6. Dark mode depth: 5-layer elevation system (#0D0A14 → #342648), top-left highlight stroke on cards
  7. Serif dark mode rules: 24pt+ only, medium weight, low-contrast serifs (Lora > Didot), off-white text (#E0E0E0)
  8. Current strengths: Tinted dusk-purple neutrals already better than generic gray; Arousal spectrum is distinctive
  Sources: 24 references from Dev.to, Apple HIG, TypeDrawers, Figma Blog, Medium, etc. Full report in chat.
- **2026-03-28T13:33Z** [CODE] `StimulationEngine`, `MismatchDetector`, and `InterventionScheduler` classes do not yet exist as Swift files in the repo — they are referenced as forward declarations from other tasks. `SessionManager` compiles only once those are implemented.
