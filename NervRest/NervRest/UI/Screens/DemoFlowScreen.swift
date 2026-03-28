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
                RampDownScreen(viewModel: rampDownViewModel)
                    .transition(.move(edge: .trailing))

            case .recovery:
                VStack(spacing: 24) {
                    AgentCharacter(mood: "relieved", size: 80)
                    Text("Winding down nicely")
                        .font(NervRestTheme.Fonts.displayMedium)
                        .foregroundColor(NervRestTheme.Text.primary)
                    Text("Your nervous system is recovering")
                        .font(NervRestTheme.Fonts.body)
                        .foregroundColor(NervRestTheme.Text.secondary)
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
