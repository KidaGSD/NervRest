# NervRest Mechanism Refinement Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the end-to-end monitoring → detection → intervention → recovery loop actually work as a live demo. Right now the pieces exist but aren't fully wired — the session timer ticks but doesn't advance the simulated app timeline, the InterventionScheduler.evaluate() is never called, notifications don't navigate back into the app, and the shield overlay never triggers.

**Architecture:** Fix the plumbing between SessionManager ↔ InterventionScheduler ↔ UI navigation. Keep 3-layer separation intact.

**Tech Stack:** Swift, SwiftUI, Combine, UserNotifications, ActivityKit

---

## What's Broken / Missing

| Gap | Where | Impact |
|-----|-------|--------|
| SessionManager.tick() doesn't call interventionScheduler.evaluate() | SessionManager.swift:46-49 | Notifications never fire, phases never escalate |
| SessionManager.tick() doesn't advance SimulatedAppUsageProvider | SessionManager.swift:46-49 | currentApp stays on first event forever |
| InterventionScheduler phase changes don't trigger UI navigation | AppContainer.swift | Shield overlay never shows; no auto-nav to mismatch screen |
| Notification tap doesn't navigate to MismatchDetail | NervRestApp.swift | User taps notification, nothing happens |
| RampDownViewModel.loadMockSuggestions() never called from flow | AppContainer.swift | RampDown screen shows empty |
| nudgeCooldownSeconds=300 too long for demo | InterventionScheduler.swift:55 | Can't see escalation in a 2-minute demo |
| No recovery detection — after user picks calm content | InterventionScheduler.swift | Phase stays at intervention forever |

---

## Dependency Graph

```
Task 1 (SessionManager loop fix) ─┐
Task 2 (AppUsage timeline sync)  ──┼──▶ Task 4 (Phase→UI navigation)
Task 3 (Demo timing tuning)  ─────┘         │
                                             ▼
                                    Task 5 (Notification tap handling)
                                             │
                                             ▼
                                    Task 6 (End-to-end smoke test)
```

Tasks 1-3 are parallel. Task 4 depends on 1-3. Task 5 depends on 4. Task 6 is final.

---

## Task 1: Wire InterventionScheduler into SessionManager tick loop

**Files:**
- Modify: `NervRest/NervRest/Logic/Managers/SessionManager.swift`
- Modify: `NervRest/NervRest/AppContainer.swift`

**Problem:** `SessionManager.tick()` calls `stimEngine.updateScore()` and `mismatchDetector.check()` but never calls `interventionScheduler.evaluate()`. The scheduler is completely disconnected.

- [ ] **Step 1: Add interventionScheduler to SessionManager**

In `SessionManager.swift`, add `interventionScheduler` as a dependency:

```swift
private let interventionScheduler: InterventionScheduler

init(stimEngine: StimulationEngine,
     mismatchDetector: MismatchDetector,
     interventionScheduler: InterventionScheduler,
     biometricProvider: SimulatedBiometricProvider? = nil) {
    self.stimEngine = stimEngine
    self.mismatchDetector = mismatchDetector
    self.interventionScheduler = interventionScheduler
    self.biometricProvider = biometricProvider
}
```

- [ ] **Step 2: Call evaluate() in tick()**

```swift
private func tick() {
    tickCount += 1
    elapsedSeconds = Int(Double(tickCount) * tickInterval)
    stimEngine.updateScore()
    mismatchDetector.check()
    interventionScheduler.evaluate()
}
```

- [ ] **Step 3: Update AppContainer to pass interventionScheduler**

In `AppContainer.swift`, change SessionManager init:

```swift
let session = SessionManager(
    stimEngine: stimEngine,
    mismatchDetector: mismatchDet,
    interventionScheduler: scheduler,
    biometricProvider: bio
)
```

- [ ] **Step 4: Verify build**

```bash
cd /Users/huangjunda/Desktop/Resolute/NervRest && xcodebuild build -scheme NervRest -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -allowProvisioningUpdates -quiet 2>&1 | tail -5
```

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "fix: wire InterventionScheduler.evaluate() into SessionManager tick loop"
```

---

## Task 2: Sync SimulatedAppUsageProvider with biometric playback

**Files:**
- Modify: `NervRest/NervRest/Logic/Managers/SessionManager.swift`
- Modify: `NervRest/NervRest/Data/Simulated/SimulatedAppUsageProvider.swift` (if needed)

**Problem:** The biometric provider advances through 150 readings (5 phases), but the app usage provider stays stuck on the first event. The two must advance in sync so that when HR spikes at reading ~90 (TikTok phase), the current app is actually "TikTok".

- [ ] **Step 1: Add appUsageProvider to SessionManager**

```swift
private let appUsageProvider: SimulatedAppUsageProvider?
```

Add to init parameters and store.

- [ ] **Step 2: Advance app timeline in tick()**

Each tick corresponds to ~1 simulated minute (since playbackSpeed=0.5 and tickInterval=2.0). Map tickCount to the evening-timeline minute offset:

```swift
private func tick() {
    tickCount += 1
    elapsedSeconds = Int(Double(tickCount) * tickInterval)

    // Advance app usage to match simulated time
    // Each tick ≈ 1 minute in sim time
    appUsageProvider?.advanceToEvent(at: tickCount)

    stimEngine.updateScore()
    mismatchDetector.check()
    interventionScheduler.evaluate()
}
```

- [ ] **Step 3: Verify advanceToEvent works correctly**

Read `SimulatedAppUsageProvider.swift` to confirm `advanceToEvent(at:)` maps minute offset to the correct timeline event. The evening-timeline is: Instagram(0-20) → Netflix(20-65) → Messaging(65-75) → Twitter(75-90) → TikTok(90-105) → YouTube_longform(105-125) → Podcast(125-150).

- [ ] **Step 4: Update AppContainer to pass appUsageProvider**

```swift
let session = SessionManager(
    stimEngine: stimEngine,
    mismatchDetector: mismatchDet,
    interventionScheduler: scheduler,
    biometricProvider: bio,
    appUsageProvider: app
)
```

- [ ] **Step 5: Verify build + commit**

```bash
git add -A && git commit -m "fix: sync app usage timeline with biometric playback in SessionManager"
```

---

## Task 3: Tune demo timing constants

**Files:**
- Modify: `NervRest/NervRest/Logic/Engines/InterventionScheduler.swift`
- Modify: `NervRest/NervRest/Logic/Managers/SessionManager.swift`

**Problem:** nudgeCooldownSeconds=300 (5 min) means you can't demo escalation. tickInterval=2.0 means 150 ticks = 5 minutes for the full evening — too fast to see, too slow for the cool parts.

- [ ] **Step 1: Reduce nudge cooldown for demo**

In `InterventionScheduler.swift`:

```swift
var nudgeCooldownSeconds: TimeInterval = 15  // 15s for demo (was 300)
```

- [ ] **Step 2: Adjust thresholds for demo drama**

Lower thresholds slightly so escalation happens during the Twitter→TikTok transition (~tick 75-105):

```swift
var nudgeThreshold: Double = 5.5       // was 6.0
var strongNudgeThreshold: Double = 7.0 // was 7.5
var interventionThreshold: Double = 8.0 // was 8.5
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "fix: tune intervention thresholds and cooldown for demo pacing"
```

---

## Task 4: Connect InterventionScheduler phase changes to UI navigation

**Files:**
- Modify: `NervRest/NervRest/AppContainer.swift`
- Modify: `NervRest/NervRest/NervRestApp.swift`

**Problem:** When `interventionScheduler.currentPhase` changes to `.gentleNudge` / `.intervention`, nothing happens in the UI. We need Combine bindings that auto-navigate.

- [ ] **Step 1: Add phase observation in AppContainer**

In `AppContainer.init()`, after the existing Combine bindings, add:

```swift
// Bind intervention phase to navigation
scheduler.$currentPhase
    .receive(on: DispatchQueue.main)
    .sink { [weak self] phase in
        self?.handlePhaseChange(phase)
    }
    .store(in: &cancellables)
```

- [ ] **Step 2: Add handlePhaseChange method**

```swift
@Published var pendingNavigation: AppRoute?

private func handlePhaseChange(_ phase: InterventionScheduler.Phase) {
    switch phase {
    case .gentleNudge:
        // Notification fires via InterventionScheduler — just update VM
        break
    case .strongNudge:
        pendingNavigation = .mismatchDetail
    case .intervention:
        pendingNavigation = .shieldOverlay
    case .recovery:
        pendingNavigation = nil
    case .monitoring:
        break
    }
}
```

- [ ] **Step 3: Observe pendingNavigation in NervRestApp**

In `NervRestApp.swift`, add `.onChange` to the NavigationStack:

```swift
.onChange(of: container.pendingNavigation) { _, route in
    if let route = route {
        router.navigate(to: route)
        container.pendingNavigation = nil
    }
}
```

- [ ] **Step 4: Wire RampDown suggestions when navigating**

When navigating to `.rampDown`, auto-load suggestions:

```swift
case .rampDown:
    RampDownScreen(viewModel: container.rampDownViewModel)
        .onAppear {
            container.rampDownViewModel.loadMockSuggestions()
        }
```

- [ ] **Step 5: Wire recovery — when user taps a suggestion, reset phase**

In AppContainer, add:

```swift
rampDownVM.onSuggestionSelected = { [weak scheduler] in
    scheduler?.userChoseRampDown()
}
```

This requires adding `var onSuggestionSelected: (() -> Void)?` to RampDownViewModel.

- [ ] **Step 6: Verify build + commit**

```bash
git add -A && git commit -m "feat: auto-navigate to mismatch/shield screens on intervention phase escalation"
```

---

## Task 5: Handle notification tap → in-app navigation

**Files:**
- Modify: `NervRest/NervRest/NervRestApp.swift`
- Modify: `NervRest/NervRest/Logic/Managers/NotificationManager.swift`

**Problem:** Notifications fire but tapping them doesn't navigate to the mismatch detail screen.

- [ ] **Step 1: Set UNUserNotificationCenter delegate**

In `NervRestApp.swift`, create a notification delegate:

```swift
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    var onWindDown: (() -> Void)?

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "WIND_DOWN" {
            onWindDown?()
        } else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            onWindDown?()  // tapping the notification itself
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])  // show banner even when app is foreground
    }
}
```

- [ ] **Step 2: Wire delegate in NervRestApp**

```swift
@StateObject private var notificationDelegate = NotificationDelegate()

// In .task:
.task {
    await container.notificationManager.requestPermission()
    container.notificationManager.registerCategories()
    UNUserNotificationCenter.current().delegate = notificationDelegate
    notificationDelegate.onWindDown = { [weak router] in
        router?.navigate(to: .mismatchDetail)
    }
}
```

- [ ] **Step 3: Verify build + commit**

```bash
git add -A && git commit -m "feat: notification tap navigates to mismatch detail screen"
```

---

## Task 6: End-to-end smoke test

**Files:** None (testing only)

- [ ] **Step 1: Run on simulator**

```bash
cd /Users/huangjunda/Desktop/Resolute/NervRest && xcodebuild build -scheme NervRest -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -allowProvisioningUpdates -quiet
```

- [ ] **Step 2: Manual test script**

1. Launch app → see Home Screen with calm state (score ~0, HR 64, HRV 55)
2. Tap "Start Evening Session" → gauge starts updating every 2 seconds
3. Watch ~20 ticks → app shows Instagram, HR ~68, score ~2-3 (calm)
4. ~tick 65-75 → app switches to Twitter, HR rising, score climbing
5. ~tick 75-90 → score hits 5.5+ → **gentle nudge notification** should fire
6. ~tick 85-95 → score hits 7.0+ → **strong nudge** → auto-navigate to Mismatch Detail
7. ~tick 90-105 → TikTok, score hits 8.0+ → **intervention** → auto-navigate to Shield Overlay
8. Tap "Show me alternatives" → navigate to RampDown with 3 suggestions
9. Tap a suggestion → phase resets to recovery, navigate back to home
10. Score should start declining as biometrics enter recovery phase

- [ ] **Step 3: Document any bugs found**

- [ ] **Step 4: Final commit**

```bash
git add -A && git commit -m "test: verify end-to-end monitoring → intervention → recovery flow"
```

---

## Execution Strategy

**Tasks 1-3: parallel** (3 subagents — different files, no overlap)
**Task 4: after 1-3 merge** (1 subagent)
**Task 5: after 4** (1 subagent)
**Task 6: manual testing**
