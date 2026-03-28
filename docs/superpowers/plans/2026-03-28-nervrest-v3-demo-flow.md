# NervRest V3 — Demo Flow Build Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the complete hackathon demo flow — user scrolls TikTok-style video feed → arousal rises → screen dims → moon mascot appears → shield overlay with alternatives. Also includes the in-app "Luna" chat greeting screen.

**Architecture:** Add a TikTok mock screen (from open-source component) as the demo entry point. The app flow becomes: TikTokMock (full screen video feed with NervRest overlay) → shield transition → Shield screen → RampDown → Recovery. The existing Home screen becomes the "settings/dashboard" view, and the TikTok mock becomes the demo showcase.

**Tech Stack:** SwiftUI, AVPlayer (video playback), existing NervRest components

**Note:** Another agent is handling avatar/Dynamic Island/Dusk theme. DO NOT touch: `AgentCharacter.swift`, `IslandCompactLeading.swift`, `NervRestTheme.swift`.

---

## The V2 Design Flow (from Figma)

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐     ┌──────────────────┐
│ TikTok/Instagram│     │ Screen dims      │     │ Moon mascot     │     │ Shield screen    │
│ feed playing    │────▶│ overlay darkens  │────▶│ appears on dark │────▶│ Gauge: 87        │
│                 │     │ gradually        │     │ background      │     │ Alarm: 8:00 AM   │
│ DI: 😊 2.5     │     │                  │     │ (transition)    │     │ [Alternatives]   │
│ HR overlay: 64  │     │                  │     │                 │     │ [5 more min]     │
└─────────────────┘     └──────────────────┘     └─────────────────┘     └──────────────────┘
                                                                                  │
                                                                                  ▼
                                                                         ┌──────────────────┐
                                                                         │ RampDown screen  │
                                                                         │ 3 alternatives   │
                                                                         └──────────────────┘
```

**In-App (separate tab):**
```
┌─────────────────┐     ┌──────────────────┐
│ Luna splash     │────▶│ Chat greeting    │
│ Moon mascot     │     │ "Good Evening"   │
│ centered, dark  │     │ "Chat with Luna" │
└─────────────────┘     └──────────────────┘
```

---

## Dependency Graph

```
Task 1 (Clone TikTok mock repo) ──▶ Task 2 (TikTokMockScreen) ──┐
                                                                   ├──▶ Task 5 (Demo flow orchestration)
Task 3 (Shield transition animation) ────────────────────────────┘         │
Task 4 (Luna chat greeting screen) ─── independent ────────────────────────┘
                                                                           │
                                                                   Task 6 (Navigation + entry point)
```

Tasks 1→2 sequential. Tasks 3, 4 parallel with 2. Task 5 depends on 2+3. Task 6 is final wiring.

**Parallel plan:**
- Agent A: Tasks 1+2 (clone + TikTok mock)
- Agent B: Task 3 (shield transition)
- Agent C: Task 4 (Luna chat)
- After A+B+C: Tasks 5+6 (orchestration + navigation)

---

## Task 1: Clone TikTok mock video player

**Action:** Clone the open-source repo and extract the relevant files.

- [ ] **Step 1: Clone the repo**

```bash
cd /tmp && git clone https://github.com/ux-germano-costa/short-video-app-swiftui.git
```

- [ ] **Step 2: Examine the repo structure**

```bash
ls -R /tmp/short-video-app-swiftui/ShortVideoApp/
```

Identify:
- Video player view (likely `VideoPlayerView.swift` or similar)
- Carousel/scroll view
- Video assets (.mp4 files)
- Any models/view models

- [ ] **Step 3: Copy relevant files to NervRest**

Create a new directory and copy:
```bash
mkdir -p /Users/huangjunda/Desktop/Resolute/NervRest/NervRest/UI/TikTokMock/
# Copy Swift view files
# Copy video assets to Resources/Videos/
```

Only copy the minimum needed: video player + carousel + assets. Skip networking, analytics, or other unnecessary code.

---

## Task 2: Build TikTokMockScreen

**Files:**
- Create: `NervRest/NervRest/UI/Screens/TikTokMockScreen.swift`
- Create: `NervRest/NervRest/UI/TikTokMock/` (copied components)

**Context:** This is the demo's "before" state — the user is scrolling TikTok-style content. NervRest biometric data overlays on top, showing arousal rising in real-time.

- [ ] **Step 1: Create TikTokMockScreen wrapper**

```swift
import SwiftUI

struct TikTokMockScreen: View {
    let arousalScore: Double     // 0-100
    let heartRate: Int
    let hrv: Int
    let currentApp: String
    let isMonitoring: Bool

    var body: some View {
        ZStack {
            // Full-screen TikTok-style video carousel (from cloned component)
            VideoCarouselView()  // or whatever the main view is named
                .ignoresSafeArea()

            // NervRest biometric overlay (top-left)
            VStack {
                HStack {
                    biometricOverlay
                    Spacer()
                }
                .padding(.top, 60)
                .padding(.horizontal, 16)

                Spacer()
            }
        }
    }

    private var biometricOverlay: some View {
        HStack(spacing: 8) {
            // Heart rate pill
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 10))
                Text("\(heartRate)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .foregroundColor(heartRate > 75 ? .red : .green)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial)
            .cornerRadius(12)

            // Arousal score pill
            Text(String(format: "%.0f", arousalScore))
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(arousalColor.opacity(0.8))
                .cornerRadius(12)
        }
    }

    private var arousalColor: Color {
        switch arousalScore {
        case ..<30: return .green
        case 30..<50: return .yellow
        case 50..<70: return .orange
        default: return .red
        }
    }
}
```

- [ ] **Step 2: Adapt cloned video player to compile with current Swift/SwiftUI**

The repo is from ~2023. Check for deprecated APIs and fix:
- `NavigationView` → `NavigationStack`
- Any iOS 15 APIs → iOS 17 equivalents
- Ensure mp4 files are in the bundle

- [ ] **Step 3: Verify build**

---

## Task 3: Shield transition animation

**Files:**
- Create: `NervRest/NervRest/UI/Screens/ShieldTransitionView.swift`

**Context:** When arousal crosses the intervention threshold, the TikTok feed dims gradually, then the moon mascot fades in on a dark background, then transitions to the full Shield screen. This is the "wow moment" of the demo.

- [ ] **Step 1: Create ShieldTransitionView**

```swift
import SwiftUI

struct ShieldTransitionView: View {
    @Binding var phase: TransitionPhase

    enum TransitionPhase {
        case hidden          // not showing
        case dimming         // dark overlay fading in over TikTok
        case moonReveal      // moon mascot appears, centered
        case shieldReady     // transition complete, show shield
    }

    var body: some View {
        ZStack {
            // Phase 1: Dimming overlay
            if phase != .hidden {
                Color.black
                    .opacity(dimmingOpacity)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 1.5), value: phase)
            }

            // Phase 2: Moon mascot reveal
            if phase == .moonReveal {
                VStack {
                    AgentCharacter(mood: "worried", size: 120)
                        .transition(.scale.combined(with: .opacity))
                }
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: phase)
            }
        }
    }

    private var dimmingOpacity: Double {
        switch phase {
        case .hidden: return 0
        case .dimming: return 0.7
        case .moonReveal: return 0.95
        case .shieldReady: return 1.0
        }
    }
}
```

- [ ] **Step 2: Create transition timing controller**

The transition should auto-advance:
- `dimming` → 2 seconds → `moonReveal`
- `moonReveal` → 1.5 seconds → `shieldReady`
- When `shieldReady`, the parent swaps to `ShieldOverlayScreen`

---

## Task 4: Luna chat greeting screen

**Files:**
- Create: `NervRest/NervRest/UI/Screens/LunaChatScreen.swift`
- Create: `NervRest/NervRest/Logic/ViewModels/LunaChatViewModel.swift`

**Context:** The in-app experience. Luna (the moon mascot) greets the user. Simple chat-style interface with greeting + text input. This is NOT a priority for the demo but rounds out the app.

- [ ] **Step 1: Create LunaChatViewModel**

```swift
import Foundation
import Combine

class LunaChatViewModel: ObservableObject {
    @Published var userName: String = "CC"
    @Published var greeting: String = ""
    @Published var inputText: String = ""
    @Published var showGreeting: Bool = false

    func loadGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        switch hour {
        case 5..<12: timeGreeting = "Good Morning"
        case 12..<17: timeGreeting = "Good Afternoon"
        case 17..<22: timeGreeting = "Good Evening"
        default: timeGreeting = "Good Night"
        }
        greeting = "\(timeGreeting), \(userName)"

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showGreeting = true
        }
    }
}
```

- [ ] **Step 2: Create LunaChatScreen**

```swift
import SwiftUI

struct LunaChatScreen: View {
    @ObservedObject var viewModel: LunaChatViewModel

    var body: some View {
        ZStack {
            NervRestTheme.Surface.background.ignoresSafeArea()

            VStack {
                Spacer()

                // Moon mascot
                AgentCharacter(mood: "happy", size: 80)
                    .opacity(viewModel.showGreeting ? 1 : 0)
                    .scaleEffect(viewModel.showGreeting ? 1 : 0.5)
                    .animation(.spring(response: 0.6), value: viewModel.showGreeting)

                if viewModel.showGreeting {
                    Text(viewModel.greeting)
                        .font(NervRestTheme.Fonts.displayMedium)
                        .foregroundColor(NervRestTheme.Text.primary)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))

                    Text("How can I help you today?")
                        .font(NervRestTheme.Fonts.body)
                        .foregroundColor(NervRestTheme.Text.secondary)
                }

                Spacer()

                // Chat input bar
                HStack {
                    TextField("Chat with Luna", text: $viewModel.inputText)
                        .font(NervRestTheme.Fonts.body)
                        .foregroundColor(NervRestTheme.Text.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(NervRestTheme.Surface.cardBackground)
                        .cornerRadius(NervRestTheme.Radius.xl)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { viewModel.loadGreeting() }
    }
}
```

---

## Task 5: Demo flow orchestration

**Files:**
- Create: `NervRest/NervRest/UI/Screens/DemoFlowScreen.swift`
- Modify: `NervRest/NervRest/Logic/Managers/SessionManager.swift`

**Context:** This is the master screen for the hackathon demo. It manages the full flow: TikTok mock → transition → Shield → RampDown.

- [ ] **Step 1: Create DemoFlowScreen**

```swift
import SwiftUI

struct DemoFlowScreen: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var mismatchViewModel: MismatchViewModel
    @ObservedObject var rampDownViewModel: RampDownViewModel

    @State private var currentPhase: DemoPhase = .tikTokScrolling
    @State private var transitionPhase: ShieldTransitionView.TransitionPhase = .hidden

    enum DemoPhase {
        case tikTokScrolling    // user is on fake TikTok
        case transitioning      // screen dimming + moon reveal
        case shieldOverlay      // full shield screen
        case rampDown          // alternatives screen
        case recovery          // back to calm content
    }

    let alarmTime: String
    var onExit: (() -> Void)?

    var body: some View {
        ZStack {
            switch currentPhase {
            case .tikTokScrolling, .transitioning:
                // TikTok mock as base layer
                TikTokMockScreen(
                    arousalScore: homeViewModel.arousalScore,
                    heartRate: homeViewModel.heartRate,
                    hrv: homeViewModel.hrv,
                    currentApp: homeViewModel.currentApp,
                    isMonitoring: homeViewModel.isMonitoring
                )

                // Shield transition overlay
                ShieldTransitionView(phase: $transitionPhase)

            case .shieldOverlay:
                ShieldOverlayScreen(
                    arousalScore: homeViewModel.arousalScore,
                    currentHR: homeViewModel.heartRate,
                    alarmTime: alarmTime,
                    onShowAlternatives: {
                        withAnimation { currentPhase = .rampDown }
                    },
                    onFiveMoreMinutes: {
                        // Reset to TikTok for 5 more minutes
                        withAnimation {
                            currentPhase = .tikTokScrolling
                            transitionPhase = .hidden
                        }
                    }
                )

            case .rampDown:
                RampDownScreen(viewModel: rampDownViewModel)

            case .recovery:
                // Could show a calm video or return to home
                VStack {
                    AgentCharacter(mood: "relieved", size: 80)
                    Text("Winding down nicely")
                        .font(NervRestTheme.Fonts.displayMedium)
                        .foregroundColor(NervRestTheme.Text.primary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(NervRestTheme.Surface.background)
            }
        }
        .onChange(of: homeViewModel.arousalScore) { _, score in
            handleScoreChange(score)
        }
    }

    private func handleScoreChange(_ score: Double) {
        guard currentPhase == .tikTokScrolling else { return }

        // When score crosses intervention threshold, start transition
        if score >= 80 {
            withAnimation {
                currentPhase = .transitioning
                transitionPhase = .dimming
            }

            // Auto-advance transition phases
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { transitionPhase = .moonReveal }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation { transitionPhase = .shieldReady }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation { currentPhase = .shieldOverlay }
            }
        }
    }
}
```

- [ ] **Step 2: Verify build**

---

## Task 6: Wire demo flow into app navigation

**Files:**
- Modify: `NervRest/NervRest/NervRestApp.swift`
- Modify: `NervRest/NervRest/UI/Navigation/AppRouter.swift`
- Modify: `NervRest/NervRest/AppContainer.swift`

- [ ] **Step 1: Add new routes**

In `AppRouter.swift`, add:
```swift
enum AppRoute: Hashable {
    case home
    case mismatchDetail
    case rampDown
    case shieldOverlay
    case demoFlow       // NEW: full demo experience
    case lunaChat       // NEW: Luna greeting
}
```

- [ ] **Step 2: Add LunaChatViewModel to AppContainer**

- [ ] **Step 3: Wire demo flow in NervRestApp**

The Home screen gets a "Start Demo" button that launches the DemoFlowScreen.
When the session starts, it enters the DemoFlowScreen which shows TikTok mock → transition → shield.

- [ ] **Step 4: Make Home screen the dashboard with two entry points**

```
Home Screen:
  - "Start Demo" → DemoFlowScreen (full demo with TikTok mock)
  - "Chat with Luna" → LunaChatScreen
  - Arousal gauge + biometrics (monitoring dashboard)
```

- [ ] **Step 5: Final build + commit**

---

## Execution Strategy

**Wave 1 (3 parallel agents):**
- **Agent A:** Tasks 1+2 — Clone TikTok repo + build TikTokMockScreen
- **Agent B:** Task 3 — Shield transition animation
- **Agent C:** Task 4 — Luna chat screen

**Wave 2 (after Wave 1):**
- **Agent D:** Tasks 5+6 — Demo flow orchestration + navigation wiring

## Key Files Created
```
NervRest/NervRest/
├── UI/
│   ├── TikTokMock/           ← copied from open-source repo
│   │   ├── VideoPlayerView.swift
│   │   ├── VideoCarouselView.swift
│   │   └── (other needed files)
│   ├── Screens/
│   │   ├── TikTokMockScreen.swift      ← NEW
│   │   ├── ShieldTransitionView.swift  ← NEW
│   │   ├── DemoFlowScreen.swift        ← NEW
│   │   └── LunaChatScreen.swift        ← NEW
│   └── Navigation/
│       └── AppRouter.swift             ← MODIFY
├── Logic/ViewModels/
│   └── LunaChatViewModel.swift         ← NEW
├── Resources/Videos/
│   └── *.mp4                           ← copied video assets
└── App/
    ├── AppContainer.swift              ← MODIFY
    └── NervRestApp.swift               ← MODIFY (but entry point)
```
