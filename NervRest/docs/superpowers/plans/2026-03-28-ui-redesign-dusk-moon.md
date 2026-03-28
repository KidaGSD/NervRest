# NervRest UI Redesign — Dusk Moon Theme

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current teal/green/red placeholder UI with a scientifically-grounded warm color palette (Warmth/Ember/Dusk) and moon-phase mascot character, creating a visually cohesive "Midnight Observatory" experience.

**Architecture:** The redesign is theme-first: update `NervRestTheme.swift` colors, then replace the emoji `AgentCharacter` with moon-phase image assets, then cascade visual changes across all 4 screens and 9 components. No logic/data changes — purely UI layer.

**Tech Stack:** SwiftUI, SF Rounded typography (kept), Xcode asset catalog for moon PNGs

---

## Context for the Implementer

### Why these colors?
The palette is based on sleep science: blue light (460-480nm) suppresses melatonin. All colors are warm, dim, and desaturated — safe for evening use. Three families:
- **Warmth** — deep warm reds/browns (calm backgrounds, subtle accents)
- **Ember** — oranges (warning/elevated states, CTA highlights)
- **Dusk** — purples (primary palette: backgrounds, surfaces, text)

### What's the mascot?
7 moon-phase characters (kawaii style) in the Figma file. Full moon = calm, new moon = critical. They replace the current emoji-based `AgentCharacter` (😊😐😟😌).

### Current state
- Theme: `NervRestTheme.swift` — teal→red arousal spectrum, dark blue-gray surfaces
- Mascot: `AgentCharacter.swift` — emoji-based with mood→color mapping
- 4 screens: Home, MismatchDetail, RampDown, ShieldOverlay
- 9 components: AgentCharacter, ArousalGauge, BiometricCard, StimScoreBadge, 5 Island components

### Design System reference (Figma)
File: `5XRoxmBUA82ZFJMZDxwbcJ` — "Design System — Midnight Observatory" page (node 14:43)

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Modify | `UI/Theme/NervRestTheme.swift` | All color tokens, new accent colors |
| Modify | `UI/Theme/ColorHex.swift` | Existing hex extension (no change expected) |
| Modify | `UI/Components/AgentCharacter.swift` | Moon-phase Image instead of emoji Text |
| Create | `Assets.xcassets/MoonPhases/` | 7 moon PNG imagesets (@2x, @3x) |
| Modify | `UI/Screens/HomeScreen.swift` | Background glow, button colors, accent colors |
| Modify | `UI/Screens/ShieldOverlayScreen.swift` | Background gradient, glow color, button colors |
| Modify | `UI/Screens/MismatchDetailScreen.swift` | Delta colors, button color, warning tint |
| Modify | `UI/Screens/RampDownScreen.swift` | Accent bar color, button colors, text field border |
| Modify | `UI/Components/ArousalGauge.swift` | Gauge arc gradient, pill colors |
| Modify | `UI/Components/BiometricCard.swift` | Icon accent colors |
| Modify | `UI/Components/StimScoreBadge.swift` | Score color mapping |
| Modify | `UI/Components/IslandCompactLeading.swift` | Moon image instead of emoji |
| Modify | `UI/Components/IslandCompactTrailing.swift` | Score color |
| Modify | `UI/Components/IslandExpandedView.swift` | Moon image, accent colors |
| Modify | `UI/Components/IslandMinimal.swift` | Dot color |
| Modify | `UI/Components/IslandPreview.swift` | Preview colors |

---

## Task 1: Update Color Theme

**Files:**
- Modify: `NervRest/UI/Theme/NervRestTheme.swift`

- [ ] **Step 1: Write the failing test**

Create a simple compile-check test that references the new color names:

```swift
// tests/NervRestTests/ThemeTests.swift
import XCTest
@testable import NervRest

final class ThemeTests: XCTestCase {
    func testArousalColorsExist() {
        // These should compile and return non-nil colors
        _ = NervRestTheme.Arousal.calm
        _ = NervRestTheme.Arousal.moderate
        _ = NervRestTheme.Arousal.elevated
        _ = NervRestTheme.Arousal.high
        _ = NervRestTheme.Arousal.critical
    }

    func testSurfaceColorsExist() {
        _ = NervRestTheme.Surface.background
        _ = NervRestTheme.Surface.cardBackground
        _ = NervRestTheme.Surface.cardBorder
        _ = NervRestTheme.Surface.elevated
    }

    func testTextColorsExist() {
        _ = NervRestTheme.Text.primary
        _ = NervRestTheme.Text.secondary
        _ = NervRestTheme.Text.tertiary
    }

    func testAccentColorsExist() {
        _ = NervRestTheme.Accent.primary
        _ = NervRestTheme.Accent.secondary
        _ = NervRestTheme.Accent.glow
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `xcodebuild test -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:NervRestTests/ThemeTests 2>&1 | tail -20`
Expected: FAIL — `Accent` enum doesn't exist yet

- [ ] **Step 3: Update NervRestTheme.swift with new palette**

Replace the color values in `NervRest/UI/Theme/NervRestTheme.swift`:

```swift
import SwiftUI

enum NervRestTheme {

    // MARK: - Arousal Spectrum (Warmth → Ember, warm & sleep-safe)
    enum Arousal {
        static let calm = Color(hex: "#402959")         // dusk purple — relaxed
        static let moderate = Color(hex: "#52312F")     // warmth brown — mild
        static let elevated = Color(hex: "#D35200")     // ember orange — rising
        static let high = Color(hex: "#842B00")         // deep ember — high alert
        static let critical = Color(hex: "#E18050")     // bright ember — critical

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

    // MARK: - Surfaces (Dusk Observatory)
    enum Surface {
        static let background = Color(hex: "#171120")       // dusk 100
        static let cardBackground = Color(hex: "#281C38")   // dusk 200
        static let cardBorder = Color(hex: "#402959")       // dusk 300
        static let elevated = Color(hex: "#1C0508")         // warmth dark
    }

    // MARK: - Text (Dusk light end + Ember warm)
    enum Text {
        static let primary = Color(hex: "#CFBEDB")      // dusk 500 — headings/body
        static let secondary = Color(hex: "#A27DBC")    // dusk 400 — labels
        static let tertiary = Color(hex: "#52312F")     // warmth 500 — hints
    }

    // MARK: - Accent (for buttons, glows, interactive elements)
    enum Accent {
        static let primary = Color(hex: "#D35200")      // ember 300 — main CTA
        static let secondary = Color(hex: "#A27DBC")    // dusk 400 — secondary actions
        static let glow = Color(hex: "#F8C8A3")         // ember 500 — warm glow
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

- [ ] **Step 4: Run test to verify it passes**

Run: `xcodebuild test -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:NervRestTests/ThemeTests 2>&1 | tail -20`
Expected: PASS

- [ ] **Step 5: Build the full project to verify no compilation errors**

Run: `xcodebuild build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20`
Expected: BUILD SUCCEEDED (all existing screens still reference same Arousal/Surface/Text enums)

- [ ] **Step 6: Commit**

```bash
git add NervRest/UI/Theme/NervRestTheme.swift NervRestTests/ThemeTests.swift
git commit -m "feat: update color theme to Dusk/Warmth/Ember palette

Replace teal→red arousal spectrum with scientifically-grounded
warm, dim, desaturated colors. Add Accent enum for CTA colors.
Surfaces now use Dusk purples, text uses Dusk lights."
```

---

## Task 2: Add Moon Phase Assets

**Files:**
- Create: `NervRest/Assets.xcassets/MoonPhases/` (7 imagesets)

- [ ] **Step 1: Export moon phase PNGs from Figma**

Use the Figma MCP to export each moon phase rectangle as PNG. The 7 phases are:
- `Moon start 1` (id: 10:44) → `moon_full.png` (calm/happy)
- `Moon stage 2 1` (id: 10:48) → `moon_waning_gibbous.png`
- `Moon stage 3 1` (id: 10:47) → `moon_last_quarter.png` (concerned)
- `Moon stage 4 1` (id: 10:46) → `moon_waning_crescent.png`
- `Moon stage 6 1` (id: 10:45) → `moon_waxing_crescent.png` (worried)
- `Moon stage 7 1` (id: 10:50) → `moon_new.png` (critical)
- `Moon end 1` (id: 10:49) → `moon_new_dark.png` (relieved/recovering)

Alternative: If Figma export isn't available, create placeholder colored circles in Assets.xcassets that can be swapped later. Use SF Symbols `moon.fill`, `moon.zzz`, etc. as temporary stand-ins.

- [ ] **Step 2: Create asset catalog imagesets**

For each moon phase, create an imageset directory under `Assets.xcassets/MoonPhases/`:

```
Assets.xcassets/MoonPhases/
├── moon_full.imageset/
│   ├── Contents.json
│   └── moon_full.png
├── moon_waning_gibbous.imageset/
│   ├── Contents.json
│   └── moon_waning_gibbous.png
├── moon_last_quarter.imageset/
│   ├── Contents.json
│   └── moon_last_quarter.png
├── moon_waning_crescent.imageset/
│   ├── Contents.json
│   └── moon_waning_crescent.png
├── moon_waxing_crescent.imageset/
│   ├── Contents.json
│   └── moon_waxing_crescent.png
├── moon_new.imageset/
│   ├── Contents.json
│   └── moon_new.png
└── moon_new_dark.imageset/
    ├── Contents.json
    └── moon_new_dark.png
```

Each `Contents.json`:
```json
{
  "images": [
    { "filename": "moon_full.png", "idiom": "universal", "scale": "1x" },
    { "idiom": "universal", "scale": "2x" },
    { "idiom": "universal", "scale": "3x" }
  ],
  "info": { "version": 1, "author": "xcode" }
}
```

- [ ] **Step 3: Verify assets load**

Build the project to confirm assets are recognized:
Run: `xcodebuild build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add NervRest/Assets.xcassets/MoonPhases/
git commit -m "feat: add moon phase mascot assets from Figma design"
```

---

## Task 3: Replace AgentCharacter with Moon Mascot

**Files:**
- Modify: `NervRest/UI/Components/AgentCharacter.swift`

- [ ] **Step 1: Rewrite AgentCharacter to use moon images**

Replace the emoji-based view with image-based moon phases:

```swift
import SwiftUI

struct AgentCharacter: View {
    let mood: String  // "happy", "concerned", "worried", "relieved"
    let size: CGFloat

    var body: some View {
        ZStack {
            // Warm glow behind moon
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            glowColor.opacity(0.2),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: size * 0.2,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)

            Image(moonImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
    }

    private var moonImageName: String {
        switch mood {
        case "happy": return "moon_full"
        case "concerned": return "moon_last_quarter"
        case "worried": return "moon_waxing_crescent"
        case "relieved": return "moon_waning_gibbous"
        default: return "moon_waning_crescent"
        }
    }

    private var glowColor: Color {
        switch mood {
        case "happy": return NervRestTheme.Accent.glow
        case "concerned": return NervRestTheme.Arousal.elevated
        case "worried": return NervRestTheme.Arousal.high
        case "relieved": return NervRestTheme.Accent.glow
        default: return NervRestTheme.Text.secondary
        }
    }
}
```

- [ ] **Step 2: Build to verify**

Run: `xcodebuild build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add NervRest/UI/Components/AgentCharacter.swift
git commit -m "feat: replace emoji agent with moon-phase mascot

Moon phases map to mood states:
- happy → full moon (calm glow)
- concerned → last quarter
- worried → waxing crescent (warning glow)
- relieved → waning gibbous"
```

---

## Task 4: Update HomeScreen Colors

**Files:**
- Modify: `NervRest/UI/Screens/HomeScreen.swift`

- [ ] **Step 1: Update background glow and session button**

In `HomeScreen.swift`, update:

1. `backgroundLayer` — change radial glow opacity from `0.08` to `0.12` for the warmer colors to show more
2. `sessionButton` — change start button fill from `Arousal.calm` to `Accent.primary`, stop button from `Arousal.high` to `Arousal.elevated`
3. Button shadow colors to match new accent
4. Button text color from `Surface.background` to `.white` (since background is now very dark purple)

```swift
// In sessionButton, update the background and shadow:
.background(
    RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
        .fill(viewModel.isMonitoring
              ? NervRestTheme.Arousal.elevated
              : NervRestTheme.Accent.primary)
)
.shadow(
    color: (viewModel.isMonitoring
            ? NervRestTheme.Arousal.elevated
            : NervRestTheme.Accent.primary).opacity(0.35),
    radius: 10,
    y: 4
)
```

- [ ] **Step 2: Update BiometricCard colors in HomeScreen**

Change HR card color from `Arousal.high` to `Arousal.elevated` and HRV card from `Arousal.calm` to `Accent.secondary`:

```swift
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
```

- [ ] **Step 3: Build and verify**

Run: `xcodebuild build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add NervRest/UI/Screens/HomeScreen.swift
git commit -m "feat: update HomeScreen to Dusk/Ember color scheme"
```

---

## Task 5: Update ShieldOverlayScreen Colors

**Files:**
- Modify: `NervRest/UI/Screens/ShieldOverlayScreen.swift`

- [ ] **Step 1: Update cinematic background and glow**

Replace the dark blue-black gradient with warm Dusk tones:

```swift
// cinematicBackground — replace hex values:
Color(hex: "#0A0510")  // base: near-black with purple tint (was #050508)

// Gradient stops:
.init(color: Color(hex: "#171120").opacity(0.8), location: 0.0),  // dusk 100
.init(color: Color(hex: "#0A0510").opacity(1.0), location: 0.4),
.init(color: Color(hex: "#0A0510"), location: 1.0),

// agentGlow — change Arousal.high to Accent.glow:
NervRestTheme.Accent.glow.opacity(breatheGlow ? 0.12 : 0.06)
```

- [ ] **Step 2: Update buttons**

```swift
// Primary button: Arousal.calm → Accent.primary
.fill(NervRestTheme.Accent.primary)
.shadow(color: NervRestTheme.Accent.primary.opacity(0.5), ...)
```

- [ ] **Step 3: Build and verify**

Run: `xcodebuild build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add NervRest/UI/Screens/ShieldOverlayScreen.swift
git commit -m "feat: update ShieldOverlay with warm Dusk background and Ember accents"
```

---

## Task 6: Update MismatchDetailScreen Colors

**Files:**
- Modify: `NervRest/UI/Screens/MismatchDetailScreen.swift`

- [ ] **Step 1: Update delta and button colors**

```swift
// comparisonRow HR delta: Arousal.high → Arousal.elevated
deltaColor: NervRestTheme.Arousal.elevated

// comparisonRow HRV delta: Arousal.elevated → Accent.secondary
deltaColor: NervRestTheme.Accent.secondary

// reasonSection warning icon: Arousal.elevated → Accent.primary
.foregroundColor(NervRestTheme.Accent.primary)

// reasonSection background: Arousal.elevated.opacity(0.08) → Accent.primary.opacity(0.08)
.fill(NervRestTheme.Accent.primary.opacity(0.08))

// windDownButton: Arousal.calm → Accent.primary
.fill(NervRestTheme.Accent.primary)
.shadow(color: NervRestTheme.Accent.primary.opacity(0.4), ...)
```

- [ ] **Step 2: Build and verify**

Run: `xcodebuild build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add NervRest/UI/Screens/MismatchDetailScreen.swift
git commit -m "feat: update MismatchDetailScreen to Ember/Dusk colors"
```

---

## Task 7: Update RampDownScreen Colors

**Files:**
- Modify: `NervRest/UI/Screens/RampDownScreen.swift`

- [ ] **Step 1: Update accent bar, buttons, and text field**

```swift
// suggestionCard left accent bar: Arousal.calm → Accent.secondary
.fill(NervRestTheme.Accent.secondary)

// metricView HR color: Arousal.calm → Accent.secondary
color: NervRestTheme.Accent.secondary

// freeTextSection border focus: Arousal.calm → Accent.secondary
NervRestTheme.Accent.secondary.opacity(0.5)

// Send button: Arousal.calm → Accent.primary
.foregroundColor(NervRestTheme.Accent.primary)
```

- [ ] **Step 2: Build and verify**

Run: `xcodebuild build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add NervRest/UI/Screens/RampDownScreen.swift
git commit -m "feat: update RampDownScreen to Dusk accent colors"
```

---

## Task 8: Update ArousalGauge Colors

> **Note on BiometricCard and StimScoreBadge:** These components take `color` as a parameter (BiometricCard) or use `NervRestTheme.Arousal.color(for:)` (StimScoreBadge). They are **implicitly updated** by Task 1 (theme) and Task 4 (HomeScreen passes new colors). No direct changes needed, but verify visually in Task 10.

**Files:**
- Modify: `NervRest/UI/Components/ArousalGauge.swift`

- [ ] **Step 1: Update pill colors**

```swift
// biometricPills — HR pill: Arousal.high → Arousal.elevated
color: NervRestTheme.Arousal.elevated

// HRV pill: Arousal.calm → Accent.secondary
color: NervRestTheme.Accent.secondary
```

No other changes needed — the gauge already uses `level.swiftUIColor` which will pick up the new theme colors automatically.

- [ ] **Step 2: Build and verify**

Run: `xcodebuild build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add NervRest/UI/Components/ArousalGauge.swift
git commit -m "feat: update ArousalGauge pill colors to Ember/Dusk"
```

---

## Task 9: Update Island Components

> **Important:** Island components use hardcoded hex literals (not `NervRestTheme`) for widget-extension portability. Replace the old hex values with the new palette hex values inline. Do NOT refactor to use theme tokens — they must remain self-contained.

**Files:**
- Modify: `NervRest/UI/Components/IslandCompactLeading.swift`
- Modify: `NervRest/UI/Components/IslandCompactTrailing.swift`
- Modify: `NervRest/UI/Components/IslandMinimal.swift`
- Modify: `NervRest/UI/Components/IslandExpandedView.swift`
- Modify: `NervRest/UI/Components/IslandPreview.swift`

- [ ] **Step 1: Update IslandCompactLeading — replace emoji with moon image**

Replace the emoji `Text` with a moon `Image` (smaller size for Dynamic Island):

```swift
// Replace the Text(emoji) with:
Image(moonImageName(for: mood))
    .resizable()
    .aspectRatio(contentMode: .fit)
    .frame(width: 20, height: 20)
    .clipShape(Circle())
```

Add helper function:
```swift
private func moonImageName(for mood: String) -> String {
    switch mood {
    case "happy": return "moon_full"
    case "concerned": return "moon_last_quarter"
    case "worried": return "moon_waxing_crescent"
    case "relieved": return "moon_waning_gibbous"
    default: return "moon_waning_crescent"
    }
}
```

- [ ] **Step 2: Update IslandCompactTrailing — replace hex colors**

Replace the old teal→red hex literals with the new Dusk/Ember palette:

```swift
private var arousalColor: Color {
    switch arousalScore {
    case ..<3:   return Color(hex: "#402959") // calm — dusk purple
    case 3..<5:  return Color(hex: "#52312F") // moderate — warmth brown
    case 5..<7:  return Color(hex: "#D35200") // elevated — ember orange
    case 7..<9:  return Color(hex: "#842B00") // high — deep ember
    default:     return Color(hex: "#E18050") // critical — bright ember
    }
}
```

- [ ] **Step 3: Update IslandMinimal — replace hex colors**

Same hex replacement in `arousalColor`:

```swift
private var arousalColor: Color {
    switch arousalScore {
    case ..<3:   return Color(hex: "#402959") // calm
    case 3..<5:  return Color(hex: "#52312F") // moderate
    case 5..<7:  return Color(hex: "#D35200") // elevated
    case 7..<9:  return Color(hex: "#842B00") // high
    default:     return Color(hex: "#E18050") // critical
    }
}
```

- [ ] **Step 4: Update IslandExpandedView — replace hex colors + emoji**

This file has **multiple** hardcoded hex values and emoji. Replace all:

1. Replace `agentEmoji` Text with moon Image (28pt):
```swift
// Replace Text(agentEmoji) with:
Image(moonImageName(for: agentMood))
    .resizable()
    .aspectRatio(contentMode: .fit)
    .frame(width: 28, height: 28)
    .clipShape(Circle())
```

2. Add `moonImageName` helper (same as Step 1).

3. Replace `arousalColor` hex values (same as Step 2/3).

4. Replace biometric row hex colors:
```swift
// heartRate color: was "#E24B4A" / "#4CAF50"
.foregroundColor(heartRate > 75 ? Color(hex: "#D35200") : Color(hex: "#402959"))

// HRV color: was "#E24B4A" / "#4CAF50"
.foregroundColor(hrv < 35 ? Color(hex: "#D35200") : Color(hex: "#402959"))
```

5. Replace action button color:
```swift
// was "#1D9E75"
.background(Color(hex: "#D35200")) // ember — accent CTA
```

6. Remove the `agentEmoji` computed property (no longer used).

- [ ] **Step 5: Update IslandPreview — replace preview background hex**

```swift
// was Color(hex: "#0D1117")
.background(Color(hex: "#171120")) // dusk 100
```

- [ ] **Step 6: Build and verify**

Run: `xcodebuild build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10`
Expected: BUILD SUCCEEDED

- [ ] **Step 7: Commit**

```bash
git add NervRest/UI/Components/IslandCompactLeading.swift NervRest/UI/Components/IslandCompactTrailing.swift NervRest/UI/Components/IslandMinimal.swift NervRest/UI/Components/IslandExpandedView.swift NervRest/UI/Components/IslandPreview.swift
git commit -m "feat: update all Dynamic Island components with moon mascot and Dusk/Ember hex colors"
```

---

## Task 10: Final Build & Visual Verification

- [ ] **Step 1: Full clean build**

```bash
xcodebuild clean build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20
```
Expected: BUILD SUCCEEDED with 0 errors, 0 warnings

- [ ] **Step 2: Run all tests**

```bash
xcodebuild test -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20
```
Expected: All tests PASS

- [ ] **Step 3: Visual spot-check each preview**

Open Xcode, check SwiftUI previews for:
- [ ] HomeScreen — warm purple background, moon mascot, ember button
- [ ] ShieldOverlay — cinematic dark-purple gradient, glowing moon, ember CTA
- [ ] MismatchDetail — ember warning accents, purple cards
- [ ] RampDown — purple accent bars, ember send button
- [ ] ArousalGauge — purple/ember arc colors
- [ ] IslandPreview — moon in compact leading, ember dot in minimal

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "chore: UI redesign complete — Dusk Moon theme applied across all screens"
```
