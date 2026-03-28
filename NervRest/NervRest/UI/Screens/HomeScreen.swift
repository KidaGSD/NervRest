import SwiftUI

struct HomeScreen: View {
    @ObservedObject var viewModel: HomeViewModel

    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
    }

    // MARK: - Status Message

    private var statusMessage: String {
        switch viewModel.arousalLevel {
        case .calm:
            return "Your nervous system is relaxed."
        case .moderate:
            return "Mild stimulation detected."
        case .elevated:
            return "Consider a short break soon."
        case .high:
            return "High arousal -- time to wind down."
        case .critical:
            return "Take a break. Your body needs rest."
        }
    }

    private var statusColor: Color {
        viewModel.arousalLevel.swiftUIColor
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Night-sky background
            backgroundLayer

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // 1. Agent character
                    AgentCharacter(mood: viewModel.agentMood, size: 64)
                        .padding(.top, NervRestTheme.SectionSpacing.dramatic)

                    // 2. Status message
                    Text(statusMessage)
                        .font(NervRestTheme.Fonts.body)
                        .foregroundColor(statusColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, NervRestTheme.Spacing.lg)
                        .padding(.top, NervRestTheme.SectionSpacing.tight)

                    // 3. Hero gauge
                    ArousalGauge(
                        score: viewModel.arousalScore,
                        level: viewModel.arousalLevel,
                        heartRate: viewModel.heartRate,
                        hrv: viewModel.hrv
                    )
                    .padding(.top, NervRestTheme.SectionSpacing.normal)

                    // 4. Stim score badge
                    StimScoreBadge(
                        appName: viewModel.currentApp,
                        score: viewModel.currentStimScore
                    )
                    .padding(.top, NervRestTheme.SectionSpacing.tight)

                    // 5. Biometric cards
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

                    // 6. Session button
                    sessionButton
                        .padding(.horizontal, NervRestTheme.Spacing.md)
                        .padding(.top, NervRestTheme.SectionSpacing.breathe)
                        .padding(.bottom, NervRestTheme.Spacing.xxl)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZStack {
            NervRestTheme.Surface.background
                .ignoresSafeArea()

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

    // MARK: - Session Button

    private var sessionButton: some View {
        Button {
            if viewModel.isMonitoring {
                viewModel.stopMonitoring()
            } else {
                viewModel.startMonitoring()
            }
        } label: {
            HStack(spacing: NervRestTheme.Spacing.sm) {
                Image(systemName: viewModel.isMonitoring ? "stop.fill" : "play.fill")
                    .font(.system(size: 14, weight: .bold))

                Text(viewModel.isMonitoring ? "Stop Session" : "Start Session")
                    .font(NervRestTheme.Fonts.headline)
            }
            .foregroundColor(NervRestTheme.Surface.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, NervRestTheme.Spacing.md)
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
        }
    }
}

// MARK: - Preview

#if DEBUG
struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(viewModel: HomeViewModel())
    }
}
#endif
