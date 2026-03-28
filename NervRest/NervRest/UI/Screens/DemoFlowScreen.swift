import SwiftUI

/// Master orchestrator for the hackathon demo flow.
/// Manages the full sequence: TikTok scrolling → shield transition → shield overlay → ramp down → recovery.
struct DemoFlowScreen: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var rampDownViewModel: RampDownViewModel
    let alarmTime: String
    var onExit: (() -> Void)?

    @State private var demoPhase: DemoPhase = .tikTokScrolling
    @State private var transitionPhase: ShieldTransitionView.TransitionPhase = .hidden

    enum DemoPhase: Equatable {
        case tikTokScrolling
        case transitioning
        case shieldOverlay
        case rampDown
        case recovery
    }

    var body: some View {
        ZStack {
            switch demoPhase {
            case .tikTokScrolling, .transitioning:
                TikTokMockScreen(
                    arousalScore: homeViewModel.arousalScore,
                    heartRate: homeViewModel.heartRate,
                    hrv: homeViewModel.hrv,
                    currentApp: homeViewModel.currentApp,
                    isMonitoring: homeViewModel.isMonitoring
                )

                ShieldTransitionView(phase: $transitionPhase)

                // Exit button — always visible during TikTok scrolling
                if demoPhase == .tikTokScrolling {
                    VStack {
                        HStack {
                            Button {
                                onExit?()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Circle().fill(Color.black.opacity(0.5)))
                            }
                            .padding(.leading, NervRestTheme.Spacing.md)
                            .padding(.top, 60)
                            Spacer()
                        }
                        Spacer()
                    }
                }

            case .shieldOverlay:
                ShieldOverlayScreen(
                    arousalScore: homeViewModel.arousalScore,
                    currentHR: homeViewModel.heartRate,
                    alarmTime: alarmTime,
                    onShowAlternatives: {
                        rampDownViewModel.loadMockSuggestions()
                        withAnimation { demoPhase = .rampDown }
                    },
                    onFiveMoreMinutes: {
                        withAnimation {
                            demoPhase = .tikTokScrolling
                            transitionPhase = .hidden
                        }
                    }
                )
                .transition(.opacity)

            case .rampDown:
                RampDownScreen(
                    viewModel: rampDownViewModel,
                    onSuggestionTapped: { _ in
                        withAnimation { demoPhase = .recovery }
                    }
                )
                .transition(.move(edge: .trailing))

            case .recovery:
                VStack(spacing: NervRestTheme.Spacing.lg) {
                    Spacer()

                    AgentCharacter(mood: "relieved", size: 80)

                    Text("Winding down nicely")
                        .font(NervRestTheme.Fonts.displayMedium)
                        .foregroundColor(NervRestTheme.Text.primary)

                    Text("Your nervous system is recovering")
                        .font(NervRestTheme.Fonts.body)
                        .foregroundColor(NervRestTheme.Text.secondary)

                    Spacer()

                    Button {
                        onExit?()
                    } label: {
                        Text("Back to Home")
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
                    .padding(.bottom, NervRestTheme.SectionSpacing.breathe)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(NervRestTheme.Surface.background)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: demoPhase)
        .onChange(of: homeViewModel.arousalScore) { _, score in
            handleScoreChange(score)
        }
        .preferredColorScheme(.dark)
    }

    private func handleScoreChange(_ score: Double) {
        guard demoPhase == .tikTokScrolling else { return }

        if score >= 80 {
            demoPhase = .transitioning
            transitionPhase = .dimming

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { transitionPhase = .moonReveal }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation { transitionPhase = .shieldReady }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                withAnimation { demoPhase = .shieldOverlay }
            }
        }
    }
}
