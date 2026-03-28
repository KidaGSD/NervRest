# NervRest V2 Alignment Plan — Score 100-scale + Shield Redesign + Biometric Weights

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align the codebase with the V2 Dusk Figma design and FigJam spec — switch to 0-100 scoring, redesign Shield screen to match V2, fix biometric weights, and add contextual alarm/bedtime info.

**Architecture:** Changes span all 3 layers. Data models change score scale. Logic engines change weights and thresholds. UI changes display format and Shield layout. No new files — all modifications.

**Tech Stack:** Swift, SwiftUI, Combine

**Note:** Another agent is independently working on avatar/Dynamic Island (Dusk Moon theme). DO NOT touch: `AgentCharacter.swift`, `IslandCompactLeading.swift`, `IslandExpandedView.swift`, or `NervRestTheme.swift` — those are being handled separately.

---

## Dependency Graph

```
Task 1 (Score 0-100 scale) ──┐
Task 2 (Biometric weights)  ──┼──▶ Task 4 (Shield redesign)
Task 3 (Threshold tuning)  ───┘         │
                                         ▼
                                Task 5 (Build + verify)
```

Tasks 1-3 are parallel. Task 4 depends on 1-3. Task 5 is final verification.

---

## Task 1: Change scoring from 1-10 to 0-100

**Files:**
- Modify: `NervRest/NervRest/Data/Models/ArousalScore.swift`
- Modify: `NervRest/NervRest/Logic/Engines/StimulationEngine.swift`
- Modify: `NervRest/NervRest/UI/Components/ArousalGauge.swift`
- Modify: `NervRest/NervRest/UI/Components/StimScoreBadge.swift`
- Modify: `NervRest/NervRest/UI/Components/IslandCompactTrailing.swift` — ONLY the score display format, NOT colors (avatar agent handles colors)
- Modify: `NervRest/NervRest/UI/Components/IslandMinimal.swift` — ONLY thresholds

**IMPORTANT:** Do NOT touch `NervRestTheme.swift`, `AgentCharacter.swift`, `IslandCompactLeading.swift`, or `IslandExpandedView.swift`. Another agent is working on those.

- [ ] **Step 1: Update ArousalScore model**

In `ArousalScore.swift`, change the `level` computed property thresholds from 1-10 to 0-100:

```swift
var level: ArousalLevel {
    switch total {
    case 0..<30: return .calm
    case 30..<50: return .moderate
    case 50..<70: return .elevated
    case 70..<90: return .high
    default: return .critical
    }
}
```

- [ ] **Step 2: Update StimulationEngine to output 0-100**

In `StimulationEngine.swift`, change the `updateScore()` method:

Find the line that caps the score:
```swift
let capped = min(10.0, max(1.0, raw))
```

Change to:
```swift
let capped = min(100.0, max(0.0, raw * 10.0))
```

This multiplies the internal calculation by 10 to produce 0-100 range.

- [ ] **Step 3: Update ArousalGauge display**

In `ArousalGauge.swift`:
- Change the arc progress from `score / 10` to `score / 100`
- Change the score format from `"%.1f"` to `"%.0f"` (show "87" not "87.3")
- The gauge ring should fill proportionally to 100

Find:
```swift
.trim(from: 0, to: animatedProgress / 10)
```
Change to:
```swift
.trim(from: 0, to: animatedProgress / 100)
```

Find score text format `"%.1f"` and change to `"%.0f"`.

- [ ] **Step 4: Update StimScoreBadge**

In `StimScoreBadge.swift`, the app stim scores (TikTok=8.3 etc) stay on the 1-10 scale since they come from the JSON lookup. These are per-app scores, NOT the overall arousal score. **No change needed** unless the badge displays the overall arousal score.

Read the file to verify what it displays. If it only shows per-app stim scores, leave it unchanged.

- [ ] **Step 5: Update IslandCompactTrailing score display**

In `IslandCompactTrailing.swift`, change score format from `"%.1f"` to `"%.0f"`.

Update the threshold ranges in `arousalColor`:
```swift
private var arousalColor: Color {
    switch arousalScore {
    case ..<30: return ...  // calm
    case 30..<50: return ... // moderate
    case 50..<70: return ... // elevated
    case 70..<90: return ... // high
    default: return ...     // critical
    }
}
```

**DO NOT change the hex color values** — the avatar agent may be updating those to Dusk palette.

- [ ] **Step 6: Update IslandMinimal thresholds**

Same threshold changes (0-100 scale) in `IslandMinimal.swift` `arousalColor`.

- [ ] **Step 7: Commit**

```bash
git add -A && git commit -m "feat: switch arousal scoring from 1-10 to 0-100 scale to match V2 design"
```

---

## Task 2: Fix biometric weights to match FigJam spec

**Files:**
- Modify: `NervRest/NervRest/Logic/Engines/StimulationEngine.swift`

**FigJam spec says:** HR: 50% weight, HRV: 30% weight, Respiratory rate: 20% weight.

Our current code uses content-based scoring (novelty/emotion/sensory/interactivity) with a biometric modifier. The FigJam wants biometrics to BE the primary signal, not a modifier.

- [ ] **Step 1: Read StimulationEngine.swift to understand current algorithm**

Current: `contentScore * bioModifier * timeMultiplier`

New approach per FigJam: The stimulation score should be primarily biometric-driven:
- Normalize HR elevation to 0-1 range
- Normalize HRV depression to 0-1 range
- Normalize respiratory rate elevation to 0-1 range
- Weighted sum: `hrScore * 0.5 + hrvScore * 0.3 + rrScore * 0.2`
- Multiply by time multiplier
- Scale to 0-100

- [ ] **Step 2: Rewrite updateScore() with biometric-first approach**

```swift
func updateScore() {
    guard let bio = biometrics.latestReading else { return }

    let ctx = context.currentContext

    // Normalize biometric signals to 0-1 range
    let hrElevation = max(0, (bio.heartRate - biometrics.baseline.restingHR) / biometrics.baseline.restingHR)
    let hrScore = min(1.0, hrElevation / 0.5)  // 50% elevation = max score

    let hrvDepression = max(0, (biometrics.baseline.restingHRV - bio.hrvSDNN) / biometrics.baseline.restingHRV)
    let hrvScore = min(1.0, hrvDepression / 0.6)  // 60% depression = max score

    let rrElevation: Double
    if let rr = bio.respiratoryRate, let baseRR = biometrics.baseline.restingRespiratoryRate {
        rrElevation = max(0, (rr - baseRR) / baseRR)
    } else {
        rrElevation = 0
    }
    let rrScore = min(1.0, rrElevation / 0.3)  // 30% elevation = max score

    // Weighted sum per FigJam: HR 50%, HRV 30%, RR 20%
    let bioScore = hrScore * 0.5 + hrvScore * 0.3 + rrScore * 0.2

    // Time multiplier
    let timeMultiplier = Self.timeMultiplier(for: ctx.currentTime)

    // Scale to 0-100
    let raw = bioScore * timeMultiplier * 100.0
    let capped = min(100.0, max(0.0, raw))

    // Get content info for the score components (still useful for display)
    let stim = stimScores.score(for: appUsage.currentApp?.appName ?? "")

    currentScore = ArousalScore(
        total: capped,
        noveltyComponent: stim?.novelty ?? 0,
        emotionComponent: stim?.emotion ?? 0,
        sensoryComponent: stim?.sensory ?? 0,
        interactivityComponent: stim?.interactivity ?? 0,
        timeMultiplier: timeMultiplier,
        timestamp: Date()
    )
}
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "feat: biometric-first scoring — HR 50%, HRV 30%, RR 20% per FigJam spec"
```

---

## Task 3: Update intervention thresholds for 0-100 scale

**Files:**
- Modify: `NervRest/NervRest/Logic/Engines/InterventionScheduler.swift`
- Modify: `NervRest/NervRest/Logic/Engines/MismatchDetector.swift`

- [ ] **Step 1: Update InterventionScheduler thresholds**

Change from 1-10 to 0-100:
```swift
var nudgeThreshold: Double = 55.0        // was 5.5
var strongNudgeThreshold: Double = 70.0  // was 7.0
var interventionThreshold: Double = 80.0 // was 8.0
```

- [ ] **Step 2: Verify MismatchDetector uses ratios, not absolute scores**

Read `MismatchDetector.swift` — it uses `hrElevationThreshold` and `hrvDepressionThreshold` as ratios (0.15, 0.20), NOT absolute scores. These should NOT change since they're percentages. Confirm and leave unchanged.

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "fix: update intervention thresholds to 0-100 scale"
```

---

## Task 4: Redesign ShieldOverlayScreen to match V2 Figma

**Files:**
- Modify: `NervRest/NervRest/UI/Screens/ShieldOverlayScreen.swift`

**V2 Design shows:**
1. ArousalGauge at top (large, showing score like "87")
2. "Time to wind down" title
3. Contextual body text: "Your bedtime is approaching and your stimulation level is quite high. Fancy seeing bedtime-ready alternatives?"
4. Alarm info bar: "Alarm    8:00 AM"
5. "Show me alternatives" button (primary, filled)
6. "5 more minutes" text (ghost)

- [ ] **Step 1: Read current ShieldOverlayScreen.swift**

Understand current parameters and layout.

- [ ] **Step 2: Rewrite the shield layout**

The new ShieldOverlayScreen needs these parameters:
```swift
struct ShieldOverlayScreen: View {
    let arousalScore: Double      // 0-100
    let currentHR: Int
    let alarmTime: String         // "8:00 AM"
    var onShowAlternatives: () -> Void = {}
    var onFiveMoreMinutes: () -> Void = {}
```

New layout (top to bottom, centered):
```
[ArousalGauge - large, showing score/100 with level label]
    spacing: 24
[Title: "Time to wind down"]
    spacing: 12
[Body text: "Your bedtime is approaching and your
stimulation level is quite high. Fancy seeing
bedtime-ready alternatives?"]
    spacing: 20
[Alarm bar: rounded rect with "Alarm" left, time right]
    spacing: 40
[Primary button: "Show me alternatives"]
    spacing: 12
[Ghost text: "5 more minutes"]
```

Background: very dark (Surface.background or darker).

The ArousalGauge component already exists — reuse it. Just need to compute the level from the score.

- [ ] **Step 3: Update NervRestApp.swift to pass alarmTime**

In the `.shieldOverlay` navigation case, pass alarm time from container:

```swift
case .shieldOverlay:
    ShieldOverlayScreen(
        arousalScore: container.homeViewModel.arousalScore,
        currentHR: container.homeViewModel.heartRate,
        alarmTime: container.contextProvider.currentContext.alarmTime?.hourMinute ?? "7:00 AM",
        onShowAlternatives: { router.navigate(to: .rampDown) },
        onFiveMoreMinutes: { router.popToRoot() }
    )
```

Note: `hourMinute` is the `Date` extension from `Date+Formatting.swift`.

- [ ] **Step 4: Verify build**

```bash
cd /Users/huangjunda/Desktop/Resolute/NervRest && xcodebuild build -scheme NervRest -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -allowProvisioningUpdates -quiet 2>&1 | tail -5
```

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "feat: redesign ShieldOverlay to match V2 — gauge + alarm info + contextual text"
```

---

## Task 5: Build verification + update Figma

- [ ] **Step 1: Full build**

```bash
cd /Users/huangjunda/Desktop/Resolute/NervRest && xcodebuild build -scheme NervRest -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -allowProvisioningUpdates 2>&1 | grep -E "error:|BUILD"
```
Expected: BUILD SUCCEEDED

- [ ] **Step 2: Commit all changes**

```bash
git add -A && git commit -m "feat: V2 alignment complete — 0-100 scoring, biometric weights, shield redesign"
```

---

## Execution Strategy

**Tasks 1-3: parallel** (3 subagents — different files, no overlap)
- Task 1: ArousalScore.swift, StimulationEngine.swift (score output), ArousalGauge.swift, Island display files
- Task 2: StimulationEngine.swift (algorithm) — **CONFLICT with Task 1** on StimulationEngine
- Task 3: InterventionScheduler.swift, MismatchDetector.swift

**Resolution:** Merge Tasks 1+2 into a single agent since both modify StimulationEngine.swift.

**Revised parallel plan:**
- **Agent A:** Tasks 1+2 combined (score scale + biometric weights) — touches: ArousalScore, StimulationEngine, ArousalGauge, Island display files
- **Agent B:** Task 3 (thresholds) — touches: InterventionScheduler, MismatchDetector
- **After A+B:** Task 4 (Shield redesign) — touches: ShieldOverlayScreen, NervRestApp
- **Final:** Task 5 (build verify)
