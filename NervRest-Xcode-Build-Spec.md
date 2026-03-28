# NervRest — Xcode Build Spec for Claude Code

> Build a native iOS app (SwiftUI + ActivityKit + HealthKit) that detects when a user's nervous system is overstimulated during evening phone use, and guides them to progressively calmer content before sleep.

> **This spec prioritizes backend architecture and scalability.** UI components are placeholders — a designer will deliver detailed screens, a design system, and a mascot character later. Every visual element should be trivially swappable.

---

## 1. What This App Does (User Flow)

```
┌──────────────┐     ┌──────────────┐     ┌───────────────────┐
│ User is about │     │ User scrolls │     │ Two parallel       │
│ to sleep      │────▶│ TikTok /     │────▶│ detection engines:  │
│               │     │ Instagram    │     │                    │
│ • bedtime set │     │              │     │ 1. Biometric:      │
│ • alarm set   │     │              │     │    HR + HRV from   │
│               │     │              │     │    Apple Watch      │
└──────────────┘     └──────────────┘     │                    │
                                           │ 2. Context:        │
                                           │    bedtime +       │
                                           │    wakeup time +   │
                                           │    current app     │
                                           └────────┬──────────┘
                                                    │
                                                    ▼
                                    ┌──────────────────────────┐
                                    │ Stimulation engine scores │
                                    │ current state (1-10)     │
                                    │                          │
                                    │ If arousal > threshold   │
                                    │ AND within wind-down     │
                                    │ window (e.g. 30 min      │
                                    │ before predicted high):  │
                                    └────────────┬─────────────┘
                                                 │
                                                 ▼
                                    ┌──────────────────────────┐
                                    │ Phase 1: Gentle nudge    │
                                    │ → Notification banner    │
                                    │   over current app       │
                                    │ → Dynamic Island updates │
                                    │   with agent character   │
                                    │   + arousal score        │
                                    └────────────┬─────────────┘
                                                 │
                                                 ▼
                                    ┌──────────────────────────┐
                                    │ Phase 2: Intervention    │
                                    │ → Screen fades to black  │
                                    │   (Screen Time shield)   │
                                    │ → Show 3 content options │
                                    │   OR let user type what  │
                                    │   they want to watch     │
                                    └────────────┬─────────────┘
                                                 │
                                                 ▼
                                    ┌──────────────────────────┐
                                    │ Phase 3: Recovery        │
                                    │ → User watches low-stim  │
                                    │   content                │
                                    │ → Dynamic Island shows   │
                                    │   agent character +      │
                                    │   biometrics recovering  │
                                    │ → Confirms wind-down     │
                                    │   before sleep           │
                                    └──────────────────────────┘
```

---

## 2. Architecture Overview

### Design Principle: Strict Separation of Concerns

The app has three layers. The UI layer ONLY renders data it receives from the logic layer. The logic layer ONLY processes data from the data layer. No business logic in views. No UI code in services.

```
┌─────────────────────────────────────────────────────────────┐
│                       UI LAYER                               │
│  (SwiftUI Views — all placeholder, easily replaceable)       │
│                                                              │
│  • MainAppView          • MismatchDetailView                │
│  • OnboardingView       • RampDownView                      │
│  • TimelineView         • NutritionLabelView                │
│  • AgentCharacterView   • SettingsView                      │
│                                                              │
│  Dynamic Island:                                             │
│  • CompactView (pill)   • ExpandedView (long-press)         │
│                                                              │
│  Notifications:                                              │
│  • NudgeBanner          • InterventionBanner                │
│                                                              │
│  Shield (Screen Time):                                       │
│  • ShieldContentView    • ShieldActionView                  │
│                                                              │
│  Design System (injected):                                   │
│  • ThemeProvider         • ColorTokens                      │
│  • Typography            • AgentAssets                      │
└──────────────────────┬──────────────────────────────────────┘
                       │ observes ViewModels (ObservableObject)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                      LOGIC LAYER                             │
│  (ViewModels + Engines — all the brains)                     │
│                                                              │
│  • StimulationEngine        → computes arousal score         │
│  • MismatchDetector         → compares body vs intent        │
│  • RampDownEngine           → generates content suggestions  │
│  • InterventionScheduler    → decides when to nudge/block    │
│  • PersonalProfileBuilder   → learns per-app body response   │
│  • LiveActivityManager      → updates Dynamic Island         │
│  • NotificationManager      → fires local notifications      │
│                                                              │
│  ViewModels:                                                 │
│  • HomeViewModel                                             │
│  • TimelineViewModel                                         │
│  • RampDownViewModel                                         │
│  • ProfileViewModel                                          │
└──────────────────────┬──────────────────────────────────────┘
                       │ reads from data providers (protocols)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                              │
│  (Protocols + concrete implementations)                      │
│                                                              │
│  Protocols:                                                  │
│  • BiometricDataProvider    → HR, HRV, respiratory rate      │
│  • AppUsageDataProvider     → current app, duration, history │
│  • ContextDataProvider      → time, alarm, motion state      │
│  • StimScoreProvider        → lookup table for app scores    │
│                                                              │
│  Concrete (hackathon):                                       │
│  • SimulatedBiometricProvider  → reads WESAD JSON on timer   │
│  • SimulatedAppUsageProvider   → reads crafted timeline JSON │
│  • RealContextProvider         → actual clock + alarm time   │
│  • StaticStimScoreProvider     → hardcoded app score lookup  │
│                                                              │
│  Concrete (production — swap later):                         │
│  • HealthKitBiometricProvider  → real Apple Watch data       │
│  • ScreenTimeAppUsageProvider  → real Screen Time API        │
│  • HealthKitContextProvider    → real sleep schedule         │
│  • AIStimScoreProvider         → Claude API classification   │
└─────────────────────────────────────────────────────────────┘
```

### Why This Matters

When the designer delivers final screens, you replace ONLY the UI layer files. When you ship to production with real Apple Watch data, you swap ONLY the data provider implementations. The logic layer never changes.

---

## 3. Project Structure

```
NervRest/
├── NervRest.xcodeproj
├── NervRest/
│   ├── App/
│   │   ├── NervRestApp.swift              ← App entry point, DI setup
│   │   └── AppContainer.swift             ← Dependency injection container
│   │
│   ├── Data/
│   │   ├── Providers/
│   │   │   ├── BiometricDataProvider.swift      ← Protocol
│   │   │   ├── AppUsageDataProvider.swift        ← Protocol
│   │   │   ├── ContextDataProvider.swift         ← Protocol
│   │   │   └── StimScoreProvider.swift           ← Protocol
│   │   │
│   │   ├── Simulated/
│   │   │   ├── SimulatedBiometricProvider.swift  ← Reads WESAD JSON, emits on timer
│   │   │   ├── SimulatedAppUsageProvider.swift   ← Reads timeline JSON, emits on timer
│   │   │   ├── RealContextProvider.swift         ← Real clock + hardcoded alarm
│   │   │   └── StaticStimScoreProvider.swift     ← Hardcoded app score lookup
│   │   │
│   │   ├── Production/                          ← Empty stubs for now
│   │   │   ├── HealthKitBiometricProvider.swift
│   │   │   ├── ScreenTimeAppUsageProvider.swift
│   │   │   └── AIStimScoreProvider.swift
│   │   │
│   │   ├── Models/
│   │   │   ├── BiometricReading.swift           ← HR, HRV, timestamp
│   │   │   ├── AppUsageEvent.swift              ← app name, start, end, stim score
│   │   │   ├── ArousalScore.swift               ← computed score + components
│   │   │   ├── MismatchEvent.swift              ← body vs intent data
│   │   │   ├── RampDownSuggestion.swift         ← target app, predicted HR drop
│   │   │   ├── PersonalProfile.swift            ← per-app avg body response
│   │   │   └── UserContext.swift                ← alarm, bedtime, motion state
│   │   │
│   │   └── JSON/
│   │       ├── wesad-evening.json               ← Processed WESAD biometric data
│   │       ├── evening-timeline.json            ← Crafted app usage scenario
│   │       └── app-stim-scores.json             ← Pre-scored app lookup table
│   │
│   ├── Logic/
│   │   ├── Engines/
│   │   │   ├── StimulationEngine.swift          ← Core scoring algorithm
│   │   │   ├── MismatchDetector.swift           ← Body vs intent comparison
│   │   │   ├── RampDownEngine.swift             ← Generates wind-down suggestions
│   │   │   ├── InterventionScheduler.swift      ← Decides when to nudge vs block
│   │   │   └── PersonalProfileBuilder.swift     ← Learns per-app body patterns
│   │   │
│   │   ├── Managers/
│   │   │   ├── LiveActivityManager.swift        ← Creates/updates Dynamic Island
│   │   │   ├── NotificationManager.swift        ← Fires local notifications
│   │   │   └── SessionManager.swift             ← Tracks current monitoring session
│   │   │
│   │   └── ViewModels/
│   │       ├── HomeViewModel.swift              ← Live gauge data
│   │       ├── TimelineViewModel.swift          ← Evening chart data
│   │       ├── MismatchViewModel.swift          ← Alert detail data
│   │       ├── RampDownViewModel.swift          ← Suggestion data
│   │       └── ProfileViewModel.swift           ← Weekly stats data
│   │
│   ├── UI/
│   │   ├── Theme/
│   │   │   ├── ThemeProvider.swift              ← Central theme config
│   │   │   ├── ColorTokens.swift               ← All colors as static tokens
│   │   │   ├── Typography.swift                ← Font styles
│   │   │   └── Spacing.swift                   ← Layout constants
│   │   │
│   │   ├── Components/                          ← Reusable, atomic UI pieces
│   │   │   ├── ArousalGauge.swift              ← Circular gauge (placeholder)
│   │   │   ├── BiometricCard.swift             ← HR + HRV display card
│   │   │   ├── AppBlock.swift                  ← Colored block for timeline
│   │   │   ├── StimScoreBadge.swift            ← Small score pill (1-10)
│   │   │   ├── AgentCharacter.swift            ← Mascot placeholder (swap later)
│   │   │   └── NutritionLabel.swift            ← FDA-style label
│   │   │
│   │   ├── Screens/
│   │   │   ├── OnboardingScreen.swift
│   │   │   ├── HomeScreen.swift                ← Live gauge + current state
│   │   │   ├── TimelineScreen.swift            ← Evening dual-track chart
│   │   │   ├── MismatchDetailScreen.swift      ← Triggered from notification
│   │   │   ├── RampDownScreen.swift            ← 3 options + free input
│   │   │   ├── ProfileScreen.swift             ← Per-app body response chart
│   │   │   └── NutritionLabelScreen.swift      ← Weekly summary
│   │   │
│   │   └── Navigation/
│   │       └── AppRouter.swift                 ← Navigation state machine
│   │
│   └── Extensions/
│       ├── Color+Theme.swift
│       ├── Date+Formatting.swift
│       └── Double+Rounding.swift
│
├── NervRestWidgetExtension/                     ← Live Activity + Dynamic Island
│   ├── NervRestLiveActivity.swift              ← ActivityAttributes definition
│   ├── NervRestWidgetBundle.swift
│   └── LiveActivityViews/
│       ├── CompactLeadingView.swift            ← Small pill: agent face + score
│       ├── CompactTrailingView.swift           ← HR number
│       ├── MinimalView.swift                   ← Tiny dot (color = arousal)
│       ├── ExpandedView.swift                  ← Full card on long-press
│       └── AgentIslandView.swift               ← Agent character in the island
│
├── NervRestShieldExtension/                     ← Screen Time shield overlay
│   ├── ShieldConfigurationExtension.swift
│   └── ShieldActionExtension.swift
│
└── NervRestDeviceActivityMonitor/               ← Background app monitoring
    └── DeviceActivityMonitorExtension.swift
```

---

## 4. Data Models

```swift
// MARK: - BiometricReading
struct BiometricReading: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let heartRate: Double          // bpm
    let hrvSDNN: Double            // ms
    let respiratoryRate: Double?   // breaths per min (optional)
    
    var isElevated: Bool {
        heartRate > 75  // configurable threshold
    }
}

// MARK: - AppUsageEvent
struct AppUsageEvent: Codable, Identifiable {
    let id: UUID
    let appName: String
    let appCategory: AppCategory
    let startTime: Date
    let endTime: Date?             // nil = still active
    let stimulationScore: Double   // 1-10
    
    var duration: TimeInterval {
        (endTime ?? Date()).timeIntervalSince(startTime)
    }
}

enum AppCategory: String, Codable {
    case socialMedia, news, entertainment, messaging
    case productivity, education, health, music
    case reading, gaming, other
}

// MARK: - ArousalScore
struct ArousalScore {
    let total: Double              // 1-10, capped
    let noveltyComponent: Double
    let emotionComponent: Double
    let sensoryComponent: Double
    let interactivityComponent: Double
    let timeMultiplier: Double
    let timestamp: Date
    
    var level: ArousalLevel {
        switch total {
        case 0..<3: return .calm
        case 3..<5: return .moderate
        case 5..<7: return .elevated
        case 7..<9: return .high
        default: return .critical
        }
    }
}

enum ArousalLevel: String {
    case calm, moderate, elevated, high, critical
    
    // Placeholder colors — designer will replace
    var color: String {
        switch self {
        case .calm: return "teal"
        case .moderate: return "green"
        case .elevated: return "amber"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

// MARK: - MismatchEvent
struct MismatchEvent: Identifiable {
    let id: UUID
    let timestamp: Date
    let currentHR: Double
    let baselineHR: Double
    let currentHRV: Double
    let baselineHRV: Double
    let currentApp: String
    let stimScore: Double
    let context: UserContext
    
    var hrElevationPercent: Double {
        ((currentHR - baselineHR) / baselineHR) * 100
    }
    
    var reason: String {
        "HR \(Int(hrElevationPercent))% above resting baseline during rest context"
    }
}

// MARK: - UserContext
struct UserContext {
    let currentTime: Date
    let alarmTime: Date?
    let bedtimeStart: Date?
    let motionState: MotionState
    let isInWindDownWindow: Bool
    
    var minutesUntilAlarm: Int? {
        guard let alarm = alarmTime else { return nil }
        return Int(alarm.timeIntervalSince(currentTime) / 60)
    }
}

enum MotionState: String {
    case still, walking, driving, exercising, unknown
}

// MARK: - RampDownSuggestion
struct RampDownSuggestion: Identifiable {
    let id: UUID
    let fromApp: String
    let toApp: String
    let toAppStimScore: Double
    let predictedHRDrop: Double    // bpm reduction
    let estimatedMinutesToCalm: Int
    let deepLinkURL: URL?          // to open the suggested app
}

// MARK: - PersonalProfile (per-app body response)
struct AppBodyResponse: Codable, Identifiable {
    let id: UUID
    let appName: String
    let avgHRChange: Double        // +12 or -8
    let avgHRVChange: Double       // -18 or +12
    let avgArousal: Double
    let sampleCount: Int
}
```

---

## 5. Data Provider Protocols

```swift
// MARK: - BiometricDataProvider
protocol BiometricDataProvider {
    /// Continuous stream of biometric readings
    var readings: AsyncStream<BiometricReading> { get }
    
    /// Latest single reading
    var latestReading: BiometricReading? { get }
    
    /// Historical readings for a time range
    func readings(from: Date, to: Date) async -> [BiometricReading]
    
    /// User's personal baseline (resting)
    var baseline: BiometricBaseline { get }
}

struct BiometricBaseline {
    let restingHR: Double          // e.g. 64
    let restingHRV: Double         // e.g. 55
    let restingRespiratoryRate: Double? // e.g. 14
}

// MARK: - AppUsageDataProvider
protocol AppUsageDataProvider {
    /// Current active app (nil if phone locked)
    var currentApp: AppUsageEvent? { get }
    
    /// Stream of app change events
    var appChanges: AsyncStream<AppUsageEvent> { get }
    
    /// Usage history for a time range
    func usage(from: Date, to: Date) async -> [AppUsageEvent]
    
    /// Number of app switches in last N minutes
    func switchCount(lastMinutes: Int) -> Int
    
    /// Number of phone pickups today
    var pickupCountToday: Int { get }
}

// MARK: - ContextDataProvider
protocol ContextDataProvider {
    var currentContext: UserContext { get }
    
    /// Stream of context changes (e.g. entering wind-down window)
    var contextChanges: AsyncStream<UserContext> { get }
}

// MARK: - StimScoreProvider
protocol StimScoreProvider {
    /// Get stimulation score breakdown for an app
    func score(for appName: String) -> StimulationBreakdown?
    
    /// Get all scored apps
    var allScores: [String: StimulationBreakdown] { get }
}

struct StimulationBreakdown: Codable {
    let novelty: Double        // 1-10
    let emotion: Double        // 1-10
    let sensory: Double        // 1-10
    let interactivity: Double  // 1-10
    let baseScore: Double      // weighted average before time multiplier
}
```

---

## 6. Core Engines

### StimulationEngine

```swift
/// Computes a real-time arousal score from biometric + app + context data.
/// This is the core algorithm. Everything else depends on this score.
class StimulationEngine: ObservableObject {
    
    @Published var currentScore: ArousalScore?
    
    private let biometrics: BiometricDataProvider
    private let appUsage: AppUsageDataProvider
    private let context: ContextDataProvider
    private let stimScores: StimScoreProvider
    
    // Weights — configurable, could be personalized later
    struct Weights {
        var novelty: Double = 0.30
        var emotion: Double = 0.25
        var sensory: Double = 0.20
        var interactivity: Double = 0.25
    }
    var weights = Weights()
    
    init(biometrics: BiometricDataProvider,
         appUsage: AppUsageDataProvider,
         context: ContextDataProvider,
         stimScores: StimScoreProvider) {
        self.biometrics = biometrics
        self.appUsage = appUsage
        self.context = context
        self.stimScores = stimScores
    }
    
    /// Call on a timer (e.g. every 30 seconds) to update the score
    func updateScore() {
        guard let bio = biometrics.latestReading,
              let app = appUsage.currentApp,
              let stim = stimScores.score(for: app.appName) else { return }
        
        let ctx = context.currentContext
        
        // Content-based score
        let contentScore = (stim.novelty * weights.novelty +
                           stim.emotion * weights.emotion +
                           stim.sensory * weights.sensory +
                           stim.interactivity * weights.interactivity)
        
        // Biometric modifier: how much is body elevated above baseline?
        let hrElevation = (bio.heartRate - biometrics.baseline.restingHR) /
                          biometrics.baseline.restingHR
        let hrvDepression = (biometrics.baseline.restingHRV - bio.hrvSDNN) /
                            biometrics.baseline.restingHRV
        let bioModifier = 1.0 + (hrElevation + hrvDepression) * 0.5
        
        // Time multiplier
        let timeMultiplier = Self.timeMultiplier(for: ctx.currentTime)
        
        // Combined
        let raw = contentScore * bioModifier * timeMultiplier
        let capped = min(10.0, max(1.0, raw))
        
        currentScore = ArousalScore(
            total: capped,
            noveltyComponent: stim.novelty,
            emotionComponent: stim.emotion,
            sensoryComponent: stim.sensory,
            interactivityComponent: stim.interactivity,
            timeMultiplier: timeMultiplier,
            timestamp: Date()
        )
    }
    
    static func timeMultiplier(for date: Date) -> Double {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 6..<12: return 1.0
        case 12..<18: return 1.0
        case 18..<21: return 1.2
        case 21..<24: return 1.5
        default: return 1.8  // after midnight
        }
    }
}
```

### MismatchDetector

```swift
/// Detects when body state contradicts rest intent.
/// Fires when: user is still + it's evening + HR is elevated + HRV is depressed
class MismatchDetector: ObservableObject {
    
    @Published var activeMismatch: MismatchEvent?
    
    private let biometrics: BiometricDataProvider
    private let appUsage: AppUsageDataProvider
    private let context: ContextDataProvider
    
    // Thresholds — configurable
    var hrElevationThreshold: Double = 0.15  // 15% above baseline
    var hrvDepressionThreshold: Double = 0.20 // 20% below baseline
    
    func check() {
        guard let bio = biometrics.latestReading else { return }
        let ctx = context.currentContext
        
        let hrElevation = (bio.heartRate - biometrics.baseline.restingHR) /
                          biometrics.baseline.restingHR
        let hrvDepression = (biometrics.baseline.restingHRV - bio.hrvSDNN) /
                            biometrics.baseline.restingHRV
        
        let isMismatch = ctx.motionState == .still &&
                         ctx.isInWindDownWindow &&
                         hrElevation > hrElevationThreshold &&
                         hrvDepression > hrvDepressionThreshold
        
        if isMismatch {
            activeMismatch = MismatchEvent(
                id: UUID(),
                timestamp: Date(),
                currentHR: bio.heartRate,
                baselineHR: biometrics.baseline.restingHR,
                currentHRV: bio.hrvSDNN,
                baselineHRV: biometrics.baseline.restingHRV,
                currentApp: appUsage.currentApp?.appName ?? "Unknown",
                stimScore: appUsage.currentApp?.stimulationScore ?? 0,
                context: ctx
            )
        } else {
            activeMismatch = nil
        }
    }
}
```

### InterventionScheduler

```swift
/// Decides WHEN and HOW to intervene based on escalating severity.
/// Phase 1: gentle nudge (notification)
/// Phase 2: stronger nudge (second notification + Dynamic Island alert)  
/// Phase 3: intervention (Screen Time shield with options)
class InterventionScheduler: ObservableObject {
    
    enum Phase: Int, Comparable {
        case monitoring = 0     // watching, no action
        case gentleNudge = 1    // first notification
        case strongNudge = 2    // second notification, island pulses
        case intervention = 3   // shield overlay with ramp-down options
        case recovery = 4       // user switched to calm content
        
        static func < (lhs: Phase, rhs: Phase) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    @Published var currentPhase: Phase = .monitoring
    
    private let stimEngine: StimulationEngine
    private let mismatchDetector: MismatchDetector
    private let notificationManager: NotificationManager
    private let liveActivityManager: LiveActivityManager
    
    // Configurable thresholds
    var nudgeThreshold: Double = 6.0        // arousal score to trigger gentle nudge
    var strongNudgeThreshold: Double = 7.5  // arousal score for strong nudge
    var interventionThreshold: Double = 8.5 // arousal score to trigger shield
    var nudgeCooldownSeconds: TimeInterval = 300  // 5 min between nudges
    
    private var lastNudgeTime: Date?
    
    /// Called on the same timer as StimulationEngine (every 30s)
    func evaluate() {
        guard let score = stimEngine.currentScore else { return }
        let mismatch = mismatchDetector.activeMismatch
        
        // Don't nudge too frequently
        if let last = lastNudgeTime,
           Date().timeIntervalSince(last) < nudgeCooldownSeconds {
            return
        }
        
        switch score.total {
        case ..<nudgeThreshold:
            currentPhase = .monitoring
            
        case nudgeThreshold..<strongNudgeThreshold:
            if mismatch != nil && currentPhase < .gentleNudge {
                currentPhase = .gentleNudge
                notificationManager.fireNudge(mismatch: mismatch!, score: score)
                liveActivityManager.updateState(.elevated(score: score))
                lastNudgeTime = Date()
            }
            
        case strongNudgeThreshold..<interventionThreshold:
            if currentPhase < .strongNudge {
                currentPhase = .strongNudge
                notificationManager.fireStrongNudge(mismatch: mismatch, score: score)
                liveActivityManager.updateState(.warning(score: score))
                lastNudgeTime = Date()
            }
            
        default: // >= interventionThreshold
            if currentPhase < .intervention {
                currentPhase = .intervention
                liveActivityManager.updateState(.critical(score: score))
                // Shield activation happens via Screen Time API
                // The shield extension reads the current phase
            }
        }
    }
    
    func userChoseRampDown() {
        currentPhase = .recovery
        liveActivityManager.updateState(.recovering)
    }
}
```

### RampDownEngine

```swift
/// Generates personalized ramp-down suggestions based on the user's
/// current arousal level and their historical body response data.
class RampDownEngine {
    
    private let stimScores: StimScoreProvider
    private let profileBuilder: PersonalProfileBuilder
    
    /// Generate a step-down path from current arousal to calm
    func generatePath(currentScore: Double, currentApp: String) -> [RampDownSuggestion] {
        let allApps = stimScores.allScores
        
        // Sort apps by stimulation score ascending
        let calmOptions = allApps
            .filter { $0.value.baseScore < currentScore - 1.5 }
            .sorted { $0.value.baseScore < $1.value.baseScore }
        
        // Pick 3-4 steps that form a gradual ramp
        var path: [RampDownSuggestion] = []
        let targetScores = stride(from: currentScore - 2.5,
                                   through: 1.5,
                                   by: -2.0)
        
        for target in targetScores {
            if let best = calmOptions.first(where: {
                abs($0.value.baseScore - target) < 1.5
            }) {
                let profile = profileBuilder.response(for: best.key)
                path.append(RampDownSuggestion(
                    id: UUID(),
                    fromApp: path.last?.toApp ?? currentApp,
                    toApp: best.key,
                    toAppStimScore: best.value.baseScore,
                    predictedHRDrop: abs(profile?.avgHRChange ?? -5),
                    estimatedMinutesToCalm: max(5, Int(abs(profile?.avgHRChange ?? -5) * 1.5)),
                    deepLinkURL: Self.deepLink(for: best.key)
                ))
            }
        }
        
        return path
    }
    
    /// Attempt to build a URL scheme to open the suggested app
    static func deepLink(for appName: String) -> URL? {
        // Common URL schemes — extend as needed
        let schemes: [String: String] = [
            "Spotify_lofi": "spotify:playlist:37i9dQZF1DWZd79rJ6a7lp",
            "Podcast": "podcasts://",
            "YouTube_longform": "youtube://",
            "Kindle": "kindle://",
            "Headspace": "headspace://",
        ]
        return schemes[appName].flatMap(URL.init(string:))
    }
}
```

---

## 7. Live Activity + Dynamic Island

### ActivityAttributes

```swift
import ActivityKit

struct NervRestActivityAttributes: ActivityAttributes {
    
    // Static data (set when activity starts, doesn't change)
    struct ContentState: Codable, Hashable {
        var arousalScore: Double
        var heartRate: Int
        var hrv: Int
        var currentApp: String
        var phase: String           // "monitoring", "elevated", "warning", "critical", "recovering"
        var agentMood: String       // "happy", "concerned", "worried", "relieved"
        var minutesUntilAlarm: Int?
    }
    
    // Fixed when activity starts
    let sessionStartTime: Date
    let userName: String
}
```

### Dynamic Island Views

```swift
// MARK: - Compact Leading (left side of pill)
// Shows the agent character face — mood changes with arousal level
struct CompactLeadingView: View {
    let state: NervRestActivityAttributes.ContentState
    
    var body: some View {
        // PLACEHOLDER: Replace with designer's agent/mascot asset
        // For now, use a simple emoji that changes with mood
        Text(agentEmoji)
            .font(.system(size: 20))
    }
    
    private var agentEmoji: String {
        switch state.agentMood {
        case "happy": return "😊"
        case "concerned": return "😐"
        case "worried": return "😟"
        case "relieved": return "😌"
        default: return "🫥"
        }
    }
}

// MARK: - Compact Trailing (right side of pill)
// Shows the arousal score with color
struct CompactTrailingView: View {
    let state: NervRestActivityAttributes.ContentState
    
    var body: some View {
        Text(String(format: "%.1f", state.arousalScore))
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(arousalColor)
    }
    
    private var arousalColor: Color {
        switch state.arousalScore {
        case ..<3: return .teal
        case 3..<5: return .green
        case 5..<7: return .orange
        case 7..<9: return .red
        default: return .red
        }
    }
}

// MARK: - Expanded View (long-press on Dynamic Island)
// Full card with biometrics, app info, and action button
struct ExpandedView: View {
    let state: NervRestActivityAttributes.ContentState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top row: agent + status
            HStack {
                // PLACEHOLDER: agent character (swap with designer asset)
                Text(agentEmoji)
                    .font(.system(size: 28))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(statusMessage)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if let mins = state.minutesUntilAlarm {
                        Text("Alarm in \(mins / 60)h \(mins % 60)m")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                Spacer()
                
                // Arousal gauge
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 3)
                        .frame(width: 36, height: 36)
                    Circle()
                        .trim(from: 0, to: state.arousalScore / 10)
                        .stroke(arousalColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 36, height: 36)
                        .rotationEffect(.degrees(-90))
                    Text(String(format: "%.0f", state.arousalScore))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            
            // Biometric row
            HStack(spacing: 16) {
                Label("\(state.heartRate) bpm", systemImage: "heart.fill")
                    .font(.system(size: 12))
                    .foregroundColor(state.heartRate > 75 ? .red : .green)
                
                Label("\(state.hrv) ms", systemImage: "waveform.path.ecg")
                    .font(.system(size: 12))
                    .foregroundColor(state.hrv < 35 ? .red : .green)
                
                Spacer()
                
                Text(state.currentApp)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            // Action button (only in warning/critical phases)
            if state.phase == "warning" || state.phase == "critical" {
                // This deep-links back into the main app's ramp-down screen
                Link(destination: URL(string: "nervrest://rampdown")!) {
                    Text("Wind down")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding(12)
    }
    
    private var agentEmoji: String {
        // PLACEHOLDER: swap with AgentCharacterView when designer delivers
        switch state.agentMood {
        case "happy": return "😊"
        case "concerned": return "😐"  
        case "worried": return "😟"
        case "relieved": return "😌"
        default: return "🫥"
        }
    }
    
    private var statusMessage: String {
        switch state.phase {
        case "monitoring": return "Monitoring your evening"
        case "elevated": return "Stimulation rising..."
        case "warning": return "Your body isn't relaxing"
        case "critical": return "Nervous system activated"
        case "recovering": return "Winding down nicely"
        default: return "NervRest"
        }
    }
    
    private var arousalColor: Color {
        switch state.arousalScore {
        case ..<3: return .teal
        case 3..<5: return .green
        case 5..<7: return .orange
        default: return .red
        }
    }
}
```

---

## 8. Notification Templates

```swift
class NotificationManager {
    
    func requestPermission() async {
        try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    /// Phase 1: gentle nudge
    func fireNudge(mismatch: MismatchEvent, score: ArousalScore) {
        let content = UNMutableNotificationContent()
        content.title = "Your body isn't resting"
        content.body = "\(mismatch.currentApp) has raised your HR to \(Int(mismatch.currentHR))bpm — \(Int(mismatch.hrElevationPercent))% above your resting baseline."
        content.categoryIdentifier = "NUDGE"
        content.sound = .default
        // PLACEHOLDER: add custom notification icon when designer delivers
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "nudge-\(UUID())", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Phase 2: stronger nudge with action buttons
    func fireStrongNudge(mismatch: MismatchEvent?, score: ArousalScore) {
        let content = UNMutableNotificationContent()
        content.title = "Stimulation is high"
        content.body = "You've been on high-stimulation content for \(Int(score.total * 3)) minutes. Your alarm is in \(mismatch?.context.minutesUntilAlarm ?? 0 / 60) hours. Ready to wind down?"
        content.categoryIdentifier = "STRONG_NUDGE"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "strong-\(UUID())", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Register notification categories with action buttons
    func registerCategories() {
        let windDown = UNNotificationAction(identifier: "WIND_DOWN", title: "Show me alternatives", options: .foreground)
        let dismiss = UNNotificationAction(identifier: "DISMISS", title: "Not now", options: .destructive)
        
        let nudgeCategory = UNNotificationCategory(identifier: "NUDGE", actions: [windDown, dismiss], intentIdentifiers: [])
        let strongCategory = UNNotificationCategory(identifier: "STRONG_NUDGE", actions: [windDown, dismiss], intentIdentifiers: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([nudgeCategory, strongCategory])
    }
}
```

---

## 9. Simulated Data Provider (Hackathon)

```swift
/// Reads WESAD biometric data from bundled JSON and emits readings on a timer.
/// For the hackathon demo, this replaces real HealthKit data.
/// The timer speed can be adjusted for demo pacing.
class SimulatedBiometricProvider: BiometricDataProvider {
    
    private var readings: [BiometricReading] = []
    private var currentIndex = 0
    private var timer: Timer?
    
    // How fast to play through the data (1.0 = real time, 0.1 = 10x speed)
    var playbackSpeed: TimeInterval = 0.5  // 2x speed for demo
    
    let baseline = BiometricBaseline(restingHR: 64, restingHRV: 55, restingRespiratoryRate: 14)
    
    var latestReading: BiometricReading? {
        guard currentIndex < readings.count else { return nil }
        return readings[currentIndex]
    }
    
    init() {
        loadData()
    }
    
    private func loadData() {
        // Load the processed WESAD JSON from app bundle
        guard let url = Bundle.main.url(forResource: "wesad-evening", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([BiometricReading].self, from: data) else {
            // Fallback: generate synthetic data
            readings = Self.generateSyntheticEvening()
            return
        }
        readings = decoded
    }
    
    func startPlayback() {
        timer = Timer.scheduledTimer(withTimeInterval: playbackSpeed, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.currentIndex < self.readings.count - 1 {
                self.currentIndex += 1
            }
        }
    }
    
    func stopPlayback() {
        timer?.invalidate()
    }
    
    /// Generate synthetic data if WESAD isn't loaded
    /// Simulates: calm → rising (during social media) → peak → recovery (during podcast)
    static func generateSyntheticEvening() -> [BiometricReading] {
        var result: [BiometricReading] = []
        let baseDate = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!
        
        // Phase 1: Calm baseline (19:00 - 19:20, Instagram browsing)
        for i in 0..<20 {
            let time = baseDate.addingTimeInterval(TimeInterval(i * 60))
            result.append(BiometricReading(
                id: UUID(), timestamp: time,
                heartRate: 68 + Double.random(in: -2...4),
                hrvSDNN: 50 + Double.random(in: -3...3),
                respiratoryRate: 14
            ))
        }
        
        // Phase 2: Netflix (19:20 - 20:05, mostly calm)
        for i in 20..<65 {
            let time = baseDate.addingTimeInterval(TimeInterval(i * 60))
            result.append(BiometricReading(
                id: UUID(), timestamp: time,
                heartRate: 66 + Double.random(in: -2...3),
                hrvSDNN: 52 + Double.random(in: -2...3),
                respiratoryRate: 14
            ))
        }
        
        // Phase 3: Twitter doomscroll (20:15 - 20:50, rising)
        for i in 65..<90 {
            let progress = Double(i - 65) / 25.0
            let time = baseDate.addingTimeInterval(TimeInterval(i * 60))
            result.append(BiometricReading(
                id: UUID(), timestamp: time,
                heartRate: 72 + progress * 16 + Double.random(in: -2...2),
                hrvSDNN: 48 - progress * 22 + Double.random(in: -2...2),
                respiratoryRate: 14 + progress * 4
            ))
        }
        
        // Phase 4: TikTok peak (20:50 - 21:15, peak stress)
        for i in 90..<105 {
            let time = baseDate.addingTimeInterval(TimeInterval(i * 60))
            result.append(BiometricReading(
                id: UUID(), timestamp: time,
                heartRate: 86 + Double.random(in: -2...4),
                hrvSDNN: 24 + Double.random(in: -2...3),
                respiratoryRate: 18 + Double.random(in: -1...1)
            ))
        }
        
        // Phase 5: Recovery - YouTube then Podcast (21:15 - 22:00)
        for i in 105..<150 {
            let progress = Double(i - 105) / 45.0
            let time = baseDate.addingTimeInterval(TimeInterval(i * 60))
            result.append(BiometricReading(
                id: UUID(), timestamp: time,
                heartRate: 86 - progress * 24 + Double.random(in: -2...2),
                hrvSDNN: 24 + progress * 32 + Double.random(in: -2...2),
                respiratoryRate: 18 - progress * 4
            ))
        }
        
        return result
    }
}
```

---

## 10. App Stimulation Scores (JSON)

Bundle this as `app-stim-scores.json`:

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

---

## 11. UI Component Contracts

Every UI component follows this pattern so the designer can replace visuals without touching logic:

```swift
/// EXAMPLE: ArousalGauge
/// The ViewModel provides the data. The View only renders.
/// When designer delivers final gauge design, replace ONLY this file.

struct ArousalGauge: View {
    let score: Double           // 1-10
    let level: ArousalLevel     // enum
    let heartRate: Int
    let hrv: Int
    
    // PLACEHOLDER IMPLEMENTATION
    // Designer will replace with final visual
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 160, height: 160)
                Circle()
                    .trim(from: 0, to: score / 10)
                    .stroke(
                        level.swiftUIColor,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", score))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    Text(level.rawValue.uppercased())
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 24) {
                Label("\(heartRate) bpm", systemImage: "heart.fill")
                    .font(.caption)
                Label("\(hrv) ms", systemImage: "waveform.path.ecg")
                    .font(.caption)
            }
        }
    }
}
```

```swift
/// EXAMPLE: AgentCharacter
/// PLACEHOLDER — will be replaced with designer's mascot/character
/// Could be a Lottie animation, SF Symbol, or custom SwiftUI drawing

struct AgentCharacter: View {
    let mood: String  // "happy", "concerned", "worried", "relieved"
    let size: CGFloat
    
    // PLACEHOLDER: emoji-based agent
    // Designer will replace with actual mascot asset (Lottie, Image, or SwiftUI)
    var body: some View {
        Text(emoji)
            .font(.system(size: size))
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
}

// When designer delivers the mascot, this becomes:
// struct AgentCharacter: View {
//     let mood: String
//     let size: CGFloat
//     var body: some View {
//         LottieView(animation: "agent-\(mood)")
//             .frame(width: size, height: size)
//     }
// }
```

---

## 12. Design System Tokens (Placeholder)

```swift
/// Central theme configuration.
/// Designer will update these values. Logic layer NEVER references colors directly.
enum NervRestTheme {
    
    // MARK: - Colors (placeholder — designer replaces these)
    enum Colors {
        static let calm = Color(hex: "#1D9E75")         // teal
        static let moderate = Color(hex: "#639922")      // green
        static let elevated = Color(hex: "#EF9F27")      // amber
        static let high = Color(hex: "#D85A30")          // coral
        static let critical = Color(hex: "#E24B4A")      // red
        
        static let backgroundPrimary = Color(hex: "#FAFAF8")
        static let backgroundSecondary = Color(hex: "#F2F1ED")
        static let textPrimary = Color(hex: "#2C2C2A")
        static let textSecondary = Color(hex: "#73726C")
        static let textTertiary = Color(hex: "#A3A29C")
        
        // Agent character accent color
        static let agentAccent = Color(hex: "#1D9E75")
    }
    
    // MARK: - Typography (placeholder)
    enum Fonts {
        static let displayLarge = Font.system(size: 34, weight: .bold, design: .rounded)
        static let displayMedium = Font.system(size: 24, weight: .bold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 15, weight: .regular)
        static let caption = Font.system(size: 13, weight: .regular)
        static let micro = Font.system(size: 11, weight: .medium)
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
}
```

---

## 13. What to Build First (Priority Order)

### Phase 1: Foundation (hours 0-3)
1. Create Xcode project with all targets (app + widget extension + shield extension)
2. Implement all data models (`BiometricReading`, `AppUsageEvent`, `ArousalScore`, etc.)
3. Implement all protocols (`BiometricDataProvider`, `AppUsageDataProvider`, etc.)
4. Implement `SimulatedBiometricProvider` with synthetic data generation
5. Implement `StaticStimScoreProvider` with JSON loader
6. Implement `StimulationEngine` core algorithm
7. Implement `MismatchDetector`

### Phase 2: Native OS Integration (hours 3-6)
8. Implement `LiveActivityManager` + `NervRestActivityAttributes`
9. Build Dynamic Island views (compact + expanded)
10. Implement `NotificationManager` with nudge templates
11. Implement `InterventionScheduler` with phase escalation
12. Wire up the main timer loop: every 30s → update score → check mismatch → evaluate intervention

### Phase 3: App Screens (hours 6-9)
13. HomeScreen with ArousalGauge (placeholder visual)
14. MismatchDetailScreen (shows body vs baseline)
15. RampDownScreen (3 options + free text input)
16. Implement `RampDownEngine` suggestion logic
17. Navigation between screens via deep links (notification tap → app)

### Phase 4: Polish + Demo (hours 9-10)
18. Test full flow on simulator: start session → play through biometric data → notification fires → tap → ramp down
19. Build demo script: exact sequence of taps and timing
20. Record backup video of the demo

### If time remains:
- TimelineScreen (evening chart with dual tracks)
- ProfileScreen (per-app body response bars)
- NutritionLabelScreen (weekly summary)

---

## 14. Things to AVOID

### Architecture
- Do NOT put business logic in SwiftUI views
- Do NOT hardcode colors/fonts — always use ThemeProvider tokens
- Do NOT make data providers singletons — use dependency injection via AppContainer
- Do NOT skip the protocol layer — even if it seems like overhead, it's what makes swapping simulated → real data trivial

### Native iOS
- Do NOT try to draw custom UI over other apps outside of Dynamic Island/notifications/shields — iOS doesn't allow it
- Do NOT try to read real Screen Time data for the hackathon — use simulated data, note that production would use DeviceActivityReport API
- Do NOT try to read real HealthKit data for the hackathon — use simulated data, note that production would use HealthKit queries

### Design
- Do NOT spend time on visual polish — the designer will handle this. Use SF Symbols, system fonts, and basic SwiftUI shapes
- Do NOT build a custom chart library — use Swift Charts (built into SwiftUI 4+)
- Do NOT build a custom agent character animation — use emoji placeholder. Designer will deliver Lottie or image assets

### Demo
- Do NOT try to demo on a physical device unless you're certain it works — simulator is fine
- Do NOT demo all screens — focus on: Dynamic Island → notification over TikTok → mismatch detail → ramp-down
- Do NOT explain the tech stack to judges — focus on the problem, the insight, and the "holy shit" moment when the notification appears over TikTok

---

## 15. Key Research References (for pitch deck)

1. Doomscrolling triggers dopamine through novelty-seeking, mimicking relaxation while activating fight-or-flight (University Hospitals, UC San Diego)
2. Fast-paced content with scene cuts <4 seconds impairs self-regulation (pediatric media studies, applicable to adults)
3. Apple Watch HRV validated against Polar H7 with reliability >0.9 (PMC validation study)
4. Screen time positively correlated with stress (r=0.67), evening use worst predictor (ML stress study, n=1000)
5. "When people try to relax, they stimulate themselves even more" — allostatic load from digital consumption
6. WESAD dataset: published stress detection benchmark, Random Forest achieves 99%+ accuracy with 8 HRV features

---

## 16. One-Line Positioning

**"Welltory tells you that you're stressed. Screen Time tells you that you're on your phone. We're the first to connect the two — and guide you down."**
