# NervRest UI Polish — De-template & Typography Upgrade

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eliminate the "vibe coded / AI-generated" feel by introducing typographic contrast, layered backgrounds, varied card styles, and intentional spacing — making the app feel designed, not generated.

**Architecture:** Pure UI-layer changes. Update `NervRestTheme.swift` fonts, then cascade visual refinements across screens. No logic/data changes. Custom fonts bundled via Info.plist.

**Tech Stack:** SwiftUI, DM Serif Display + DM Sans (Google Fonts, OFL license), existing Dusk/Ember palette

---

## Context for the Implementer

### What's wrong now (the "template" signals)
1. **Every font is SF Rounded** — uniform `.rounded` design at every level screams auto-generated
2. **Flat single-color background** — `#171120` everywhere, no depth or layering
3. **Uniform 8pt grid spacing** — every gap is a mechanical multiple of 8, feels robotic
4. **Cards all look identical** — same `cardBackground` + `cardBorder` stroke pattern repeated everywhere
5. **No texture or depth** — surfaces feel flat, no grain, no subtle gradients between layers

### The fix (research-backed)
- **Typography**: DM Serif Display for headlines (warm, literary feel) + DM Sans for body/UI (clean, readable). Keep SF Rounded ONLY for numeric scores (gauge numbers).
- **Background**: Layer 2-3 radial gradients at different positions + optional subtle noise texture
- **Spacing**: Break the rigid 8pt grid — use 48pt between major sections, 12pt within groups, creating rhythm
- **Cards**: Mix container styles — some with glassmorphism, some full-bleed, some floating pills
- **Color restraint**: Use Ember accent sparingly (CTAs only), not on every interactive element

### Reference apps (what "good" looks like)
- **Oura Ring**: Serif headlines, dark backgrounds with subtle radial glows, minimal color usage
- **Calm**: Warm serif typography, nature textures, depth through layered transparency
- **Rise Sleep**: Clean data viz, intentional whitespace, typographic hierarchy

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `NervRest/Resources/Fonts/DMSerifDisplay-Regular.ttf` | Display font file |
| Create | `NervRest/Resources/Fonts/DMSans-Regular.ttf` | Body font file |
| Create | `NervRest/Resources/Fonts/DMSans-Medium.ttf` | Medium weight body |
| Create | `NervRest/Resources/Fonts/DMSans-SemiBold.ttf` | Semibold body |
| Create | `NervRest/Resources/Fonts/DMSans-Bold.ttf` | Bold body |
| Modify | `NervRest/Info.plist` | Register custom fonts via UIAppFonts |
| Modify | `UI/Theme/NervRestTheme.swift` | New font definitions + spacing adjustments |
| Modify | `UI/Screens/HomeScreen.swift` | Layered background, spacing rhythm |
| Modify | `UI/Screens/ShieldOverlayScreen.swift` | Typography upgrade |
| Modify | `UI/Screens/MismatchDetailScreen.swift` | Typography + card variation |
| Modify | `UI/Screens/RampDownScreen.swift` | Typography + card variation |
| Modify | `UI/Components/ArousalGauge.swift` | Score keeps SF Rounded, label gets DM Sans |
| Modify | `UI/Components/BiometricCard.swift` | Glassmorphism variant |
| Modify | `UI/Components/StimScoreBadge.swift` | DM Sans font |

---

## Task 1: Bundle Custom Fonts

**Files:**
- Create: `NervRest/Resources/Fonts/` (5 font files)
- Modify: `NervRest/Info.plist`

- [ ] **Step 1: Download DM Serif Display and DM Sans from Google Fonts**

```bash
cd /tmp
curl -L "https://fonts.google.com/download?family=DM+Serif+Display" -o dm-serif.zip
curl -L "https://fonts.google.com/download?family=DM+Sans" -o dm-sans.zip
unzip dm-serif.zip -d dm-serif
unzip dm-sans.zip -d dm-sans
```

- [ ] **Step 2: Copy font files to project**

```bash
mkdir -p NervRest/Resources/Fonts
cp dm-serif/DMSerifDisplay-Regular.ttf NervRest/Resources/Fonts/
cp dm-sans/static/DMSans-Regular.ttf NervRest/Resources/Fonts/
cp dm-sans/static/DMSans-Medium.ttf NervRest/Resources/Fonts/
cp dm-sans/static/DMSans-SemiBold.ttf NervRest/Resources/Fonts/
cp dm-sans/static/DMSans-Bold.ttf NervRest/Resources/Fonts/
```

- [ ] **Step 3: Register fonts in Info.plist**

Add `UIAppFonts` array to Info.plist:

```xml
<key>UIAppFonts</key>
<array>
    <string>DMSerifDisplay-Regular.ttf</string>
    <string>DMSans-Regular.ttf</string>
    <string>DMSans-Medium.ttf</string>
    <string>DMSans-SemiBold.ttf</string>
    <string>DMSans-Bold.ttf</string>
</array>
```

- [ ] **Step 4: Build to verify fonts load**

Run: `xcodebuild build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10`
Expected: BUILD SUCCEEDED

- [ ] **Step 5: Commit**

```bash
git add NervRest/Resources/ NervRest/Info.plist
git commit -m "feat: bundle DM Serif Display + DM Sans custom fonts"
```

---

## Task 2: Update Typography System

**Files:**
- Modify: `NervRest/UI/Theme/NervRestTheme.swift`

- [ ] **Step 1: Replace Fonts enum with dual-font system**

```swift
// MARK: - Typography (DM Serif Display + DM Sans — warm, intentional)
enum Fonts {
    // Display — DM Serif Display (warm serif for headlines)
    static let displayLarge = Font.custom("DMSerifDisplay-Regular", size: 40)
    static let displayMedium = Font.custom("DMSerifDisplay-Regular", size: 28)

    // UI — DM Sans (clean sans for body/UI)
    static let headline = Font.custom("DMSans-SemiBold", size: 17)
    static let body = Font.custom("DMSans-Regular", size: 15)
    static let caption = Font.custom("DMSans-Regular", size: 13)
    static let micro = Font.custom("DMSans-Medium", size: 11)

    // Score — keep SF Rounded for numeric data
    static let score = Font.system(size: 56, weight: .heavy, design: .rounded)

    // Fallback helper for dynamic sizing
    static func serif(_ size: CGFloat) -> Font {
        .custom("DMSerifDisplay-Regular", size: size)
    }
    static func sans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .bold: return .custom("DMSans-Bold", size: size)
        case .semibold: return .custom("DMSans-SemiBold", size: size)
        case .medium: return .custom("DMSans-Medium", size: size)
        default: return .custom("DMSans-Regular", size: size)
        }
    }
}
```

- [ ] **Step 2: Add spacing variation constants**

Add to the existing Spacing enum:

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
git commit -m "feat: introduce DM Serif Display + DM Sans typography system

Serif for display headlines, Sans for body/UI, SF Rounded only for
numeric scores. Add SectionSpacing for intentional rhythm."
```

---

## Task 3: Layered Background Component

**Files:**
- Modify: `NervRest/UI/Screens/HomeScreen.swift`

- [ ] **Step 1: Replace flat background with layered gradients**

Update `backgroundLayer` in HomeScreen.swift:

```swift
private var backgroundLayer: some View {
    ZStack {
        // Base
        NervRestTheme.Surface.background
            .ignoresSafeArea()

        // Layer 1: Warm radial glow from top-right (ambient warmth)
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

        // Layer 2: Status-colored glow behind gauge (contextual)
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

        // Layer 3: Subtle purple wash at bottom
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

- [ ] **Step 2: Update spacing rhythm**

Replace uniform `NervRestTheme.Spacing.lg` gaps in the main VStack with varied spacing:

```swift
VStack(spacing: 0) { // Manual spacing for rhythm
    AgentCharacter(mood: viewModel.agentMood, size: 64)
        .padding(.top, NervRestTheme.SectionSpacing.dramatic)

    Text(statusMessage)
        .font(NervRestTheme.Fonts.body)
        .foregroundColor(statusColor)
        .multilineTextAlignment(.center)
        .padding(.horizontal, NervRestTheme.Spacing.lg)
        .padding(.top, NervRestTheme.SectionSpacing.tight)

    ArousalGauge(...)
        .padding(.top, NervRestTheme.SectionSpacing.normal)

    StimScoreBadge(...)
        .padding(.top, NervRestTheme.SectionSpacing.tight)

    HStack(...) { /* BiometricCards */ }
        .padding(.top, NervRestTheme.SectionSpacing.breathe)

    sessionButton
        .padding(.top, NervRestTheme.SectionSpacing.breathe)
        .padding(.bottom, NervRestTheme.Spacing.xxl)
}
```

- [ ] **Step 3: Build and verify**

Run: `xcodebuild build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add NervRest/UI/Screens/HomeScreen.swift
git commit -m "feat: layered background gradients + intentional spacing rhythm on HomeScreen"
```

---

## Task 4: Update ShieldOverlay Typography

**Files:**
- Modify: `NervRest/UI/Screens/ShieldOverlayScreen.swift`

- [ ] **Step 1: Update title to serif font**

```swift
// titleSection — use serif display for dramatic effect
Text("Time to wind down")
    .font(NervRestTheme.Fonts.displayLarge)  // now DM Serif Display
    // rest stays the same
```

The font change happens automatically through the theme — just verify the displayLarge is used. No other changes needed since ShieldOverlay already has good cinematic design.

- [ ] **Step 2: Build and verify**

- [ ] **Step 3: Commit**

```bash
git add NervRest/UI/Screens/ShieldOverlayScreen.swift
git commit -m "feat: serif typography on ShieldOverlay title"
```

---

## Task 5: Update MismatchDetail Typography + Card Variation

**Files:**
- Modify: `NervRest/UI/Screens/MismatchDetailScreen.swift`

- [ ] **Step 1: Add glassmorphism to comparison card**

Replace the comparison card background with a glass effect:

```swift
.background(
    RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
        .fill(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
        .overlay(
            RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                .stroke(NervRestTheme.Surface.cardBorder.opacity(0.5), lineWidth: 0.5)
        )
)
```

- [ ] **Step 2: Title uses serif**

The title "Your body isn't resting" uses `.displayMedium` which is now DM Serif — automatic.

- [ ] **Step 3: Build and verify**

- [ ] **Step 4: Commit**

```bash
git add NervRest/UI/Screens/MismatchDetailScreen.swift
git commit -m "feat: glassmorphism comparison card + serif title on MismatchDetail"
```

---

## Task 6: Update RampDown Card Styles

**Files:**
- Modify: `NervRest/UI/Screens/RampDownScreen.swift`

- [ ] **Step 1: Differentiate suggestion card styles**

Add subtle gradient backgrounds to suggestion cards instead of flat fill:

```swift
// Replace flat cardBackground with subtle gradient per card
.background(
    RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
        .fill(
            LinearGradient(
                gradient: Gradient(colors: [
                    NervRestTheme.Surface.cardBackground,
                    NervRestTheme.Surface.cardBackground.opacity(0.7)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                .stroke(NervRestTheme.Surface.cardBorder.opacity(0.4), lineWidth: 0.5)
        )
)
```

- [ ] **Step 2: Build and verify**

- [ ] **Step 3: Commit**

```bash
git add NervRest/UI/Screens/RampDownScreen.swift
git commit -m "feat: gradient card backgrounds on RampDown suggestions"
```

---

## Task 7: Update BiometricCard with Glass Effect

**Files:**
- Modify: `NervRest/UI/Components/BiometricCard.swift`

- [ ] **Step 1: Replace flat card with glassmorphism**

```swift
// Replace flat cardBackground fill with:
.background(
    RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
        .fill(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
)
```

- [ ] **Step 2: Build and verify**

- [ ] **Step 3: Commit**

```bash
git add NervRest/UI/Components/BiometricCard.swift
git commit -m "feat: glassmorphism BiometricCard for depth variation"
```

---

## Task 8: Final Build & Visual Verification

- [ ] **Step 1: Full clean build**

```bash
xcodebuild clean build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20
```

- [ ] **Step 2: Run all tests**

```bash
xcodebuild test -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20
```

- [ ] **Step 3: Visual spot-check previews**

- [ ] HomeScreen — serif-free (only body text), layered gradients, varied spacing
- [ ] ShieldOverlay — serif "Time to wind down" title, cinematic feel
- [ ] MismatchDetail — glass comparison card, serif "Your body isn't resting"
- [ ] RampDown — gradient suggestion cards, serif "Let's wind down"
- [ ] ArousalGauge — SF Rounded score number, DM Sans labels
- [ ] BiometricCard — glass effect, no flat rectangle

- [ ] **Step 4: Commit and push**

```bash
git add -A
git commit -m "chore: UI polish complete — serif typography, layered backgrounds, glassmorphism cards"
git push origin master
```
