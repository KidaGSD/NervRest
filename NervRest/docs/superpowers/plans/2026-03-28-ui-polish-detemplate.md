# NervRest UI Polish — SF Pro Typography, Layered Depth, Conversational Direction

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace SF Rounded with SF Pro for a cleaner, more intentional feel. Add layered backgrounds, glassmorphism cards, and spacing rhythm. Align with the new Figma direction: conversational "Luna" companion with greeting screen + chat input.

**Architecture:** Pure UI-layer changes. Update `NervRestTheme.swift` fonts (`.rounded` → `.default`), add depth to backgrounds, vary card styles. New conversational home screen to match Figma "In-App" design. No logic/data changes.

**Tech Stack:** SwiftUI, SF Pro (system default — no font bundling needed), existing Dusk/Ember palette

---

## Context for the Implementer

### What's wrong now (the "template" signals)
1. **Every font is SF Rounded** — the `.rounded` design makes everything look bubbly and AI-generated
2. **Flat single-color background** — `#171120` everywhere, no depth
3. **Uniform 8pt grid spacing** — mechanical, robotic feel
4. **Cards all look identical** — same `cardBackground` + `cardBorder` stroke
5. **Dashboard-heavy layout** — gauge + cards + pills feels like a generic health app template

### The fix
- **Typography**: SF Pro (system `.default` design) — clean, professional, Apple-native. Keep SF Rounded ONLY for the numeric score in ArousalGauge.
- **Background**: Layer 2-3 radial gradients at different positions for depth
- **Spacing**: Break the rigid 8pt grid — vary section gaps for rhythm
- **Cards**: Mix glassmorphism (`.ultraThinMaterial`) with gradient fills
- **Direction**: New conversational home screen matching Figma "In-App" — moon mascot + "Good Evening" greeting + "Chat with Luna" input

### New Figma designs (from team)
- **Shield Flow**: Instagram → dimming overlay → arousal score ring (87, ember orange) → "Time to wind down" with alarm info
- **In-App Home**: Centered moon mascot, "Good Evening, CC", "How can I help you today?", bottom chat input "Chat with Luna"
- **Chat Interface**: Full-screen moon mascot centered (loading/splash)

### Reference: SF Pro vs SF Rounded
| SF Rounded (current) | SF Pro (target) |
|---|---|
| `.system(size:weight:design: .rounded)` | `.system(size:weight:design: .default)` |
| Bubbly, playful, childish at scale | Clean, professional, Apple-native |
| Every corner rounded → looks templated | Sharp letterforms → looks intentional |

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Modify | `UI/Theme/NervRestTheme.swift` | `.rounded` → `.default`, add SectionSpacing |
| Modify | `UI/Screens/HomeScreen.swift` | Layered background, spacing, conversational layout |
| Modify | `UI/Screens/ShieldOverlayScreen.swift` | Spacing rhythm, alarm info |
| Modify | `UI/Screens/MismatchDetailScreen.swift` | Glassmorphism card, spacing |
| Modify | `UI/Screens/RampDownScreen.swift` | Gradient cards, spacing |
| Modify | `UI/Components/ArousalGauge.swift` | Keep `.rounded` for score only |
| Modify | `UI/Components/BiometricCard.swift` | Glassmorphism |

---

## Task 1: Switch Typography to SF Pro

**Files:**
- Modify: `NervRest/UI/Theme/NervRestTheme.swift`

- [ ] **Step 1: Replace `.rounded` with `.default` in all Fonts except score**

Change every `design: .rounded` to `design: .default` EXCEPT `score` which keeps `.rounded` for numeric readability:

```swift
// MARK: - Typography (SF Pro — clean, Apple-native)
enum Fonts {
    static let displayLarge = Font.system(size: 40, weight: .bold, design: .default)
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .default)
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 15, weight: .regular, design: .default)
    static let caption = Font.system(size: 13, weight: .regular, design: .default)
    static let micro = Font.system(size: 11, weight: .medium, design: .default)
    static let score = Font.system(size: 56, weight: .heavy, design: .rounded) // KEEP rounded for numbers
}
```

- [ ] **Step 2: Add SectionSpacing enum**

Add after the existing Spacing enum:

```swift
// MARK: - Section Spacing (intentional rhythm, not uniform grid)
enum SectionSpacing {
    static let tight: CGFloat = 12      // within a group
    static let normal: CGFloat = 24     // between related items
    static let breathe: CGFloat = 40    // between sections
    static let dramatic: CGFloat = 56   // before hero elements
}
```

- [ ] **Step 3: Build to verify**

Run: `xcodebuild build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add NervRest/UI/Theme/NervRestTheme.swift
git commit -m "feat: switch from SF Rounded to SF Pro, add SectionSpacing

SF Pro for all text except numeric scores (keep .rounded).
Add SectionSpacing for intentional layout rhythm."
```

---

## Task 2: Layered Background + Spacing Rhythm on HomeScreen

**Files:**
- Modify: `NervRest/UI/Screens/HomeScreen.swift`

- [ ] **Step 1: Replace flat background with layered gradients**

Update `backgroundLayer`:

```swift
private var backgroundLayer: some View {
    ZStack {
        NervRestTheme.Surface.background
            .ignoresSafeArea()

        // Layer 1: Warm ambient glow top-right
        RadialGradient(
            gradient: Gradient(colors: [
                NervRestTheme.Accent.glow.opacity(0.04),
                Color.clear
            ]),
            center: UnitPoint(x: 0.8, y: 0.1),
            startRadius: 20,
            endRadius: 350
        )
        .ignoresSafeArea()

        // Layer 2: Status-colored glow behind gauge
        RadialGradient(
            gradient: Gradient(colors: [
                statusColor.opacity(0.1),
                Color.clear
            ]),
            center: UnitPoint(x: 0.5, y: 0.4),
            startRadius: 30,
            endRadius: 250
        )
        .ignoresSafeArea()

        // Layer 3: Purple wash at bottom for depth
        LinearGradient(
            gradient: Gradient(colors: [
                Color.clear,
                NervRestTheme.Surface.cardBackground.opacity(0.3)
            ]),
            startPoint: UnitPoint(x: 0.5, y: 0.6),
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
```

- [ ] **Step 2: Update spacing in main VStack**

Replace uniform `Spacing.lg` with intentional rhythm using `SectionSpacing`:

```swift
VStack(spacing: 0) {
    AgentCharacter(mood: viewModel.agentMood, size: 64)
        .padding(.top, NervRestTheme.SectionSpacing.dramatic)

    Text(statusMessage)
        .font(NervRestTheme.Fonts.body)
        .foregroundColor(statusColor)
        .multilineTextAlignment(.center)
        .padding(.horizontal, NervRestTheme.Spacing.lg)
        .padding(.top, NervRestTheme.SectionSpacing.tight)

    ArousalGauge(
        score: viewModel.arousalScore,
        level: viewModel.arousalLevel,
        heartRate: viewModel.heartRate,
        hrv: viewModel.hrv
    )
    .padding(.top, NervRestTheme.SectionSpacing.normal)

    StimScoreBadge(
        appName: viewModel.currentApp,
        score: viewModel.currentStimScore
    )
    .padding(.top, NervRestTheme.SectionSpacing.tight)

    HStack(spacing: NervRestTheme.Spacing.md) {
        BiometricCard(
            title: "Heart Rate",
            value: "\(viewModel.heartRate)",
            unit: "BPM",
            icon: "heart.fill",
            color: NervRestTheme.Arousal.elevated
        )
        BiometricCard(
            title: "HRV",
            value: "\(viewModel.hrv)",
            unit: "ms",
            icon: "waveform.path.ecg",
            color: NervRestTheme.Accent.secondary
        )
    }
    .padding(.horizontal, NervRestTheme.Spacing.md)
    .padding(.top, NervRestTheme.SectionSpacing.breathe)

    sessionButton
        .padding(.horizontal, NervRestTheme.Spacing.md)
        .padding(.top, NervRestTheme.SectionSpacing.breathe)
        .padding(.bottom, NervRestTheme.Spacing.xxl)
}
```

- [ ] **Step 3: Build and verify**

- [ ] **Step 4: Commit**

```bash
git add NervRest/UI/Screens/HomeScreen.swift
git commit -m "feat: layered background gradients + spacing rhythm on HomeScreen"
```

---

## Task 3: Glassmorphism on MismatchDetail

**Files:**
- Modify: `NervRest/UI/Screens/MismatchDetailScreen.swift`

- [ ] **Step 1: Replace comparison card background with glass**

Find the `comparisonCard` background and replace:

```swift
// OLD:
.fill(NervRestTheme.Surface.cardBackground)

// NEW:
.fill(.ultraThinMaterial)
.environment(\.colorScheme, .dark)
```

Keep the `.overlay` stroke but reduce opacity:
```swift
.stroke(NervRestTheme.Surface.cardBorder.opacity(0.4), lineWidth: 0.5)
```

- [ ] **Step 2: Build and verify**

- [ ] **Step 3: Commit**

```bash
git add NervRest/UI/Screens/MismatchDetailScreen.swift
git commit -m "feat: glassmorphism comparison card on MismatchDetail"
```

---

## Task 4: Gradient Cards on RampDown

**Files:**
- Modify: `NervRest/UI/Screens/RampDownScreen.swift`

- [ ] **Step 1: Replace flat card fill with subtle gradient**

In `suggestionCard`, replace the background:

```swift
// OLD:
.fill(NervRestTheme.Surface.cardBackground)

// NEW:
.fill(
    LinearGradient(
        gradient: Gradient(colors: [
            NervRestTheme.Surface.cardBackground,
            NervRestTheme.Surface.cardBackground.opacity(0.6)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
)
```

And reduce border stroke:
```swift
.stroke(NervRestTheme.Surface.cardBorder.opacity(0.3), lineWidth: 0.5)
```

- [ ] **Step 2: Build and verify**

- [ ] **Step 3: Commit**

```bash
git add NervRest/UI/Screens/RampDownScreen.swift
git commit -m "feat: gradient suggestion cards on RampDown"
```

---

## Task 5: Glassmorphism BiometricCard

**Files:**
- Modify: `NervRest/UI/Components/BiometricCard.swift`

- [ ] **Step 1: Replace flat fill with glass material**

```swift
// OLD:
.fill(NervRestTheme.Surface.cardBackground)

// NEW:
.fill(.ultraThinMaterial)
.environment(\.colorScheme, .dark)
```

- [ ] **Step 2: Build and verify**

- [ ] **Step 3: Commit**

```bash
git add NervRest/UI/Components/BiometricCard.swift
git commit -m "feat: glassmorphism BiometricCard"
```

---

## Task 6: Final Build, Push, and Verification

- [ ] **Step 1: Full clean build**

```bash
xcodebuild clean build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20
```
Expected: BUILD SUCCEEDED

- [ ] **Step 2: Run all tests**

```bash
xcodebuild test -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20
```
Expected: All tests PASS

- [ ] **Step 3: Visual spot-check**

- [ ] All text uses SF Pro (sharp letterforms, not bubbly rounded)
- [ ] ArousalGauge score number still uses SF Rounded (56pt heavy)
- [ ] HomeScreen background has visible depth (not flat single color)
- [ ] HomeScreen spacing has rhythm (tight groups, breathe between sections)
- [ ] MismatchDetail comparison card has glass translucency
- [ ] RampDown suggestion cards have subtle left-to-right gradient
- [ ] BiometricCards have glass effect

- [ ] **Step 4: Commit and push**

```bash
git add -A
git commit -m "chore: UI polish complete — SF Pro, layered backgrounds, glassmorphism"
git push origin master:main
```
