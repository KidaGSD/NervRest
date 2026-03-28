# NervRest Iteration 1 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a working iOS app that detects nervous system overstimulation during evening phone use and guides users to calmer content — with mock data, placeholder UI, Dynamic Island, and local notifications.

**Architecture:** Three-layer separation (UI / Logic / Data) with protocol-driven data providers and dependency injection via `AppContainer`. All data is mocked for this iteration — simulated biometric readings and hardcoded app stimulation scores. UI uses SwiftUI with a bold design system (dark theme, rounded typography, teal-to-red arousal palette) that the design team can later override.

**Tech Stack:** Swift 5.9+, SwiftUI, ActivityKit (Dynamic Island / Live Activity), UserNotifications, Screen Time (Family Controls / DeviceActivity / ManagedSettings), XCTest

**Spec:** `NervRest-Xcode-Build-Spec.md` (repo root)

**Figma (design team reference):** https://www.figma.com/design/jJFwohnX3LlZfayZ5CBCRu/Resolution-Hacks?node-id=0-1

**Parallelism:** Tasks 1-4 are independent and MUST be dispatched as parallel subagents. Tasks 5-6 depend on 1-4. Tasks 7-9 are independent of each other and can run in parallel after 5-6. Task 10 is the final integration.

---

## Dependency Graph

```
Task 1 (Data Models) ──┐
Task 2 (Protocols)  ───┤
Task 3 (Mock Data)  ───┼──▶ Task 5 (Core Engines) ──┐
Task 4 (Design System)─┘                            │
                                                     ├──▶ Task 10 (Integration + App Entry)
Task 6 (Managers) ───────────────────────────────────┤
                                                     │
Task 7 (Home Screen) ───────────────────────────────┤  (parallel after 5+6)
Task 8 (Mismatch + RampDown Screens) ──────────────┤  (parallel after 5+6)
Task 9 (Dynamic Island + Widget Extension) ─────────┘  (parallel after 5+6)
```

---

## File Structure

```
NervRest/
├── NervRest.xcodeproj/
├── NervRest/
│   ├── App/
│   │   ├── NervRestApp.swift                    ← Task 10
│   │   └── AppContainer.swift                   ← Task 10
│   │
│   ├── Data/
│   │   ├── Models/
│   │   │   ├── BiometricReading.swift            ← Task 1
│   │   │   ├── AppUsageEvent.swift               ← Task 1
│   │   │   ├── ArousalScore.swift                ← Task 1
│   │   │   ├── MismatchEvent.swift               ← Task 1
│   │   │   ├── RampDownSuggestion.swift           ← Task 1
│   │   │   ├── PersonalProfile.swift              ← Task 1
│   │   │   └── UserContext.swift                  ← Task 1
│   │   │
│   │   ├── Providers/
│   │   │   ├── BiometricDataProvider.swift         ← Task 2
│   │   │   ├── AppUsageDataProvider.swift          ← Task 2
│   │   │   ├── ContextDataProvider.swift           ← Task 2
│   │   │   └── StimScoreProvider.swift             ← Task 2
│   │   │
│   │   └── Simulated/
│   │       ├── SimulatedBiometricProvider.swift    ← Task 3
│   │       ├── SimulatedAppUsageProvider.swift     ← Task 3
│   │       ├── RealContextProvider.swift           ← Task 3
│   │       └── StaticStimScoreProvider.swift       ← Task 3
│   │
│   ├── Logic/
│   │   ├── Engines/
│   │   │   ├── StimulationEngine.swift             ← Task 5
│   │   │   ├── MismatchDetector.swift              ← Task 5
│   │   │   ├── RampDownEngine.swift                ← Task 5
│   │   │   └── InterventionScheduler.swift         ← Task 5
│   │   │
│   │   ├── Managers/
│   │   │   ├── LiveActivityManager.swift           ← Task 6
│   │   │   ├── NotificationManager.swift           ← Task 6
│   │   │   └── SessionManager.swift                ← Task 6
│   │   │
│   │   └── ViewModels/
│   │       ├── HomeViewModel.swift                 ← Task 7
│   │       ├── MismatchViewModel.swift             ← Task 8
│   │       └── RampDownViewModel.swift             ← Task 8
│   │
│   ├── UI/
│   │   ├── Theme/
│   │   │   ├── NervRestTheme.swift                 ← Task 4
│   │   │   └── Color+Hex.swift                     ← Task 4
│   │   │
│   │   ├── Components/
│   │   │   ├── ArousalGauge.swift                  ← Task 7
│   │   │   ├── BiometricCard.swift                 ← Task 7
│   │   │   ├── AgentCharacter.swift                ← Task 4
│   │   │   └── StimScoreBadge.swift                ← Task 7
│   │   │
│   │   ├── Screens/
│   │   │   ├── HomeScreen.swift                    ← Task 7
│   │   │   ├── MismatchDetailScreen.swift          ← Task 8
│   │   │   └── RampDownScreen.swift                ← Task 8
│   │   │
│   │   └── Navigation/
│   │       └── AppRouter.swift                     ← Task 10
│   │
│   ├── Resources/
│   │   ├── app-stim-scores.json                   ← Task 3
│   │   └── evening-timeline.json                  ← Task 3
│   │
│   └── Extensions/
│       ├── Date+Formatting.swift                   ← Task 1
│       └── Double+Rounding.swift                   ← Task 1
│
├── NervRestWidgetExtension/                        ← Task 9
│   ├── NervRestLiveActivity.swift
│   ├── NervRestWidgetBundle.swift
│   └── LiveActivityViews/
│       ├── CompactLeadingView.swift
│       ├── CompactTrailingView.swift
│       ├── MinimalView.swift
│       └── ExpandedView.swift
│
└── NervRestTests/
    ├── Models/
    │   └── ModelsTests.swift                       ← Task 1
    ├── Engines/
    │   ├── StimulationEngineTests.swift             ← Task 5
    │   ├── MismatchDetectorTests.swift              ← Task 5
    │   └── RampDownEngineTests.swift                ← Task 5
    └── Providers/
        └── SimulatedProviderTests.swift             ← Task 3
```

---

## Task 1: Data Models + Extensions (PARALLEL — no dependencies)

**Files:**
- Create: `NervRest/Data/Models/BiometricReading.swift`
- Create: `NervRest/Data/Models/AppUsageEvent.swift`
- Create: `NervRest/Data/Models/ArousalScore.swift`
- Create: `NervRest/Data/Models/MismatchEvent.swift`
- Create: `NervRest/Data/Models/RampDownSuggestion.swift`
- Create: `NervRest/Data/Models/PersonalProfile.swift`
- Create: `NervRest/Data/Models/UserContext.swift`
- Create: `NervRest/Extensions/Date+Formatting.swift`
- Create: `NervRest/Extensions/Double+Rounding.swift`
- Test: `NervRestTests/Models/ModelsTests.swift`

**Context:** These are plain value types. Follow the spec exactly (Section 4). All structs should be `Codable` and `Identifiable` where specified. Enums need raw values for serialization.

- [ ] **Step 1: Create the Xcode project skeleton**

Create the Xcode project with `xcodebuild` or manually. The project needs:
- App target: `NervRest` (iOS 17.0+, SwiftUI lifecycle)
- Test target: `NervRestTests`
- Bundle ID: `com.nervrest.app`

```bash
# From repo root, create directory structure
mkdir -p NervRest/NervRest/{App,Data/{Models,Providers,Simulated},Logic/{Engines,Managers,ViewModels},UI/{Theme,Components,Screens,Navigation},Resources,Extensions}
mkdir -p NervRest/NervRestTests/{Models,Engines,Providers}
mkdir -p NervRest/NervRestWidgetExtension/LiveActivityViews
```

- [ ] **Step 2: Write model tests**

Create `NervRestTests/Models/ModelsTests.swift`:

```swift
import XCTest
@testable import NervRest

final class BiometricReadingTests: XCTestCase {
    func testIsElevated_aboveThreshold_returnsTrue() {
        let reading = BiometricReading(
            id: UUID(), timestamp: Date(),
            heartRate: 80, hrvSDNN: 45, respiratoryRate: 14
        )
        XCTAssertTrue(reading.isElevated)
    }

    func testIsElevated_belowThreshold_returnsFalse() {
        let reading = BiometricReading(
            id: UUID(), timestamp: Date(),
            heartRate: 65, hrvSDNN: 55, respiratoryRate: 14
        )
        XCTAssertFalse(reading.isElevated)
    }

    func testCodableRoundTrip() throws {
        let original = BiometricReading(
            id: UUID(), timestamp: Date(),
            heartRate: 72, hrvSDNN: 48, respiratoryRate: 15
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(BiometricReading.self, from: data)
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.heartRate, original.heartRate)
    }
}

final class AppUsageEventTests: XCTestCase {
    func testDuration_withEndTime_calculatesCorrectly() {
        let start = Date()
        let end = start.addingTimeInterval(300) // 5 minutes
        let event = AppUsageEvent(
            id: UUID(), appName: "TikTok",
            appCategory: .socialMedia,
            startTime: start, endTime: end,
            stimulationScore: 8.3
        )
        XCTAssertEqual(event.duration, 300, accuracy: 1)
    }

    func testDuration_withoutEndTime_usesCurrentTime() {
        let start = Date().addingTimeInterval(-120) // 2 min ago
        let event = AppUsageEvent(
            id: UUID(), appName: "Twitter",
            appCategory: .socialMedia,
            startTime: start, endTime: nil,
            stimulationScore: 7.5
        )
        XCTAssertGreaterThan(event.duration, 119)
    }
}

final class ArousalScoreTests: XCTestCase {
    func testLevel_calm() {
        let score = ArousalScore(
            total: 2.0, noveltyComponent: 1, emotionComponent: 1,
            sensoryComponent: 1, interactivityComponent: 1,
            timeMultiplier: 1.0, timestamp: Date()
        )
        XCTAssertEqual(score.level, .calm)
    }

    func testLevel_critical() {
        let score = ArousalScore(
            total: 9.5, noveltyComponent: 9, emotionComponent: 9,
            sensoryComponent: 9, interactivityComponent: 9,
            timeMultiplier: 1.5, timestamp: Date()
        )
        XCTAssertEqual(score.level, .critical)
    }
}

final class MismatchEventTests: XCTestCase {
    func testHRElevationPercent() {
        let ctx = UserContext(
            currentTime: Date(), alarmTime: nil,
            bedtimeStart: nil, motionState: .still,
            isInWindDownWindow: true
        )
        let event = MismatchEvent(
            id: UUID(), timestamp: Date(),
            currentHR: 92, baselineHR: 64,
            currentHRV: 30, baselineHRV: 55,
            currentApp: "TikTok", stimScore: 8.3, context: ctx
        )
        XCTAssertEqual(event.hrElevationPercent, 43.75, accuracy: 0.01)
    }
}

final class UserContextTests: XCTestCase {
    func testMinutesUntilAlarm() {
        let now = Date()
        let alarm = now.addingTimeInterval(7200) // 2 hours
        let ctx = UserContext(
            currentTime: now, alarmTime: alarm,
            bedtimeStart: nil, motionState: .still,
            isInWindDownWindow: false
        )
        XCTAssertEqual(ctx.minutesUntilAlarm, 120)
    }

    func testMinutesUntilAlarm_noAlarm_returnsNil() {
        let ctx = UserContext(
            currentTime: Date(), alarmTime: nil,
            bedtimeStart: nil, motionState: .still,
            isInWindDownWindow: false
        )
        XCTAssertNil(ctx.minutesUntilAlarm)
    }
}
```

- [ ] **Step 3: Run tests — verify they fail**

```bash
cd NervRest && xcodebuild test -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20
```
Expected: FAIL — types not defined

- [ ] **Step 4: Implement all data models**

Create each file per the spec Section 4. Key implementation notes:
- `BiometricReading`: `Codable, Identifiable`, computed `isElevated` (HR > 75)
- `AppUsageEvent`: `Codable, Identifiable`, computed `duration`, `AppCategory` enum with `String` raw value
- `ArousalScore`: computed `level` property returning `ArousalLevel` enum
- `ArousalLevel`: enum with `calm/moderate/elevated/high/critical`, computed `color` string
- `MismatchEvent`: `Identifiable`, computed `hrElevationPercent` and `reason`
- `UserContext`: computed `minutesUntilAlarm`, `MotionState` enum
- `RampDownSuggestion`: `Identifiable`, has `deepLinkURL: URL?`
- `AppBodyResponse` (PersonalProfile): `Codable, Identifiable`

See spec Section 4 for exact field names and types.

- [ ] **Step 5: Implement extensions**

`Date+Formatting.swift`:
```swift
import Foundation

extension Date {
    var shortTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    var hourMinute: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }
}
```

`Double+Rounding.swift`:
```swift
import Foundation

extension Double {
    func rounded(to places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
```

- [ ] **Step 6: Run tests — verify they pass**

```bash
cd NervRest && xcodebuild test -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20
```
Expected: ALL PASS

- [ ] **Step 7: Commit**

```bash
git add NervRest/NervRest/Data/Models/ NervRest/NervRest/Extensions/ NervRest/NervRestTests/Models/
git commit -m "feat: add all data models and extensions with tests"
```

---

## Task 2: Data Provider Protocols (PARALLEL — no dependencies)

**Files:**
- Create: `NervRest/Data/Providers/BiometricDataProvider.swift`
- Create: `NervRest/Data/Providers/AppUsageDataProvider.swift`
- Create: `NervRest/Data/Providers/ContextDataProvider.swift`
- Create: `NervRest/Data/Providers/StimScoreProvider.swift`

**Context:** Pure protocol definitions with associated types. Follow spec Section 5 exactly. These define the contract between data and logic layers. No tests needed — protocols are tested via their conforming types.

- [ ] **Step 1: Implement BiometricDataProvider protocol**

Create `NervRest/Data/Providers/BiometricDataProvider.swift`:

```swift
import Foundation

struct BiometricBaseline {
    let restingHR: Double       // e.g. 64
    let restingHRV: Double      // e.g. 55
    let restingRespiratoryRate: Double?  // e.g. 14
}

protocol BiometricDataProvider {
    var readings: AsyncStream<BiometricReading> { get }
    var latestReading: BiometricReading? { get }
    func readings(from: Date, to: Date) async -> [BiometricReading]
    var baseline: BiometricBaseline { get }
}
```

- [ ] **Step 2: Implement AppUsageDataProvider protocol**

Create `NervRest/Data/Providers/AppUsageDataProvider.swift`:

```swift
import Foundation

protocol AppUsageDataProvider {
    var currentApp: AppUsageEvent? { get }
    var appChanges: AsyncStream<AppUsageEvent> { get }
    func usage(from: Date, to: Date) async -> [AppUsageEvent]
    func switchCount(lastMinutes: Int) -> Int
    var pickupCountToday: Int { get }
}
```

- [ ] **Step 3: Implement ContextDataProvider protocol**

Create `NervRest/Data/Providers/ContextDataProvider.swift`:

```swift
import Foundation

protocol ContextDataProvider {
    var currentContext: UserContext { get }
    var contextChanges: AsyncStream<UserContext> { get }
}
```

- [ ] **Step 4: Implement StimScoreProvider protocol**

Create `NervRest/Data/Providers/StimScoreProvider.swift`:

```swift
import Foundation

struct StimulationBreakdown: Codable {
    let novelty: Double     // 1-10
    let emotion: Double     // 1-10
    let sensory: Double     // 1-10
    let interactivity: Double // 1-10
    let baseScore: Double   // weighted average
}

protocol StimScoreProvider {
    func score(for appName: String) -> StimulationBreakdown?
    var allScores: [String: StimulationBreakdown] { get }
}
```

- [ ] **Step 5: Verify build**

```bash
cd NervRest && xcodebuild build -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10
```
Expected: BUILD SUCCEEDED

- [ ] **Step 6: Commit**

```bash
git add NervRest/NervRest/Data/Providers/
git commit -m "feat: add data provider protocols for biometric, app usage, context, and stim scores"
```

---

## Task 3: Mock Data Providers + JSON Resources (PARALLEL — no dependencies)

**Files:**
- Create: `NervRest/Data/Simulated/SimulatedBiometricProvider.swift`
- Create: `NervRest/Data/Simulated/SimulatedAppUsageProvider.swift`
- Create: `NervRest/Data/Simulated/RealContextProvider.swift`
- Create: `NervRest/Data/Simulated/StaticStimScoreProvider.swift`
- Create: `NervRest/Resources/app-stim-scores.json`
- Create: `NervRest/Resources/evening-timeline.json`
- Test: `NervRestTests/Providers/SimulatedProviderTests.swift`

**Context:** These are the concrete mock implementations that power the hackathon demo. `SimulatedBiometricProvider` generates synthetic biometric data following the evening pattern: calm → rising (social media) → peak (TikTok) → recovery (podcast). Follow spec Sections 9-10.

**Important:** This task depends on Tasks 1 and 2 being complete (needs models and protocols). If running in parallel, ensure the models and protocols are stubbed or this task runs after 1+2.

- [ ] **Step 1: Create `app-stim-scores.json`**

Create `NervRest/Resources/app-stim-scores.json` with exact content from spec Section 10:

```json
{
  "TikTok":           { "novelty": 9, "emotion": 7, "sensory": 9, "interactivity": 8, "baseScore": 8.3 },
  "Twitter":          { "novelty": 8, "emotion": 9, "sensory": 5, "interactivity": 7, "baseScore": 7.5 },
  "Instagram":        { "novelty": 7, "emotion": 6, "sensory": 7, "interactivity": 7, "baseScore": 6.8 },
  "Reddit":           { "novelty": 6, "emotion": 7, "sensory": 4, "interactivity": 6, "baseScore": 5.9 },
  "YouTube":          { "novelty": 5, "emotion": 5, "sensory": 6, "interactivity": 3, "baseScore": 4.8 },
  "Netflix":          { "novelty": 4, "emotion": 7, "sensory": 6, "interactivity": 2, "baseScore": 4.8 },
  "News":             { "novelty": 7, "emotion": 8, "sensory": 4, "interactivity": 5, "baseScore": 6.2 },
  "Messaging":        { "novelty": 5, "emotion": 5, "sensory": 2, "interactivity": 7, "baseScore": 4.9 },
  "YouTube_longform": { "novelty": 3, "emotion": 4, "sensory": 5, "interactivity": 2, "baseScore": 3.4 },
  "Podcast":          { "novelty": 2, "emotion": 4, "sensory": 1, "interactivity": 1, "baseScore": 2.1 },
  "Kindle":           { "novelty": 1, "emotion": 3, "sensory": 1, "interactivity": 2, "baseScore": 1.7 },
  "Spotify_lofi":     { "novelty": 1, "emotion": 1, "sensory": 2, "interactivity": 1, "baseScore": 1.2 },
  "Meditation":       { "novelty": 1, "emotion": 2, "sensory": 2, "interactivity": 2, "baseScore": 1.7 },
  "Yoga":             { "novelty": 1, "emotion": 2, "sensory": 3, "interactivity": 2, "baseScore": 1.9 }
}
```

- [ ] **Step 2: Create `evening-timeline.json`**

Create `NervRest/Resources/evening-timeline.json`:

```json
[
  { "appName": "Instagram", "category": "socialMedia", "startMinute": 0, "durationMinutes": 20 },
  { "appName": "Netflix", "category": "entertainment", "startMinute": 20, "durationMinutes": 45 },
  { "appName": "Messaging", "category": "messaging", "startMinute": 65, "durationMinutes": 10 },
  { "appName": "Twitter", "category": "socialMedia", "startMinute": 75, "durationMinutes": 15 },
  { "appName": "TikTok", "category": "socialMedia", "startMinute": 90, "durationMinutes": 15 },
  { "appName": "YouTube_longform", "category": "entertainment", "startMinute": 105, "durationMinutes": 20 },
  { "appName": "Podcast", "category": "education", "startMinute": 125, "durationMinutes": 25 }
]
```

- [ ] **Step 3: Write provider tests**

Create `NervRestTests/Providers/SimulatedProviderTests.swift`:

```swift
import XCTest
@testable import NervRest

final class StaticStimScoreProviderTests: XCTestCase {
    func testLoadScores_containsTikTok() {
        let provider = StaticStimScoreProvider()
        let score = provider.score(for: "TikTok")
        XCTAssertNotNil(score)
        XCTAssertEqual(score?.baseScore, 8.3)
        XCTAssertEqual(score?.novelty, 9)
    }

    func testLoadScores_unknownApp_returnsNil() {
        let provider = StaticStimScoreProvider()
        XCTAssertNil(provider.score(for: "NonexistentApp"))
    }

    func testAllScores_has14Entries() {
        let provider = StaticStimScoreProvider()
        XCTAssertEqual(provider.allScores.count, 14)
    }
}

final class SimulatedBiometricProviderTests: XCTestCase {
    func testSyntheticEvening_generatesData() {
        let readings = SimulatedBiometricProvider.generateSyntheticEvening()
        XCTAssertEqual(readings.count, 150)
    }

    func testSyntheticEvening_startCalm_endRecovery() {
        let readings = SimulatedBiometricProvider.generateSyntheticEvening()
        // First reading should be calm (HR ~68)
        XCTAssertLessThan(readings[0].heartRate, 75)
        // Peak should be high (around index 90-105)
        let peak = readings[95]
        XCTAssertGreaterThan(peak.heartRate, 80)
        // Last reading should be recovering
        XCTAssertLessThan(readings[149].heartRate, 75)
    }

    func testBaseline_hasReasonableValues() {
        let provider = SimulatedBiometricProvider()
        XCTAssertEqual(provider.baseline.restingHR, 64)
        XCTAssertEqual(provider.baseline.restingHRV, 55)
    }
}

final class SimulatedAppUsageProviderTests: XCTestCase {
    func testLoadTimeline_hasEvents() {
        let provider = SimulatedAppUsageProvider()
        XCTAssertGreaterThan(provider.timeline.count, 0)
    }
}

final class RealContextProviderTests: XCTestCase {
    func testCurrentContext_hasCurrentTime() {
        let provider = RealContextProvider()
        let ctx = provider.currentContext
        let diff = abs(ctx.currentTime.timeIntervalSinceNow)
        XCTAssertLessThan(diff, 2) // within 2 seconds
    }
}
```

- [ ] **Step 4: Run tests — verify they fail**

```bash
cd NervRest && xcodebuild test -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20
```
Expected: FAIL — provider types not defined

- [ ] **Step 5: Implement `StaticStimScoreProvider`**

Create `NervRest/Data/Simulated/StaticStimScoreProvider.swift`:

```swift
import Foundation

class StaticStimScoreProvider: StimScoreProvider {
    private var scores: [String: StimulationBreakdown] = [:]

    var allScores: [String: StimulationBreakdown] { scores }

    init() {
        loadScores()
    }

    func score(for appName: String) -> StimulationBreakdown? {
        scores[appName]
    }

    private func loadScores() {
        guard let url = Bundle.main.url(forResource: "app-stim-scores", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: StimulationBreakdown].self, from: data) else {
            // Fallback hardcoded
            scores = Self.hardcodedScores
            return
        }
        scores = decoded
    }

    static let hardcodedScores: [String: StimulationBreakdown] = [
        "TikTok": StimulationBreakdown(novelty: 9, emotion: 7, sensory: 9, interactivity: 8, baseScore: 8.3),
        "Twitter": StimulationBreakdown(novelty: 8, emotion: 9, sensory: 5, interactivity: 7, baseScore: 7.5),
        "Instagram": StimulationBreakdown(novelty: 7, emotion: 6, sensory: 7, interactivity: 7, baseScore: 6.8),
        "Reddit": StimulationBreakdown(novelty: 6, emotion: 7, sensory: 4, interactivity: 6, baseScore: 5.9),
        "YouTube": StimulationBreakdown(novelty: 5, emotion: 5, sensory: 6, interactivity: 3, baseScore: 4.8),
        "Netflix": StimulationBreakdown(novelty: 4, emotion: 7, sensory: 6, interactivity: 2, baseScore: 4.8),
        "News": StimulationBreakdown(novelty: 7, emotion: 8, sensory: 4, interactivity: 5, baseScore: 6.2),
        "Messaging": StimulationBreakdown(novelty: 5, emotion: 5, sensory: 2, interactivity: 7, baseScore: 4.9),
        "YouTube_longform": StimulationBreakdown(novelty: 3, emotion: 4, sensory: 5, interactivity: 2, baseScore: 3.4),
        "Podcast": StimulationBreakdown(novelty: 2, emotion: 4, sensory: 1, interactivity: 1, baseScore: 2.1),
        "Kindle": StimulationBreakdown(novelty: 1, emotion: 3, sensory: 1, interactivity: 2, baseScore: 1.7),
        "Spotify_lofi": StimulationBreakdown(novelty: 1, emotion: 1, sensory: 2, interactivity: 1, baseScore: 1.2),
        "Meditation": StimulationBreakdown(novelty: 1, emotion: 2, sensory: 2, interactivity: 2, baseScore: 1.7),
        "Yoga": StimulationBreakdown(novelty: 1, emotion: 2, sensory: 3, interactivity: 2, baseScore: 1.9),
    ]
}
```

- [ ] **Step 6: Implement `SimulatedBiometricProvider`**

Create `NervRest/Data/Simulated/SimulatedBiometricProvider.swift` per spec Section 9. Key: implement `generateSyntheticEvening()` static method with the 5-phase evening pattern (calm → Netflix → Twitter doomscroll → TikTok peak → recovery). Include `startPlayback()` / `stopPlayback()` with Timer and configurable `playbackSpeed`.

- [ ] **Step 7: Implement `SimulatedAppUsageProvider`**

Create `NervRest/Data/Simulated/SimulatedAppUsageProvider.swift`:

```swift
import Foundation

class SimulatedAppUsageProvider: AppUsageDataProvider {
    struct TimelineEntry: Codable {
        let appName: String
        let category: String
        let startMinute: Int
        let durationMinutes: Int
    }

    var timeline: [AppUsageEvent] = []
    private var currentIndex = 0
    private let baseDate: Date

    var currentApp: AppUsageEvent? {
        guard currentIndex < timeline.count else { return nil }
        return timeline[currentIndex]
    }

    var appChanges: AsyncStream<AppUsageEvent> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }

    var pickupCountToday: Int { 47 } // mock

    init() {
        baseDate = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!
        loadTimeline()
    }

    func usage(from: Date, to: Date) async -> [AppUsageEvent] { timeline }

    func switchCount(lastMinutes: Int) -> Int {
        min(currentIndex, 3) // mock
    }

    func advanceToEvent(at minuteOffset: Int) {
        currentIndex = timeline.firstIndex { event in
            let eventStart = event.startTime
            let offset = eventStart.timeIntervalSince(baseDate) / 60
            return Int(offset) >= minuteOffset
        } ?? currentIndex
    }

    private func loadTimeline() {
        // Try to load from JSON, fallback to hardcoded
        let entries: [TimelineEntry] = [
            TimelineEntry(appName: "Instagram", category: "socialMedia", startMinute: 0, durationMinutes: 20),
            TimelineEntry(appName: "Netflix", category: "entertainment", startMinute: 20, durationMinutes: 45),
            TimelineEntry(appName: "Messaging", category: "messaging", startMinute: 65, durationMinutes: 10),
            TimelineEntry(appName: "Twitter", category: "socialMedia", startMinute: 75, durationMinutes: 15),
            TimelineEntry(appName: "TikTok", category: "socialMedia", startMinute: 90, durationMinutes: 15),
            TimelineEntry(appName: "YouTube_longform", category: "entertainment", startMinute: 105, durationMinutes: 20),
            TimelineEntry(appName: "Podcast", category: "education", startMinute: 125, durationMinutes: 25),
        ]

        timeline = entries.map { entry in
            let start = baseDate.addingTimeInterval(TimeInterval(entry.startMinute * 60))
            let end = start.addingTimeInterval(TimeInterval(entry.durationMinutes * 60))
            let category = AppCategory(rawValue: entry.category) ?? .other
            let stimScore = StaticStimScoreProvider.hardcodedScores[entry.appName]?.baseScore ?? 5.0
            return AppUsageEvent(
                id: UUID(), appName: entry.appName,
                appCategory: category,
                startTime: start, endTime: end,
                stimulationScore: stimScore
            )
        }
    }
}
```

- [ ] **Step 8: Implement `RealContextProvider`**

Create `NervRest/Data/Simulated/RealContextProvider.swift`:

```swift
import Foundation

class RealContextProvider: ContextDataProvider {
    var currentContext: UserContext {
        let now = Date()
        let alarm = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: now.addingTimeInterval(86400))
        let bedtime = Calendar.current.date(bySettingHour: 22, minute: 30, second: 0, of: now)
        let hour = Calendar.current.component(.hour, from: now)
        let isWindDown = hour >= 21 || hour < 2

        return UserContext(
            currentTime: now,
            alarmTime: alarm,
            bedtimeStart: bedtime,
            motionState: .still,
            isInWindDownWindow: isWindDown
        )
    }

    var contextChanges: AsyncStream<UserContext> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }
}
```

- [ ] **Step 9: Run tests — verify they pass**

```bash
cd NervRest && xcodebuild test -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20
```
Expected: ALL PASS

- [ ] **Step 10: Commit**

```bash
git add NervRest/NervRest/Data/Simulated/ NervRest/NervRest/Resources/ NervRest/NervRestTests/Providers/
git commit -m "feat: add mock data providers with synthetic evening biometric data and app stim scores"
```

---

## Task 4: Design System + Theme + AgentCharacter (PARALLEL — no dependencies)

**Files:**
- Create: `NervRest/UI/Theme/NervRestTheme.swift`
- Create: `NervRest/UI/Theme/Color+Hex.swift`
- Create: `NervRest/UI/Components/AgentCharacter.swift`

**Context:** This defines the visual language of the app. Follow the frontend-design skill principles: choose a BOLD aesthetic direction, not generic AI slop. Direction: **"Midnight Observatory"** — dark background like a night sky, teal-to-red arousal spectrum feels like shifting star temperature, rounded typography for warmth. The designer will override later, but this should look intentional, not placeholder.

**Design direction:**
- **Tone:** Refined dark mode with organic warmth. Think: a calm nighttime observatory instrument panel.
- **Colors:** Deep navy/charcoal backgrounds. Teal (calm) → amber (alert) → coral-red (critical) for arousal states. NOT generic purple gradients.
- **Typography:** SF Rounded (system, but configured with `.rounded` design) — warm, approachable, matches health/wellness tone.
- **Differentiation:** The arousal color spectrum should feel alive — not flat tokens but gradients that breathe.

- [ ] **Step 1: Implement `Color+Hex` extension**

Create `NervRest/UI/Theme/Color+Hex.swift`:

```swift
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

- [ ] **Step 2: Implement `NervRestTheme`**

Create `NervRest/UI/Theme/NervRestTheme.swift`:

```swift
import SwiftUI

enum NervRestTheme {

    // MARK: - Arousal Spectrum (teal → red, like star temperature)
    enum Arousal {
        static let calm = Color(hex: "#1D9E75")         // deep teal
        static let moderate = Color(hex: "#4CAF50")      // forest green
        static let elevated = Color(hex: "#EF9F27")      // warm amber
        static let high = Color(hex: "#D85A30")          // burnt coral
        static let critical = Color(hex: "#E24B4A")      // signal red

        static func color(for level: ArousalLevel) -> Color {
            switch level {
            case .calm: return calm
            case .moderate: return moderate
            case .elevated: return elevated
            case .high: return high
            case .critical: return critical
            }
        }

        static func color(for score: Double) -> Color {
            switch score {
            case ..<3: return calm
            case 3..<5: return moderate
            case 5..<7: return elevated
            case 7..<9: return high
            default: return critical
            }
        }
    }

    // MARK: - Surfaces (Midnight Observatory)
    enum Surface {
        static let background = Color(hex: "#0D1117")       // deep space
        static let cardBackground = Color(hex: "#161B22")    // raised card
        static let cardBorder = Color(hex: "#21262D")        // subtle edge
        static let elevated = Color(hex: "#1C2128")          // modal/sheet
    }

    // MARK: - Text
    enum Text {
        static let primary = Color(hex: "#E6EDF3")           // bright white-blue
        static let secondary = Color(hex: "#8B949E")         // muted
        static let tertiary = Color(hex: "#484F58")          // dimmed
    }

    // MARK: - Typography (SF Rounded — warm, approachable)
    enum Fonts {
        static let displayLarge = Font.system(size: 40, weight: .bold, design: .rounded)
        static let displayMedium = Font.system(size: 28, weight: .bold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 15, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 13, weight: .regular, design: .rounded)
        static let micro = Font.system(size: 11, weight: .medium, design: .rounded)
        static let score = Font.system(size: 56, weight: .heavy, design: .rounded)
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 999
    }
}

// Convenience extension on ArousalLevel
extension ArousalLevel {
    var swiftUIColor: Color {
        NervRestTheme.Arousal.color(for: self)
    }
}
```

- [ ] **Step 3: Implement `AgentCharacter` placeholder**

Create `NervRest/UI/Components/AgentCharacter.swift`:

```swift
import SwiftUI

struct AgentCharacter: View {
    let mood: String  // "happy", "concerned", "worried", "relieved"
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(NervRestTheme.Arousal.color(for: moodLevel).opacity(0.15))
                .frame(width: size * 1.2, height: size * 1.2)
            Text(emoji)
                .font(.system(size: size * 0.7))
        }
    }

    private var emoji: String {
        switch mood {
        case "happy": return "😊"
        case "concerned": return "😐"
        case "worried": return "😟"
        case "relieved": return "😌"
        default: return "🫥"
        }
    }

    private var moodLevel: ArousalLevel {
        switch mood {
        case "happy": return .calm
        case "concerned": return .moderate
        case "worried": return .high
        case "relieved": return .calm
        default: return .moderate
        }
    }
}
```

- [ ] **Step 4: Verify build**

```bash
cd NervRest && xcodebuild build -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10
```
Expected: BUILD SUCCEEDED

- [ ] **Step 5: Commit**

```bash
git add NervRest/NervRest/UI/Theme/ NervRest/NervRest/UI/Components/AgentCharacter.swift
git commit -m "feat: add Midnight Observatory design system — dark theme with teal-to-red arousal spectrum"
```

---

## Task 5: Core Engines (depends on Tasks 1, 2, 3)

**Files:**
- Create: `NervRest/Logic/Engines/StimulationEngine.swift`
- Create: `NervRest/Logic/Engines/MismatchDetector.swift`
- Create: `NervRest/Logic/Engines/RampDownEngine.swift`
- Create: `NervRest/Logic/Engines/InterventionScheduler.swift`
- Test: `NervRestTests/Engines/StimulationEngineTests.swift`
- Test: `NervRestTests/Engines/MismatchDetectorTests.swift`
- Test: `NervRestTests/Engines/RampDownEngineTests.swift`

**Context:** These are the "brains" of the app. Follow spec Sections 6 exactly. `StimulationEngine` computes the arousal score. `MismatchDetector` finds body-vs-intent contradictions. `InterventionScheduler` decides when to nudge/block. `RampDownEngine` generates calm-down suggestions. All take protocol-typed dependencies (not concrete types).

- [ ] **Step 1: Write `StimulationEngine` tests**

Create `NervRestTests/Engines/StimulationEngineTests.swift`:

```swift
import XCTest
@testable import NervRest

// Test double for BiometricDataProvider
class MockBiometricProvider: BiometricDataProvider {
    var readings: AsyncStream<BiometricReading> { AsyncStream { $0.finish() } }
    var latestReading: BiometricReading?
    func readings(from: Date, to: Date) async -> [BiometricReading] { [] }
    var baseline = BiometricBaseline(restingHR: 64, restingHRV: 55, restingRespiratoryRate: 14)
}

class MockAppUsageProvider: AppUsageDataProvider {
    var currentApp: AppUsageEvent?
    var appChanges: AsyncStream<AppUsageEvent> { AsyncStream { $0.finish() } }
    func usage(from: Date, to: Date) async -> [AppUsageEvent] { [] }
    func switchCount(lastMinutes: Int) -> Int { 0 }
    var pickupCountToday: Int { 0 }
}

class MockContextProvider: ContextDataProvider {
    var currentContext = UserContext(
        currentTime: Date(), alarmTime: nil,
        bedtimeStart: nil, motionState: .still,
        isInWindDownWindow: true
    )
    var contextChanges: AsyncStream<UserContext> { AsyncStream { $0.finish() } }
}

final class StimulationEngineTests: XCTestCase {
    var bio: MockBiometricProvider!
    var app: MockAppUsageProvider!
    var ctx: MockContextProvider!
    var stim: StaticStimScoreProvider!
    var engine: StimulationEngine!

    override func setUp() {
        bio = MockBiometricProvider()
        app = MockAppUsageProvider()
        ctx = MockContextProvider()
        stim = StaticStimScoreProvider()
        engine = StimulationEngine(biometrics: bio, appUsage: app, context: ctx, stimScores: stim)
    }

    func testUpdateScore_withTikTok_producesHighScore() {
        bio.latestReading = BiometricReading(
            id: UUID(), timestamp: Date(),
            heartRate: 88, hrvSDNN: 28, respiratoryRate: 17
        )
        app.currentApp = AppUsageEvent(
            id: UUID(), appName: "TikTok", appCategory: .socialMedia,
            startTime: Date().addingTimeInterval(-300), endTime: nil,
            stimulationScore: 8.3
        )

        engine.updateScore()

        XCTAssertNotNil(engine.currentScore)
        XCTAssertGreaterThan(engine.currentScore!.total, 7.0)
    }

    func testUpdateScore_withPodcast_producesLowScore() {
        bio.latestReading = BiometricReading(
            id: UUID(), timestamp: Date(),
            heartRate: 62, hrvSDNN: 58, respiratoryRate: 13
        )
        app.currentApp = AppUsageEvent(
            id: UUID(), appName: "Podcast", appCategory: .education,
            startTime: Date().addingTimeInterval(-300), endTime: nil,
            stimulationScore: 2.1
        )

        engine.updateScore()

        XCTAssertNotNil(engine.currentScore)
        XCTAssertLessThan(engine.currentScore!.total, 4.0)
    }

    func testUpdateScore_withNoData_doesNothing() {
        engine.updateScore()
        XCTAssertNil(engine.currentScore)
    }

    func testTimeMultiplier_evening_isElevated() {
        let evening = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
        let multiplier = StimulationEngine.timeMultiplier(for: evening)
        XCTAssertEqual(multiplier, 1.5)
    }

    func testTimeMultiplier_morning_isNormal() {
        let morning = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
        let multiplier = StimulationEngine.timeMultiplier(for: morning)
        XCTAssertEqual(multiplier, 1.0)
    }

    func testScoreIsCapped_between1And10() {
        bio.latestReading = BiometricReading(
            id: UUID(), timestamp: Date(),
            heartRate: 120, hrvSDNN: 10, respiratoryRate: 22
        )
        app.currentApp = AppUsageEvent(
            id: UUID(), appName: "TikTok", appCategory: .socialMedia,
            startTime: Date(), endTime: nil, stimulationScore: 8.3
        )

        engine.updateScore()

        XCTAssertNotNil(engine.currentScore)
        XCTAssertLessThanOrEqual(engine.currentScore!.total, 10.0)
        XCTAssertGreaterThanOrEqual(engine.currentScore!.total, 1.0)
    }
}
```

- [ ] **Step 2: Run tests — verify they fail**

```bash
cd NervRest && xcodebuild test -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:NervRestTests/StimulationEngineTests 2>&1 | tail -20
```
Expected: FAIL

- [ ] **Step 3: Implement `StimulationEngine`**

Create `NervRest/Logic/Engines/StimulationEngine.swift` exactly per spec Section 6 — `StimulationEngine` class. Key: `@Published var currentScore`, `updateScore()` method, `timeMultiplier(for:)` static method.

- [ ] **Step 4: Run tests — verify they pass**

Expected: ALL PASS

- [ ] **Step 5: Write `MismatchDetector` tests**

Create `NervRestTests/Engines/MismatchDetectorTests.swift`:

```swift
import XCTest
@testable import NervRest

final class MismatchDetectorTests: XCTestCase {
    var bio: MockBiometricProvider!
    var app: MockAppUsageProvider!
    var ctx: MockContextProvider!
    var detector: MismatchDetector!

    override func setUp() {
        bio = MockBiometricProvider()
        app = MockAppUsageProvider()
        ctx = MockContextProvider()
        detector = MismatchDetector(biometrics: bio, appUsage: app, context: ctx)
    }

    func testMismatch_detectedWhenAllConditionsMet() {
        // Still + wind-down + elevated HR + depressed HRV
        ctx.currentContext = UserContext(
            currentTime: Date(), alarmTime: nil,
            bedtimeStart: nil, motionState: .still,
            isInWindDownWindow: true
        )
        bio.latestReading = BiometricReading(
            id: UUID(), timestamp: Date(),
            heartRate: 88, hrvSDNN: 30, respiratoryRate: 17
        )
        // baseline: HR=64, HRV=55
        // HR elevation: (88-64)/64 = 0.375 > 0.15 ✓
        // HRV depression: (55-30)/55 = 0.454 > 0.20 ✓
        app.currentApp = AppUsageEvent(
            id: UUID(), appName: "TikTok", appCategory: .socialMedia,
            startTime: Date(), endTime: nil, stimulationScore: 8.3
        )

        detector.check()
        XCTAssertNotNil(detector.activeMismatch)
    }

    func testNoMismatch_whenNotInWindDown() {
        ctx.currentContext = UserContext(
            currentTime: Date(), alarmTime: nil,
            bedtimeStart: nil, motionState: .still,
            isInWindDownWindow: false  // not in wind-down
        )
        bio.latestReading = BiometricReading(
            id: UUID(), timestamp: Date(),
            heartRate: 88, hrvSDNN: 30, respiratoryRate: 17
        )

        detector.check()
        XCTAssertNil(detector.activeMismatch)
    }

    func testNoMismatch_whenHRNotElevated() {
        ctx.currentContext = UserContext(
            currentTime: Date(), alarmTime: nil,
            bedtimeStart: nil, motionState: .still,
            isInWindDownWindow: true
        )
        bio.latestReading = BiometricReading(
            id: UUID(), timestamp: Date(),
            heartRate: 66, hrvSDNN: 50, respiratoryRate: 14  // calm
        )

        detector.check()
        XCTAssertNil(detector.activeMismatch)
    }
}
```

- [ ] **Step 6: Implement `MismatchDetector`**

Create `NervRest/Logic/Engines/MismatchDetector.swift` per spec Section 6.

- [ ] **Step 7: Run MismatchDetector tests — verify pass**

- [ ] **Step 8: Write `RampDownEngine` tests**

Create `NervRestTests/Engines/RampDownEngineTests.swift`:

```swift
import XCTest
@testable import NervRest

final class RampDownEngineTests: XCTestCase {
    func testGeneratePath_fromHighScore_suggestsCalmerApps() {
        let stim = StaticStimScoreProvider()
        let profile = PersonalProfileBuilder()
        let engine = RampDownEngine(stimScores: stim, profileBuilder: profile)

        let path = engine.generatePath(currentScore: 8.0, currentApp: "TikTok")

        XCTAssertGreaterThan(path.count, 0)
        // Each suggestion should have a lower stim score than the current
        for suggestion in path {
            XCTAssertLessThan(suggestion.toAppStimScore, 8.0)
        }
    }

    func testGeneratePath_fromLowScore_returnsEmptyOrMinimal() {
        let stim = StaticStimScoreProvider()
        let profile = PersonalProfileBuilder()
        let engine = RampDownEngine(stimScores: stim, profileBuilder: profile)

        let path = engine.generatePath(currentScore: 2.0, currentApp: "Kindle")
        // Already calm — few or no suggestions
        XCTAssertLessThanOrEqual(path.count, 1)
    }
}
```

- [ ] **Step 9: Implement `RampDownEngine` and `PersonalProfileBuilder`**

Create `NervRest/Logic/Engines/RampDownEngine.swift` per spec Section 6.

Also create a minimal `PersonalProfileBuilder` (stub — returns nil profiles for now):

```swift
class PersonalProfileBuilder {
    func response(for appName: String) -> AppBodyResponse? {
        nil // stub — will learn from real data later
    }
}
```

- [ ] **Step 10: Implement `InterventionScheduler`**

Create `NervRest/Logic/Engines/InterventionScheduler.swift` per spec Section 6. This depends on `StimulationEngine`, `MismatchDetector`, `NotificationManager`, and `LiveActivityManager`. For now, use protocol references or accept these as init parameters. `NotificationManager` and `LiveActivityManager` will be implemented in Task 6 — use forward declarations or protocols.

**Note to implementer:** You may need to define minimal protocol stubs for `NotificationManager` and `LiveActivityManager` interfaces so this compiles. The full implementations come in Task 6.

- [ ] **Step 11: Run all engine tests — verify pass**

```bash
cd NervRest && xcodebuild test -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:NervRestTests 2>&1 | tail -20
```
Expected: ALL PASS

- [ ] **Step 12: Commit**

```bash
git add NervRest/NervRest/Logic/Engines/ NervRest/NervRestTests/Engines/
git commit -m "feat: add core engines — StimulationEngine, MismatchDetector, RampDownEngine, InterventionScheduler"
```

---

## Task 6: Managers — LiveActivity, Notifications, Session (depends on Tasks 1, 2)

**Files:**
- Create: `NervRest/Logic/Managers/LiveActivityManager.swift`
- Create: `NervRest/Logic/Managers/NotificationManager.swift`
- Create: `NervRest/Logic/Managers/SessionManager.swift`

**Context:** These manage iOS system integrations. `LiveActivityManager` creates/updates the Dynamic Island Live Activity. `NotificationManager` fires local notifications with escalating severity. `SessionManager` tracks the current monitoring session lifecycle (start → monitoring → done). Follow spec Sections 7-8.

- [ ] **Step 1: Implement `NervRestActivityAttributes`**

This struct must be in a file accessible to both the app target and the widget extension. Create in `NervRest/Logic/Managers/LiveActivityManager.swift`:

```swift
import ActivityKit
import Foundation

struct NervRestActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var arousalScore: Double
        var heartRate: Int
        var hrv: Int
        var currentApp: String
        var phase: String        // "monitoring", "elevated", "warning", "critical", "recovering"
        var agentMood: String    // "happy", "concerned", "worried", "relieved"
        var minutesUntilAlarm: Int?
    }

    let sessionStartTime: Date
    let userName: String
}
```

- [ ] **Step 2: Implement `LiveActivityManager`**

Add to the same file:

```swift
class LiveActivityManager: ObservableObject {
    enum ActivityState {
        case idle
        case monitoring(score: ArousalScore)
        case elevated(score: ArousalScore)
        case warning(score: ArousalScore)
        case critical(score: ArousalScore)
        case recovering
    }

    @Published var currentState: ActivityState = .idle
    private var currentActivity: Activity<NervRestActivityAttributes>?

    func startActivity(userName: String) {
        let attributes = NervRestActivityAttributes(
            sessionStartTime: Date(), userName: userName
        )
        let initialState = NervRestActivityAttributes.ContentState(
            arousalScore: 1.0, heartRate: 64, hrv: 55,
            currentApp: "None", phase: "monitoring",
            agentMood: "happy", minutesUntilAlarm: nil
        )

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    func updateState(_ state: ActivityState) {
        currentState = state
        let contentState = makeContentState(from: state)
        Task {
            await currentActivity?.update(
                ActivityContent(state: contentState, staleDate: nil)
            )
        }
    }

    func endActivity() {
        let finalState = NervRestActivityAttributes.ContentState(
            arousalScore: 1.0, heartRate: 64, hrv: 55,
            currentApp: "Done", phase: "monitoring",
            agentMood: "relieved", minutesUntilAlarm: nil
        )
        Task {
            await currentActivity?.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: .default
            )
        }
        currentActivity = nil
    }

    private func makeContentState(from state: ActivityState) -> NervRestActivityAttributes.ContentState {
        switch state {
        case .idle:
            return .init(arousalScore: 1, heartRate: 64, hrv: 55, currentApp: "None",
                        phase: "monitoring", agentMood: "happy", minutesUntilAlarm: nil)
        case .monitoring(let score):
            return .init(arousalScore: score.total, heartRate: 64, hrv: 55,
                        currentApp: "Monitoring", phase: "monitoring",
                        agentMood: "happy", minutesUntilAlarm: nil)
        case .elevated(let score):
            return .init(arousalScore: score.total, heartRate: 78, hrv: 38,
                        currentApp: "Active", phase: "elevated",
                        agentMood: "concerned", minutesUntilAlarm: nil)
        case .warning(let score):
            return .init(arousalScore: score.total, heartRate: 85, hrv: 30,
                        currentApp: "Active", phase: "warning",
                        agentMood: "worried", minutesUntilAlarm: nil)
        case .critical(let score):
            return .init(arousalScore: score.total, heartRate: 90, hrv: 24,
                        currentApp: "Active", phase: "critical",
                        agentMood: "worried", minutesUntilAlarm: nil)
        case .recovering:
            return .init(arousalScore: 3, heartRate: 68, hrv: 48,
                        currentApp: "Recovering", phase: "recovering",
                        agentMood: "relieved", minutesUntilAlarm: nil)
        }
    }
}
```

- [ ] **Step 3: Implement `NotificationManager`**

Create `NervRest/Logic/Managers/NotificationManager.swift` per spec Section 8. Include `requestPermission()`, `fireNudge()`, `fireStrongNudge()`, and `registerCategories()`.

- [ ] **Step 4: Implement `SessionManager`**

Create `NervRest/Logic/Managers/SessionManager.swift`:

```swift
import Foundation
import Combine

class SessionManager: ObservableObject {
    enum State {
        case idle
        case monitoring
        case paused
    }

    @Published var state: State = .idle
    @Published var sessionStartTime: Date?

    private var timer: Timer?
    private let stimEngine: StimulationEngine
    private let mismatchDetector: MismatchDetector
    private let interventionScheduler: InterventionScheduler

    let tickInterval: TimeInterval = 30 // seconds

    init(stimEngine: StimulationEngine,
         mismatchDetector: MismatchDetector,
         interventionScheduler: InterventionScheduler) {
        self.stimEngine = stimEngine
        self.mismatchDetector = mismatchDetector
        self.interventionScheduler = interventionScheduler
    }

    func startSession() {
        state = .monitoring
        sessionStartTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
        tick() // immediate first tick
    }

    func stopSession() {
        state = .idle
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        stimEngine.updateScore()
        mismatchDetector.check()
        interventionScheduler.evaluate()
    }
}
```

- [ ] **Step 5: Verify build**

```bash
cd NervRest && xcodebuild build -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10
```
Expected: BUILD SUCCEEDED

- [ ] **Step 6: Commit**

```bash
git add NervRest/NervRest/Logic/Managers/
git commit -m "feat: add LiveActivityManager, NotificationManager, SessionManager"
```

---

## Task 7: Home Screen + Components (depends on Tasks 4, 5, 6)

**Files:**
- Create: `NervRest/UI/Components/ArousalGauge.swift`
- Create: `NervRest/UI/Components/BiometricCard.swift`
- Create: `NervRest/UI/Components/StimScoreBadge.swift`
- Create: `NervRest/Logic/ViewModels/HomeViewModel.swift`
- Create: `NervRest/UI/Screens/HomeScreen.swift`

**Context:** The main screen of the app. Shows a live arousal gauge, current biometrics, current app with stim score, and agent character. Uses the Midnight Observatory dark theme. Follow frontend-design skill: bold, intentional aesthetics, not generic.

**Design notes (frontend-design skill):**
- The `ArousalGauge` is the hero element — large circular gauge with animated arc and glowing color
- `BiometricCard` shows HR and HRV side-by-side with subtle pulsing animation on the heart icon
- Background should have subtle gradient noise texture, not flat black
- Cards use glass-morphism (frosted glass over dark background)
- Agent character sits at the top as the "narrator"

- [ ] **Step 1: Implement `HomeViewModel`**

Create `NervRest/Logic/ViewModels/HomeViewModel.swift`:

```swift
import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var arousalScore: Double = 0
    @Published var arousalLevel: ArousalLevel = .calm
    @Published var heartRate: Int = 64
    @Published var hrv: Int = 55
    @Published var currentApp: String = "None"
    @Published var currentStimScore: Double = 0
    @Published var agentMood: String = "happy"
    @Published var isMonitoring: Bool = false

    private let sessionManager: SessionManager
    private let stimEngine: StimulationEngine
    private let biometrics: BiometricDataProvider
    private let appUsage: AppUsageDataProvider
    private var cancellables = Set<AnyCancellable>()

    init(sessionManager: SessionManager,
         stimEngine: StimulationEngine,
         biometrics: BiometricDataProvider,
         appUsage: AppUsageDataProvider) {
        self.sessionManager = sessionManager
        self.stimEngine = stimEngine
        self.biometrics = biometrics
        self.appUsage = appUsage
        bindEngine()
    }

    func startMonitoring() {
        sessionManager.startSession()
        isMonitoring = true
    }

    func stopMonitoring() {
        sessionManager.stopSession()
        isMonitoring = false
    }

    private func bindEngine() {
        stimEngine.$currentScore
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] score in
                self?.arousalScore = score.total
                self?.arousalLevel = score.level
                self?.updateBiometrics()
                self?.updateApp()
                self?.updateMood(score: score)
            }
            .store(in: &cancellables)
    }

    private func updateBiometrics() {
        if let reading = biometrics.latestReading {
            heartRate = Int(reading.heartRate)
            hrv = Int(reading.hrvSDNN)
        }
    }

    private func updateApp() {
        if let app = appUsage.currentApp {
            currentApp = app.appName
            currentStimScore = app.stimulationScore
        }
    }

    private func updateMood(score: ArousalScore) {
        switch score.level {
        case .calm: agentMood = "happy"
        case .moderate: agentMood = "happy"
        case .elevated: agentMood = "concerned"
        case .high: agentMood = "worried"
        case .critical: agentMood = "worried"
        }
    }
}
```

- [ ] **Step 2: Implement `ArousalGauge`**

Create `NervRest/UI/Components/ArousalGauge.swift`:

```swift
import SwiftUI

struct ArousalGauge: View {
    let score: Double
    let level: ArousalLevel
    let heartRate: Int
    let hrv: Int

    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(spacing: NervRestTheme.Spacing.md) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(
                        NervRestTheme.Surface.cardBorder,
                        lineWidth: 14
                    )
                    .frame(width: 180, height: 180)

                // Animated arc with glow
                Circle()
                    .trim(from: 0, to: animatedProgress / 10)
                    .stroke(
                        level.swiftUIColor,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: level.swiftUIColor.opacity(0.5), radius: 8)

                // Score display
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", score))
                        .font(NervRestTheme.Fonts.score)
                        .foregroundColor(NervRestTheme.Text.primary)
                    Text(level.rawValue.uppercased())
                        .font(NervRestTheme.Fonts.micro)
                        .foregroundColor(level.swiftUIColor)
                        .tracking(2)
                }
            }

            // Biometric pills
            HStack(spacing: NervRestTheme.Spacing.lg) {
                Label("\(heartRate) bpm", systemImage: "heart.fill")
                    .font(NervRestTheme.Fonts.caption)
                    .foregroundColor(heartRate > 75 ? NervRestTheme.Arousal.high : NervRestTheme.Arousal.calm)
                Label("\(hrv) ms", systemImage: "waveform.path.ecg")
                    .font(NervRestTheme.Fonts.caption)
                    .foregroundColor(hrv < 35 ? NervRestTheme.Arousal.high : NervRestTheme.Arousal.calm)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = score
            }
        }
        .onChange(of: score) { _, newValue in
            withAnimation(.easeInOut(duration: 0.6)) {
                animatedProgress = newValue
            }
        }
    }
}
```

- [ ] **Step 3: Implement `BiometricCard` and `StimScoreBadge`**

`NervRest/UI/Components/BiometricCard.swift`:
```swift
import SwiftUI

struct BiometricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: NervRestTheme.Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(NervRestTheme.Fonts.micro)
                    .foregroundColor(NervRestTheme.Text.tertiary)
                Text(value)
                    .font(NervRestTheme.Fonts.headline)
                    .foregroundColor(NervRestTheme.Text.primary)
            }
            Spacer()
        }
        .padding(NervRestTheme.Spacing.md)
        .background(NervRestTheme.Surface.cardBackground)
        .cornerRadius(NervRestTheme.Radius.md)
        .overlay(
            RoundedRectangle(cornerRadius: NervRestTheme.Radius.md)
                .stroke(NervRestTheme.Surface.cardBorder, lineWidth: 1)
        )
    }
}
```

`NervRest/UI/Components/StimScoreBadge.swift`:
```swift
import SwiftUI

struct StimScoreBadge: View {
    let appName: String
    let score: Double

    var body: some View {
        HStack(spacing: NervRestTheme.Spacing.xs) {
            Text(appName)
                .font(NervRestTheme.Fonts.caption)
                .foregroundColor(NervRestTheme.Text.primary)
            Text(String(format: "%.1f", score))
                .font(NervRestTheme.Fonts.micro)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(NervRestTheme.Arousal.color(for: score))
                .cornerRadius(NervRestTheme.Radius.full)
        }
    }
}
```

- [ ] **Step 4: Implement `HomeScreen`**

Create `NervRest/UI/Screens/HomeScreen.swift`:

```swift
import SwiftUI

struct HomeScreen: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ZStack {
            // Background
            NervRestTheme.Surface.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: NervRestTheme.Spacing.xl) {
                    // Agent character
                    AgentCharacter(mood: viewModel.agentMood, size: 48)
                        .padding(.top, NervRestTheme.Spacing.lg)

                    // Status message
                    Text(statusMessage)
                        .font(NervRestTheme.Fonts.headline)
                        .foregroundColor(NervRestTheme.Text.secondary)

                    // Main gauge
                    ArousalGauge(
                        score: viewModel.arousalScore,
                        level: viewModel.arousalLevel,
                        heartRate: viewModel.heartRate,
                        hrv: viewModel.hrv
                    )

                    // Current app badge
                    if viewModel.currentApp != "None" {
                        StimScoreBadge(
                            appName: viewModel.currentApp,
                            score: viewModel.currentStimScore
                        )
                    }

                    // Biometric cards
                    HStack(spacing: NervRestTheme.Spacing.sm) {
                        BiometricCard(
                            title: "HEART RATE",
                            value: "\(viewModel.heartRate) bpm",
                            icon: "heart.fill",
                            color: viewModel.heartRate > 75
                                ? NervRestTheme.Arousal.high
                                : NervRestTheme.Arousal.calm
                        )
                        BiometricCard(
                            title: "HRV",
                            value: "\(viewModel.hrv) ms",
                            icon: "waveform.path.ecg",
                            color: viewModel.hrv < 35
                                ? NervRestTheme.Arousal.high
                                : NervRestTheme.Arousal.calm
                        )
                    }
                    .padding(.horizontal, NervRestTheme.Spacing.md)

                    // Start/Stop button
                    Button(action: {
                        if viewModel.isMonitoring {
                            viewModel.stopMonitoring()
                        } else {
                            viewModel.startMonitoring()
                        }
                    }) {
                        Text(viewModel.isMonitoring ? "Stop Session" : "Start Evening Session")
                            .font(NervRestTheme.Fonts.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, NervRestTheme.Spacing.md)
                            .background(
                                viewModel.isMonitoring
                                    ? NervRestTheme.Arousal.high
                                    : NervRestTheme.Arousal.calm
                            )
                            .cornerRadius(NervRestTheme.Radius.lg)
                    }
                    .padding(.horizontal, NervRestTheme.Spacing.md)
                }
                .padding(.bottom, NervRestTheme.Spacing.xxl)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var statusMessage: String {
        switch viewModel.arousalLevel {
        case .calm: return "Your nervous system is calm"
        case .moderate: return "Slightly elevated activity"
        case .elevated: return "Stimulation is rising..."
        case .high: return "Your body isn't relaxing"
        case .critical: return "Nervous system activated"
        }
    }
}
```

- [ ] **Step 5: Verify build + preview**

```bash
cd NervRest && xcodebuild build -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10
```
Expected: BUILD SUCCEEDED

- [ ] **Step 6: Commit**

```bash
git add NervRest/NervRest/UI/Components/ NervRest/NervRest/UI/Screens/HomeScreen.swift NervRest/NervRest/Logic/ViewModels/HomeViewModel.swift
git commit -m "feat: add HomeScreen with ArousalGauge, BiometricCard, AgentCharacter — Midnight Observatory theme"
```

---

## Task 8: Mismatch Detail + RampDown Screens (PARALLEL with Task 7, depends on 4, 5)

**Files:**
- Create: `NervRest/Logic/ViewModels/MismatchViewModel.swift`
- Create: `NervRest/Logic/ViewModels/RampDownViewModel.swift`
- Create: `NervRest/UI/Screens/MismatchDetailScreen.swift`
- Create: `NervRest/UI/Screens/RampDownScreen.swift`

**Context:** `MismatchDetailScreen` shows why the app thinks the user's body is overstimulated (HR vs baseline, current app). `RampDownScreen` shows 3 alternatives + free text input. Both are destination screens from notification taps.

- [ ] **Step 1: Implement `MismatchViewModel`**

Create `NervRest/Logic/ViewModels/MismatchViewModel.swift`:

```swift
import Foundation
import Combine

class MismatchViewModel: ObservableObject {
    @Published var mismatch: MismatchEvent?
    @Published var currentScore: ArousalScore?

    private let mismatchDetector: MismatchDetector
    private let stimEngine: StimulationEngine
    private var cancellables = Set<AnyCancellable>()

    init(mismatchDetector: MismatchDetector, stimEngine: StimulationEngine) {
        self.mismatchDetector = mismatchDetector
        self.stimEngine = stimEngine

        mismatchDetector.$activeMismatch
            .receive(on: DispatchQueue.main)
            .assign(to: &$mismatch)

        stimEngine.$currentScore
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentScore)
    }
}
```

- [ ] **Step 2: Implement `MismatchDetailScreen`**

Create `NervRest/UI/Screens/MismatchDetailScreen.swift`:

```swift
import SwiftUI

struct MismatchDetailScreen: View {
    @ObservedObject var viewModel: MismatchViewModel
    let onWindDown: () -> Void

    var body: some View {
        ZStack {
            NervRestTheme.Surface.background.ignoresSafeArea()

            VStack(spacing: NervRestTheme.Spacing.xl) {
                AgentCharacter(mood: "worried", size: 56)

                Text("Your body isn't resting")
                    .font(NervRestTheme.Fonts.displayMedium)
                    .foregroundColor(NervRestTheme.Text.primary)

                if let m = viewModel.mismatch {
                    // HR comparison
                    VStack(spacing: NervRestTheme.Spacing.md) {
                        comparisonRow(
                            label: "Heart Rate",
                            current: "\(Int(m.currentHR)) bpm",
                            baseline: "\(Int(m.baselineHR)) bpm",
                            elevation: "+\(Int(m.hrElevationPercent))%",
                            isElevated: true
                        )
                        comparisonRow(
                            label: "HRV",
                            current: "\(Int(m.currentHRV)) ms",
                            baseline: "\(Int(m.baselineHRV)) ms",
                            elevation: "-\(Int((m.baselineHRV - m.currentHRV) / m.baselineHRV * 100))%",
                            isElevated: true
                        )
                    }
                    .padding(NervRestTheme.Spacing.md)
                    .background(NervRestTheme.Surface.cardBackground)
                    .cornerRadius(NervRestTheme.Radius.lg)

                    // Reason
                    Text(m.reason)
                        .font(NervRestTheme.Fonts.body)
                        .foregroundColor(NervRestTheme.Text.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, NervRestTheme.Spacing.lg)

                    // Current app
                    StimScoreBadge(appName: m.currentApp, score: m.stimScore)
                }

                Spacer()

                Button(action: onWindDown) {
                    Text("Show me alternatives")
                        .font(NervRestTheme.Fonts.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, NervRestTheme.Spacing.md)
                        .background(NervRestTheme.Arousal.calm)
                        .cornerRadius(NervRestTheme.Radius.lg)
                }
                .padding(.horizontal, NervRestTheme.Spacing.md)
            }
            .padding(.vertical, NervRestTheme.Spacing.xl)
        }
        .preferredColorScheme(.dark)
    }

    private func comparisonRow(label: String, current: String, baseline: String, elevation: String, isElevated: Bool) -> some View {
        HStack {
            Text(label)
                .font(NervRestTheme.Fonts.caption)
                .foregroundColor(NervRestTheme.Text.tertiary)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(current)
                    .font(NervRestTheme.Fonts.headline)
                    .foregroundColor(isElevated ? NervRestTheme.Arousal.high : NervRestTheme.Text.primary)
                Text("baseline: \(baseline)")
                    .font(NervRestTheme.Fonts.micro)
                    .foregroundColor(NervRestTheme.Text.tertiary)
            }
            Text(elevation)
                .font(NervRestTheme.Fonts.micro)
                .fontWeight(.bold)
                .foregroundColor(isElevated ? NervRestTheme.Arousal.critical : NervRestTheme.Arousal.calm)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background((isElevated ? NervRestTheme.Arousal.critical : NervRestTheme.Arousal.calm).opacity(0.15))
                .cornerRadius(NervRestTheme.Radius.sm)
        }
    }
}
```

- [ ] **Step 3: Implement `RampDownViewModel`**

Create `NervRest/Logic/ViewModels/RampDownViewModel.swift`:

```swift
import Foundation
import Combine

class RampDownViewModel: ObservableObject {
    @Published var suggestions: [RampDownSuggestion] = []
    @Published var freeTextInput: String = ""

    private let rampDownEngine: RampDownEngine
    private let stimEngine: StimulationEngine
    private let appUsage: AppUsageDataProvider

    init(rampDownEngine: RampDownEngine,
         stimEngine: StimulationEngine,
         appUsage: AppUsageDataProvider) {
        self.rampDownEngine = rampDownEngine
        self.stimEngine = stimEngine
        self.appUsage = appUsage
    }

    func loadSuggestions() {
        guard let score = stimEngine.currentScore,
              let currentApp = appUsage.currentApp else { return }
        suggestions = rampDownEngine.generatePath(
            currentScore: score.total,
            currentApp: currentApp.appName
        )
    }

    func openSuggestion(_ suggestion: RampDownSuggestion) {
        guard let url = suggestion.deepLinkURL else { return }
        // In production, this would open the app via UIApplication.shared.open(url)
    }
}
```

- [ ] **Step 4: Implement `RampDownScreen`**

Create `NervRest/UI/Screens/RampDownScreen.swift`:

```swift
import SwiftUI

struct RampDownScreen: View {
    @ObservedObject var viewModel: RampDownViewModel

    var body: some View {
        ZStack {
            NervRestTheme.Surface.background.ignoresSafeArea()

            VStack(spacing: NervRestTheme.Spacing.xl) {
                AgentCharacter(mood: "concerned", size: 48)

                Text("Let's wind down")
                    .font(NervRestTheme.Fonts.displayMedium)
                    .foregroundColor(NervRestTheme.Text.primary)

                Text("Try switching to something calmer")
                    .font(NervRestTheme.Fonts.body)
                    .foregroundColor(NervRestTheme.Text.secondary)

                // Suggestion cards
                VStack(spacing: NervRestTheme.Spacing.sm) {
                    ForEach(viewModel.suggestions.prefix(3)) { suggestion in
                        suggestionCard(suggestion)
                    }
                }
                .padding(.horizontal, NervRestTheme.Spacing.md)

                // Free text input
                VStack(alignment: .leading, spacing: NervRestTheme.Spacing.xs) {
                    Text("Or tell me what you'd like to watch")
                        .font(NervRestTheme.Fonts.caption)
                        .foregroundColor(NervRestTheme.Text.tertiary)
                    TextField("e.g. nature documentary", text: $viewModel.freeTextInput)
                        .textFieldStyle(.plain)
                        .font(NervRestTheme.Fonts.body)
                        .foregroundColor(NervRestTheme.Text.primary)
                        .padding(NervRestTheme.Spacing.md)
                        .background(NervRestTheme.Surface.cardBackground)
                        .cornerRadius(NervRestTheme.Radius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: NervRestTheme.Radius.md)
                                .stroke(NervRestTheme.Surface.cardBorder, lineWidth: 1)
                        )
                }
                .padding(.horizontal, NervRestTheme.Spacing.md)

                Spacer()
            }
            .padding(.vertical, NervRestTheme.Spacing.xl)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.loadSuggestions()
        }
    }

    private func suggestionCard(_ suggestion: RampDownSuggestion) -> some View {
        Button(action: { viewModel.openSuggestion(suggestion) }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.toApp)
                        .font(NervRestTheme.Fonts.headline)
                        .foregroundColor(NervRestTheme.Text.primary)
                    Text("Stim: \(String(format: "%.1f", suggestion.toAppStimScore)) · ~\(suggestion.estimatedMinutesToCalm) min to calm")
                        .font(NervRestTheme.Fonts.micro)
                        .foregroundColor(NervRestTheme.Text.tertiary)
                }
                Spacer()
                Text("−\(Int(suggestion.predictedHRDrop)) bpm")
                    .font(NervRestTheme.Fonts.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(NervRestTheme.Arousal.calm)
            }
            .padding(NervRestTheme.Spacing.md)
            .background(NervRestTheme.Surface.cardBackground)
            .cornerRadius(NervRestTheme.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: NervRestTheme.Radius.md)
                    .stroke(NervRestTheme.Surface.cardBorder, lineWidth: 1)
            )
        }
    }
}
```

- [ ] **Step 5: Verify build**

```bash
cd NervRest && xcodebuild build -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10
```
Expected: BUILD SUCCEEDED

- [ ] **Step 6: Commit**

```bash
git add NervRest/NervRest/UI/Screens/MismatchDetailScreen.swift NervRest/NervRest/UI/Screens/RampDownScreen.swift NervRest/NervRest/Logic/ViewModels/
git commit -m "feat: add MismatchDetail and RampDown screens with ViewModels"
```

---

## Task 9: Dynamic Island Widget Extension (PARALLEL with Tasks 7, 8 — depends on 4, 6)

**Files:**
- Create: `NervRestWidgetExtension/NervRestLiveActivity.swift`
- Create: `NervRestWidgetExtension/NervRestWidgetBundle.swift`
- Create: `NervRestWidgetExtension/LiveActivityViews/CompactLeadingView.swift`
- Create: `NervRestWidgetExtension/LiveActivityViews/CompactTrailingView.swift`
- Create: `NervRestWidgetExtension/LiveActivityViews/MinimalView.swift`
- Create: `NervRestWidgetExtension/LiveActivityViews/ExpandedView.swift`

**Context:** This is the Widget Extension target that renders the Dynamic Island and Lock Screen Live Activity. Follow spec Section 7. The `NervRestActivityAttributes` are defined in Task 6 and must be shared with this target (add the file to both targets in Xcode, or use a shared framework).

**Important Xcode setup:** Create a new Widget Extension target named `NervRestWidgetExtension`. Set "Include Live Activity" option. Add `NervRestActivityAttributes` to both targets' membership.

- [ ] **Step 1: Create widget extension target**

In Xcode: File → New → Target → Widget Extension. Name: `NervRestWidgetExtension`. Check "Include Live Activity". Deployment target: iOS 17.0.

- [ ] **Step 2: Implement `NervRestWidgetBundle`**

Create `NervRestWidgetExtension/NervRestWidgetBundle.swift`:

```swift
import WidgetKit
import SwiftUI

@main
struct NervRestWidgetBundle: WidgetBundle {
    var body: some Widget {
        NervRestLiveActivity()
    }
}
```

- [ ] **Step 3: Implement `NervRestLiveActivity`**

Create `NervRestWidgetExtension/NervRestLiveActivity.swift`:

```swift
import ActivityKit
import SwiftUI
import WidgetKit

struct NervRestLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NervRestActivityAttributes.self) { context in
            // Lock Screen banner
            ExpandedView(state: context.state)
                .padding(12)
                .background(Color(hex: "#0D1117"))
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded regions
                DynamicIslandExpandedRegion(.leading) {
                    CompactLeadingView(state: context.state)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    CompactTrailingView(state: context.state)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedView(state: context.state)
                }
            } compactLeading: {
                CompactLeadingView(state: context.state)
            } compactTrailing: {
                CompactTrailingView(state: context.state)
            } minimal: {
                MinimalView(state: context.state)
            }
        }
    }
}
```

- [ ] **Step 4: Implement Dynamic Island views**

Create all 4 view files per spec Section 7:
- `CompactLeadingView.swift` — agent emoji based on mood
- `CompactTrailingView.swift` — arousal score with color
- `MinimalView.swift` — tiny colored dot
- `ExpandedView.swift` — full card with biometrics, app info, action button

See spec Section 7 for exact implementation. Use `NervRestTheme` colors where possible (may need to duplicate color definitions in the widget extension since extensions can't always share code easily).

- [ ] **Step 5: Add `NSSupportsLiveActivities` to Info.plist**

Ensure the main app's Info.plist has:
```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

- [ ] **Step 6: Verify build for both targets**

```bash
cd NervRest && xcodebuild build -scheme NervRestWidgetExtension -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10
```
Expected: BUILD SUCCEEDED

- [ ] **Step 7: Commit**

```bash
git add NervRestWidgetExtension/
git commit -m "feat: add Dynamic Island widget extension with compact, expanded, and minimal views"
```

---

## Task 10: App Entry Point + DI Container + Navigation (depends on ALL previous tasks)

**Files:**
- Create: `NervRest/App/AppContainer.swift`
- Create: `NervRest/App/NervRestApp.swift`
- Create: `NervRest/UI/Navigation/AppRouter.swift`

**Context:** This is the final integration task. `AppContainer` wires everything together using dependency injection. `AppRouter` handles navigation state (tab bar or navigation stack). `NervRestApp` is the SwiftUI app entry point. This task glues all previous work into a running app.

- [ ] **Step 1: Implement `AppContainer`**

Create `NervRest/App/AppContainer.swift`:

```swift
import Foundation

class AppContainer: ObservableObject {
    // Data Layer
    let biometrics: BiometricDataProvider
    let appUsage: AppUsageDataProvider
    let context: ContextDataProvider
    let stimScores: StimScoreProvider

    // Logic Layer — Engines
    let stimulationEngine: StimulationEngine
    let mismatchDetector: MismatchDetector
    let rampDownEngine: RampDownEngine
    let interventionScheduler: InterventionScheduler
    let personalProfileBuilder: PersonalProfileBuilder

    // Logic Layer — Managers
    let liveActivityManager: LiveActivityManager
    let notificationManager: NotificationManager
    let sessionManager: SessionManager

    // ViewModels
    let homeViewModel: HomeViewModel
    let mismatchViewModel: MismatchViewModel
    let rampDownViewModel: RampDownViewModel

    init() {
        // Data providers (simulated for hackathon)
        let bio = SimulatedBiometricProvider()
        let app = SimulatedAppUsageProvider()
        let ctx = RealContextProvider()
        let stim = StaticStimScoreProvider()

        self.biometrics = bio
        self.appUsage = app
        self.context = ctx
        self.stimScores = stim

        // Engines
        self.stimulationEngine = StimulationEngine(
            biometrics: bio, appUsage: app, context: ctx, stimScores: stim
        )
        self.mismatchDetector = MismatchDetector(
            biometrics: bio, appUsage: app, context: ctx
        )
        self.personalProfileBuilder = PersonalProfileBuilder()
        self.rampDownEngine = RampDownEngine(
            stimScores: stim, profileBuilder: personalProfileBuilder
        )

        // Managers
        self.liveActivityManager = LiveActivityManager()
        self.notificationManager = NotificationManager()
        self.interventionScheduler = InterventionScheduler(
            stimEngine: stimulationEngine,
            mismatchDetector: mismatchDetector,
            notificationManager: notificationManager,
            liveActivityManager: liveActivityManager
        )
        self.sessionManager = SessionManager(
            stimEngine: stimulationEngine,
            mismatchDetector: mismatchDetector,
            interventionScheduler: interventionScheduler
        )

        // ViewModels
        self.homeViewModel = HomeViewModel(
            sessionManager: sessionManager,
            stimEngine: stimulationEngine,
            biometrics: bio,
            appUsage: app
        )
        self.mismatchViewModel = MismatchViewModel(
            mismatchDetector: mismatchDetector,
            stimEngine: stimulationEngine
        )
        self.rampDownViewModel = RampDownViewModel(
            rampDownEngine: rampDownEngine,
            stimEngine: stimulationEngine,
            appUsage: app
        )

        // Start simulated biometric playback
        bio.startPlayback()
    }
}
```

- [ ] **Step 2: Implement `AppRouter`**

Create `NervRest/UI/Navigation/AppRouter.swift`:

```swift
import SwiftUI

enum AppRoute: Hashable {
    case home
    case mismatchDetail
    case rampDown
}

class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var currentRoute: AppRoute = .home

    func navigate(to route: AppRoute) {
        currentRoute = route
        path.append(route)
    }

    func popToRoot() {
        path = NavigationPath()
        currentRoute = .home
    }
}
```

- [ ] **Step 3: Implement `NervRestApp`**

Create `NervRest/App/NervRestApp.swift`:

```swift
import SwiftUI

@main
struct NervRestApp: App {
    @StateObject private var container = AppContainer()
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                HomeScreen(viewModel: container.homeViewModel)
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .home:
                            HomeScreen(viewModel: container.homeViewModel)
                        case .mismatchDetail:
                            MismatchDetailScreen(
                                viewModel: container.mismatchViewModel,
                                onWindDown: {
                                    router.navigate(to: .rampDown)
                                }
                            )
                        case .rampDown:
                            RampDownScreen(viewModel: container.rampDownViewModel)
                        }
                    }
            }
            .environmentObject(container)
            .environmentObject(router)
            .onOpenURL { url in
                handleDeepLink(url)
            }
            .task {
                await container.notificationManager.requestPermission()
                container.notificationManager.registerCategories()
            }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "nervrest" else { return }
        switch url.host {
        case "rampdown":
            router.navigate(to: .rampDown)
        case "mismatch":
            router.navigate(to: .mismatchDetail)
        default:
            break
        }
    }
}
```

- [ ] **Step 4: Add URL scheme to Info.plist**

Ensure the app's Info.plist includes URL scheme `nervrest`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>nervrest</string>
        </array>
    </dict>
</array>
```

- [ ] **Step 5: Build and run on simulator**

```bash
cd NervRest && xcodebuild build -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10
```
Expected: BUILD SUCCEEDED

- [ ] **Step 6: Smoke test the full flow**

1. Launch app on simulator
2. Tap "Start Evening Session"
3. Watch arousal gauge update every 30 seconds as simulated biometric data plays
4. When arousal rises (during Twitter/TikTok phase), notification should fire
5. Tap notification → navigates to MismatchDetailScreen
6. Tap "Show me alternatives" → navigates to RampDownScreen
7. Verify Dynamic Island updates (requires iPhone 15+ simulator)

- [ ] **Step 7: Commit**

```bash
git add NervRest/NervRest/App/ NervRest/NervRest/UI/Navigation/
git commit -m "feat: integrate all layers — AppContainer DI, navigation, deep links, full monitoring flow"
```

---

## Execution Notes

### Parallel Execution Strategy

**Wave 1 (4 parallel subagents):**
- Subagent A → Task 1 (Data Models)
- Subagent B → Task 2 (Protocols)
- Subagent C → Task 3 (Mock Data — may need model stubs, merge after A+B)
- Subagent D → Task 4 (Design System)

**Wave 2 (2 parallel subagents, after Wave 1 merges):**
- Subagent E → Task 5 (Core Engines)
- Subagent F → Task 6 (Managers)

**Wave 3 (3 parallel subagents, after Wave 2 merges):**
- Subagent G → Task 7 (Home Screen)
- Subagent H → Task 8 (Mismatch + RampDown)
- Subagent I → Task 9 (Dynamic Island Widget)

**Wave 4 (1 subagent, after Wave 3 merges):**
- Subagent J → Task 10 (Integration)

### What's Deferred to Iteration 2
- Real HealthKit data integration
- Real Screen Time API integration
- Screen Time Shield extension
- Timeline/Profile/NutritionLabel screens
- Onboarding flow
- Final Figma design implementation
- Claude API for dynamic stim scoring
- Personal profile learning from real usage data
