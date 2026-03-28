# NervRest V3 — Figma Team Design Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Figma team's V2 Dusk designs: onboarding flow, Luna chat UI, redesigned recommendations with cover art, and Luna splash screen — transforming NervRest from a dashboard app into a conversational companion.

**Architecture:** Add onboarding state management (UserDefaults flag), 3 new screens for onboarding, redesign LunaChatScreen with message bubbles, and upgrade RampDownScreen with rich media cards. All screens follow existing MVVM + NervRestTheme patterns.

**Tech Stack:** SwiftUI, SF Pro, existing Dusk/Ember palette, moon SVG assets in catalog

---

## Context for the Implementer

### What exists
- `NervRestTheme.swift` — complete Dusk/Ember color palette + SF Pro typography
- `AgentCharacter.swift` — moon mascot with mood-based SVG phases + glow
- `AppRouter.swift` — enum routing with `.home`, `.lunaChat`, `.rampDown`, etc.
- `LunaChatScreen.swift` + `LunaChatViewModel.swift` — basic Luna greeting (needs chat bubble redesign)
- `RampDownScreen.swift` + `RampDownViewModel.swift` — text-only suggestion cards (needs cover art redesign)
- Moon SVG assets in `Assets.xcassets/MoonPhases/` (7 phases)

### What to build (Figma reference: file `5XRoxmBUA82ZFJMZDxwbcJ`, page "App Screens — V2 Dusk")

| Priority | Screen | Figma node | Description |
|----------|--------|------------|-------------|
| 1 | Onboarding Splash | `2052:3342` | Luna centered on black→purple gradient |
| 2 | Onboarding Step 1 | `2052:3503` | "What helps you wind down?" 6-item grid |
| 3 | Onboarding Step 2 | `2052:2886` | "What content are you most interested in?" 6-item grid |
| 4 | Chat Greeting | `2038:432` | "Good Evening, CC" + "Chat with Luna" input |
| 5 | Chat Conversation | `2061:2649` | Message bubbles + Luna avatar + input bar |
| 6 | Recommendations | `2052:2492` | Cover art cards + score rings + "▶ 30min" + "Chat with Luna" CTA |
| 7 | Luna Splash | `2052:951` | Full-screen gradient + centered moon (loading/transition) |

### Design patterns from Figma
- **Background**: Black (#000) top → Dusk purple (#402959) bottom gradient (NOT flat #171120)
- **Onboarding cards**: Rounded glass cards in 2-column grid, dusk fill
- **Progress bar**: 3-segment horizontal bar at top
- **CTA button**: Full-width, deep purple fill (#402959), "Continue" / "Chat with Luna"
- **Chat bubbles**: User = right-aligned, dusk-tinted. Luna = left-aligned with small moon avatar
- **Recommendation cards**: Cover art image (left), title + subtitle + play button (right), score ring (top-right corner)

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `UI/Screens/OnboardingSplashScreen.swift` | Luna welcome with gradient bg |
| Create | `UI/Screens/OnboardingPreferencesScreen.swift` | 2-step grid selector (reusable for both steps) |
| Create | `Logic/ViewModels/OnboardingViewModel.swift` | Onboarding state, selections, persistence |
| Create | `Data/Models/UserPreferences.swift` | Wind-down + content preferences model |
| Modify | `NervRestApp.swift` | Route to onboarding if first launch |
| Modify | `UI/Navigation/AppRouter.swift` | Add `.onboarding` route |
| Modify | `UI/Screens/LunaChatScreen.swift` | Chat bubbles, Luna avatar, redesigned input |
| Modify | `Logic/ViewModels/LunaChatViewModel.swift` | Message array, send/receive |
| Modify | `UI/Screens/RampDownScreen.swift` | Cover art cards, score rings, play buttons |
| Modify | `Logic/ViewModels/RampDownViewModel.swift` | Cover image URLs, duration |
| Create | `UI/Screens/LunaSplashScreen.swift` | Full-screen gradient + moon loading |

---

## Task 1: Onboarding Data Model + ViewModel

**Files:**
- Create: `NervRest/Data/Models/UserPreferences.swift`
- Create: `NervRest/Logic/ViewModels/OnboardingViewModel.swift`

- [ ] **Step 1: Create UserPreferences model**

```swift
// NervRest/Data/Models/UserPreferences.swift
import Foundation

struct UserPreferences: Codable {
    var windDownMethods: Set<String>   // "Lo-fi music", "Nature sounds", etc.
    var contentInterests: Set<String>  // "Lo-fi music", "Sleep stories", etc.
    var hasCompletedOnboarding: Bool

    static let windDownOptions = [
        "Lo-fi music", "Nature sounds", "Sleep stories",
        "Slow TV", "Breathwork", "Podcast"
    ]

    static let contentOptions = [
        "Lo-fi music", "Nature sounds", "Sleep stories",
        "Slow TV", "Breathwork", "Podcast"
    ]

    static var empty: UserPreferences {
        UserPreferences(windDownMethods: [], contentInterests: [], hasCompletedOnboarding: false)
    }
}
```

- [ ] **Step 2: Create OnboardingViewModel**

```swift
// NervRest/Logic/ViewModels/OnboardingViewModel.swift
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0  // 0=splash, 1=wind-down, 2=content
    @Published var windDownSelections: Set<String> = []
    @Published var contentSelections: Set<String> = []

    let totalSteps = 3

    var canContinue: Bool {
        switch currentStep {
        case 0: return true
        case 1: return windDownSelections.count >= 3
        case 2: return contentSelections.count >= 3
        default: return false
        }
    }

    func toggleWindDown(_ item: String) {
        if windDownSelections.contains(item) {
            windDownSelections.remove(item)
        } else {
            windDownSelections.insert(item)
        }
    }

    func toggleContent(_ item: String) {
        if contentSelections.contains(item) {
            contentSelections.remove(item)
        } else {
            contentSelections.insert(item)
        }
    }

    func advance() {
        if currentStep < totalSteps - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        }
    }

    func completeOnboarding() {
        let prefs = UserPreferences(
            windDownMethods: windDownSelections,
            contentInterests: contentSelections,
            hasCompletedOnboarding: true
        )
        if let data = try? JSONEncoder().encode(prefs) {
            UserDefaults.standard.set(data, forKey: "userPreferences")
        }
    }

    static func hasCompletedOnboarding() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: "userPreferences"),
              let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return false
        }
        return prefs.hasCompletedOnboarding
    }
}
```

- [ ] **Step 3: Build to verify**

Run: `xcodebuild build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 17 Pro' 2>&1 | tail -10`

- [ ] **Step 4: Commit**

```bash
git add NervRest/Data/Models/UserPreferences.swift NervRest/Logic/ViewModels/OnboardingViewModel.swift
git commit -m "feat: add UserPreferences model + OnboardingViewModel"
```

---

## Task 2: Onboarding Splash Screen (Luna Welcome)

**Files:**
- Create: `NervRest/UI/Screens/OnboardingSplashScreen.swift`

- [ ] **Step 1: Create the splash screen matching Figma node 2052:3342**

Key design: Luna moon centered on a black→dusk purple vertical gradient. No text, no buttons — just the mascot with warm glow. Tapping or after 2s auto-advances.

```swift
// NervRest/UI/Screens/OnboardingSplashScreen.swift
import SwiftUI

struct OnboardingSplashScreen: View {
    var onContinue: () -> Void = {}

    @State private var moonAppeared = false
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            // Gradient background: black top → dusk purple bottom
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(hex: "#171120"),
                    Color(hex: "#402959").opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                // Luna moon with glow
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    NervRestTheme.Accent.glow.opacity(glowPulse ? 0.25 : 0.15),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 30,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)

                    Image("moon_waxing_crescent")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .scaleEffect(moonAppeared ? 1.0 : 0.3)
                        .opacity(moonAppeared ? 1.0 : 0.0)
                }

                Spacer()
                Spacer()
            }
        }
        .onTapGesture {
            onContinue()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                moonAppeared = true
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            // Auto-advance after 2.5s
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onContinue()
            }
        }
    }
}
```

- [ ] **Step 2: Build to verify**

- [ ] **Step 3: Commit**

```bash
git add NervRest/UI/Screens/OnboardingSplashScreen.swift
git commit -m "feat: add OnboardingSplashScreen with Luna gradient welcome"
```

---

## Task 3: Onboarding Preferences Screen (Reusable Grid)

**Files:**
- Create: `NervRest/UI/Screens/OnboardingPreferencesScreen.swift`

- [ ] **Step 1: Create the reusable preferences grid matching Figma nodes 2052:3503 and 2052:2886**

Key design: 3-segment progress bar at top. Title question + subtitle. 2-column grid of 6 glass cards. "Continue" button at bottom (deep purple). Reused for both "wind down" and "content" steps.

```swift
// NervRest/UI/Screens/OnboardingPreferencesScreen.swift
import SwiftUI

struct OnboardingPreferencesScreen: View {
    let title: String
    let subtitle: String
    let options: [String]
    @Binding var selections: Set<String>
    let currentStep: Int      // 1 or 2 (of 3 total)
    let totalSteps: Int
    let minSelections: Int
    var onContinue: () -> Void = {}

    @State private var appeared = false

    var body: some View {
        ZStack {
            // Background: same gradient as splash
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(hex: "#171120"),
                    Color(hex: "#402959").opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                progressBar
                    .padding(.top, NervRestTheme.Spacing.lg)
                    .padding(.horizontal, NervRestTheme.Spacing.lg)

                // Title
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(NervRestTheme.Text.primary)
                    .multilineTextAlignment(.center)
                    .padding(.top, NervRestTheme.SectionSpacing.breathe)
                    .padding(.horizontal, NervRestTheme.Spacing.lg)

                // Subtitle
                Text(subtitle)
                    .font(NervRestTheme.Fonts.body)
                    .foregroundColor(NervRestTheme.Text.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, NervRestTheme.Spacing.sm)
                    .padding(.horizontal, NervRestTheme.Spacing.xl)

                // Grid
                optionsGrid
                    .padding(.top, NervRestTheme.SectionSpacing.breathe)
                    .padding(.horizontal, NervRestTheme.Spacing.lg)

                Spacer()

                // Continue button
                Button(action: onContinue) {
                    Text("Continue")
                        .font(NervRestTheme.Fonts.headline)
                        .foregroundColor(selections.count >= minSelections ? .white : NervRestTheme.Text.tertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, NervRestTheme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                                .fill(selections.count >= minSelections
                                      ? NervRestTheme.Surface.cardBorder
                                      : NervRestTheme.Surface.cardBackground)
                        )
                }
                .disabled(selections.count < minSelections)
                .padding(.horizontal, NervRestTheme.Spacing.lg)
                .padding(.bottom, NervRestTheme.SectionSpacing.breathe)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appeared = true }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 2)
                    .fill(step <= currentStep ? Color.white : Color.white.opacity(0.2))
                    .frame(height: 3)
            }
        }
    }

    // MARK: - Options Grid

    private var optionsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: NervRestTheme.Spacing.md),
            GridItem(.flexible(), spacing: NervRestTheme.Spacing.md)
        ], spacing: NervRestTheme.Spacing.md) {
            ForEach(Array(options.enumerated()), id: \.element) { index, option in
                optionCard(option, index: index)
            }
        }
    }

    private func optionCard(_ option: String, index: Int) -> some View {
        let isSelected = selections.contains(option)
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if isSelected {
                    selections.remove(option)
                } else {
                    selections.insert(option)
                }
            }
        } label: {
            VStack {
                Spacer()
                Text(option)
                    .font(NervRestTheme.Fonts.body)
                    .foregroundColor(NervRestTheme.Text.primary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                    .fill(isSelected
                          ? NervRestTheme.Surface.cardBorder.opacity(0.6)
                          : NervRestTheme.Surface.cardBackground.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                            .stroke(isSelected
                                    ? NervRestTheme.Accent.secondary.opacity(0.5)
                                    : Color.white.opacity(0.08),
                                    lineWidth: isSelected ? 1.5 : 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.08), value: appeared)
    }
}
```

- [ ] **Step 2: Build to verify**

- [ ] **Step 3: Commit**

```bash
git add NervRest/UI/Screens/OnboardingPreferencesScreen.swift
git commit -m "feat: add OnboardingPreferencesScreen with 2-column grid selector"
```

---

## Task 4: Wire Onboarding into App Navigation

**Files:**
- Modify: `NervRest/NervRestApp.swift`

- [ ] **Step 1: Add onboarding flow to app entry**

Read `NervRestApp.swift` first. Add an `@AppStorage` flag to check if onboarding is complete. If not, show the onboarding flow instead of the main app.

The onboarding flow is a local `@State` machine (splash → step1 → step2 → main app). It does NOT use `AppRouter` — it's a pre-navigation flow.

Add this to the `NervRestApp` struct:

```swift
@State private var showOnboarding = !OnboardingViewModel.hasCompletedOnboarding()
@StateObject private var onboardingVM = OnboardingViewModel()
```

In the `body`, wrap the existing `NavigationStack` with a conditional:

```swift
if showOnboarding {
    onboardingFlow
} else {
    // existing NavigationStack content
}
```

Add the `onboardingFlow` computed property:

```swift
@ViewBuilder
private var onboardingFlow: some View {
    switch onboardingVM.currentStep {
    case 0:
        OnboardingSplashScreen {
            onboardingVM.advance()
        }
    case 1:
        OnboardingPreferencesScreen(
            title: "What helps you wind down?",
            subtitle: "Select at least 3 forms that help the most",
            options: UserPreferences.windDownOptions,
            selections: $onboardingVM.windDownSelections,
            currentStep: 1,
            totalSteps: 3,
            minSelections: 3
        ) {
            onboardingVM.advance()
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    case 2:
        OnboardingPreferencesScreen(
            title: "What content are you most interested in?",
            subtitle: "Select at least 3 topics you are interested in",
            options: UserPreferences.contentOptions,
            selections: $onboardingVM.contentSelections,
            currentStep: 2,
            totalSteps: 3,
            minSelections: 3
        ) {
            onboardingVM.completeOnboarding()
            withAnimation(.easeInOut(duration: 0.5)) {
                showOnboarding = false
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    default:
        EmptyView()
    }
}
```

- [ ] **Step 2: Build and verify**

- [ ] **Step 3: Commit**

```bash
git add NervRest/NervRestApp.swift
git commit -m "feat: wire onboarding flow into app entry — splash + 2-step preferences"
```

---

## Task 5: Redesign Luna Chat with Message Bubbles

**Files:**
- Modify: `NervRest/Logic/ViewModels/LunaChatViewModel.swift`
- Modify: `NervRest/UI/Screens/LunaChatScreen.swift`

- [ ] **Step 1: Add message model and array to LunaChatViewModel**

Read `LunaChatViewModel.swift` first. Add a `ChatMessage` struct and messages array:

```swift
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
}
```

Add to the ViewModel:
```swift
@Published var messages: [ChatMessage] = []

func sendMessage() {
    let text = inputText.trimmingCharacters(in: .whitespaces)
    guard !text.isEmpty else { return }
    messages.append(ChatMessage(text: text, isUser: true))
    inputText = ""

    // Simulate Luna response after delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
        self?.messages.append(ChatMessage(
            text: "I hear you. Let me find something calming for you.",
            isUser: false
        ))
    }
}
```

- [ ] **Step 2: Redesign LunaChatScreen to match Figma nodes 2038:432 and 2061:2649**

Read `LunaChatScreen.swift` first. Replace the body with:

```swift
var body: some View {
    ZStack {
        NervRestTheme.Surface.background.ignoresSafeArea()

        VStack(spacing: 0) {
            // Back button
            HStack {
                Button("< Chat") {
                    // pop navigation
                }
                .font(NervRestTheme.Fonts.body)
                .foregroundColor(NervRestTheme.Accent.secondary)
                Spacer()
            }
            .padding(.horizontal, NervRestTheme.Spacing.md)
            .padding(.top, NervRestTheme.Spacing.sm)

            if viewModel.messages.isEmpty {
                // Greeting state (Figma: 2038:432)
                Spacer()
                greetingView
                Spacer()
            } else {
                // Conversation state (Figma: 2061:2649)
                Text(viewModel.greeting)
                    .font(NervRestTheme.Fonts.displayMedium)
                    .foregroundColor(NervRestTheme.Text.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, NervRestTheme.Spacing.lg)
                    .padding(.top, NervRestTheme.Spacing.md)

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: NervRestTheme.Spacing.md) {
                            ForEach(viewModel.messages) { message in
                                messageBubble(message)
                            }
                        }
                        .padding(.horizontal, NervRestTheme.Spacing.lg)
                        .padding(.top, NervRestTheme.Spacing.md)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let last = viewModel.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input bar
            inputBar
                .padding(.horizontal, NervRestTheme.Spacing.md)
                .padding(.bottom, NervRestTheme.Spacing.md)
        }
    }
    .preferredColorScheme(.dark)
}
```

Add the message bubble view:
```swift
@ViewBuilder
private func messageBubble(_ message: ChatMessage) -> some View {
    HStack(alignment: .top, spacing: 8) {
        if !message.isUser {
            // Luna avatar
            Image("moon_waxing_crescent")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .clipShape(Circle())
        }

        Text(message.text)
            .font(NervRestTheme.Fonts.body)
            .foregroundColor(NervRestTheme.Text.primary)
            .padding(.horizontal, NervRestTheme.Spacing.md)
            .padding(.vertical, NervRestTheme.Spacing.sm + 2)
            .background(
                RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                    .fill(message.isUser
                          ? NervRestTheme.Surface.cardBorder.opacity(0.5)
                          : NervRestTheme.Surface.cardBackground)
            )
            .frame(maxWidth: 260, alignment: message.isUser ? .trailing : .leading)
    }
    .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
    .id(message.id)
}
```

Add the input bar:
```swift
private var inputBar: some View {
    HStack(spacing: NervRestTheme.Spacing.sm) {
        TextField(viewModel.messages.isEmpty ? "Chat with Luna" : "What are you looking for?",
                  text: $viewModel.inputText)
            .font(NervRestTheme.Fonts.body)
            .foregroundColor(NervRestTheme.Text.primary)
            .padding(.horizontal, NervRestTheme.Spacing.md)
            .padding(.vertical, NervRestTheme.Spacing.sm + 2)
            .background(
                RoundedRectangle(cornerRadius: NervRestTheme.Radius.full)
                    .fill(NervRestTheme.Surface.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: NervRestTheme.Radius.full)
                            .stroke(NervRestTheme.Surface.cardBorder.opacity(0.4), lineWidth: 0.5)
                    )
            )
            .submitLabel(.send)
            .onSubmit { viewModel.sendMessage() }

        if !viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty {
            Button { viewModel.sendMessage() } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(NervRestTheme.Accent.secondary)
            }
            .transition(.scale.combined(with: .opacity))
        }
    }
}
```

- [ ] **Step 3: Build and verify**

- [ ] **Step 4: Commit**

```bash
git add NervRest/Logic/ViewModels/LunaChatViewModel.swift NervRest/UI/Screens/LunaChatScreen.swift
git commit -m "feat: redesign Luna chat with message bubbles, avatar, and conversation state"
```

---

## Task 6: Redesign Recommendations with Cover Art

**Files:**
- Modify: `NervRest/UI/Screens/RampDownScreen.swift`
- Modify: `NervRest/Logic/ViewModels/RampDownViewModel.swift`
- Modify: `NervRest/Data/Models/RampDownSuggestion.swift`

- [ ] **Step 1: Add cover image and duration to RampDownSuggestion model**

Read `RampDownSuggestion.swift`. Add two fields:

```swift
var coverImageName: String   // SF Symbol or asset name
var durationMinutes: Int     // e.g. 30
```

- [ ] **Step 2: Update RampDownViewModel mock data**

Read `RampDownViewModel.swift`. Update `loadMockSuggestions()` to include cover images and duration:

```swift
suggestions = [
    RampDownSuggestion(
        id: UUID(), fromApp: "TikTok", toApp: "Podcast",
        toAppStimScore: 2.1, predictedHRDrop: 18,
        estimatedMinutesToCalm: 15, deepLinkURL: nil,
        coverImageName: "headphones", durationMinutes: 30
    ),
    RampDownSuggestion(
        id: UUID(), fromApp: "TikTok", toApp: "Youtube",
        toAppStimScore: 3.4, predictedHRDrop: 12,
        estimatedMinutesToCalm: 15, deepLinkURL: nil,
        coverImageName: "play.rectangle.fill", durationMinutes: 30
    ),
    RampDownSuggestion(
        id: UUID(), fromApp: "TikTok", toApp: "Apple Music",
        toAppStimScore: 1.2, predictedHRDrop: 22,
        estimatedMinutesToCalm: 8, deepLinkURL: nil,
        coverImageName: "music.note", durationMinutes: 30
    ),
]
```

- [ ] **Step 3: Redesign suggestion cards to match Figma node 2052:2492**

Read `RampDownScreen.swift`. Replace `suggestionCard` with rich media cards:

```swift
private func suggestionCard(suggestion: RampDownSuggestion, index: Int) -> some View {
    Button {
        onSuggestionTapped(suggestion)
    } label: {
        HStack(spacing: NervRestTheme.Spacing.md) {
            // Cover art placeholder (SF Symbol in colored square)
            ZStack {
                RoundedRectangle(cornerRadius: NervRestTheme.Radius.md)
                    .fill(NervRestTheme.Surface.cardBorder.opacity(0.3))
                    .frame(width: 80, height: 80)
                Image(systemName: suggestion.coverImageName)
                    .font(.system(size: 28))
                    .foregroundColor(NervRestTheme.Accent.secondary)
            }

            // Info
            VStack(alignment: .leading, spacing: NervRestTheme.Spacing.xs) {
                Text(suggestion.toApp)
                    .font(NervRestTheme.Fonts.headline)
                    .foregroundColor(NervRestTheme.Text.primary)

                Text("\(suggestion.estimatedMinutesToCalm)m to calm")
                    .font(NervRestTheme.Fonts.caption)
                    .foregroundColor(NervRestTheme.Text.secondary)

                // Play button pill
                HStack(spacing: 4) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 10))
                    Text("\(suggestion.durationMinutes)min")
                        .font(NervRestTheme.Fonts.caption)
                }
                .foregroundColor(NervRestTheme.Accent.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule().fill(NervRestTheme.Accent.secondary.opacity(0.15))
                )
            }

            Spacer()

            // Score ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 2.5)
                    .frame(width: 36, height: 36)
                Circle()
                    .trim(from: 0, to: suggestion.toAppStimScore / 10.0)
                    .stroke(NervRestTheme.Accent.secondary, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(suggestion.toAppStimScore * 10))")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(NervRestTheme.Text.primary)
            }
        }
        .padding(NervRestTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                .fill(
                    LinearGradient(
                        colors: [NervRestTheme.Surface.cardBackground, NervRestTheme.Surface.cardBackground.opacity(0.6)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                        .stroke(NervRestTheme.Surface.cardBorder.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
    .buttonStyle(.plain)
}
```

- [ ] **Step 4: Add "Chat with Luna" CTA at bottom**

After the suggestions section and free text section, add a divider and CTA:

```swift
// After freeTextSection, add:
HStack {
    Rectangle().fill(NervRestTheme.Text.tertiary.opacity(0.3)).frame(height: 0.5)
    Text("Or")
        .font(NervRestTheme.Fonts.caption)
        .foregroundColor(NervRestTheme.Text.tertiary)
    Rectangle().fill(NervRestTheme.Text.tertiary.opacity(0.3)).frame(height: 0.5)
}
.padding(.horizontal, NervRestTheme.Spacing.lg)

Button {
    // Navigate to Luna chat
} label: {
    Text("Chat with Luna")
        .font(NervRestTheme.Fonts.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, NervRestTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                .fill(NervRestTheme.Accent.secondary)
        )
}
.padding(.horizontal, NervRestTheme.Spacing.lg)
```

- [ ] **Step 5: Build and verify**

- [ ] **Step 6: Commit**

```bash
git add NervRest/Data/Models/RampDownSuggestion.swift NervRest/Logic/ViewModels/RampDownViewModel.swift NervRest/UI/Screens/RampDownScreen.swift
git commit -m "feat: redesign recommendations with cover art, score rings, play buttons, Chat with Luna CTA"
```

---

## Task 7: Luna Splash/Loading Screen

**Files:**
- Create: `NervRest/UI/Screens/LunaSplashScreen.swift`

- [ ] **Step 1: Create the loading screen matching Figma node 2052:951**

This is a reusable full-screen transition shown during loading or between states. Same gradient as onboarding splash but can be used anywhere.

```swift
// NervRest/UI/Screens/LunaSplashScreen.swift
import SwiftUI

struct LunaSplashScreen: View {
    @State private var moonScale: CGFloat = 0.5
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(hex: "#171120"),
                    Color(hex: "#402959").opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                NervRestTheme.Accent.glow.opacity(glowPulse ? 0.3 : 0.15),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)

                Image("moon_waxing_crescent")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .scaleEffect(moonScale)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
                moonScale = 1.0
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}
```

- [ ] **Step 2: Build and verify**

- [ ] **Step 3: Commit**

```bash
git add NervRest/UI/Screens/LunaSplashScreen.swift
git commit -m "feat: add LunaSplashScreen with gradient background + breathing moon glow"
```

---

## Task 8: Final Build, Push, and Verification

- [ ] **Step 1: Full clean build**

```bash
xcodebuild clean build -project NervRest.xcodeproj -scheme NervRest -destination 'platform=iOS Simulator,name=iPhone 17 Pro' 2>&1 | tail -20
```

- [ ] **Step 2: Visual spot-check**

- [ ] First launch shows onboarding splash (Luna + gradient)
- [ ] Tap → "What helps you wind down?" with 6 grid cards
- [ ] Select 3+ → "Continue" button activates
- [ ] Tap → "What content are you most interested in?" same grid
- [ ] Complete → main app (onboarding doesn't show again on relaunch)
- [ ] Luna chat shows greeting + input → typing sends message → bubbles appear
- [ ] Recommendations show cover art + score rings + play buttons + "Chat with Luna"
- [ ] LunaSplashScreen works as standalone view

- [ ] **Step 3: Commit and push**

```bash
git add -A
git commit -m "chore: V3 implementation complete — onboarding, chat bubbles, rich recommendations"
git push origin master:main
```
