import SwiftUI

struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()

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
                VStack(spacing: NervRestTheme.Spacing.lg) {
                    // 1. Agent character
                    AgentCharacter(mood: viewModel.agentMood, size: 64)
                        .padding(.top, NervRestTheme.Spacing.xl)

                    // 2. Status message
                    Text(statusMessage)
                        .font(NervRestTheme.Fonts.body)
                        .foregroundColor(statusColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, NervRestTheme.Spacing.lg)

                    // 3. Hero gauge
                    ArousalGauge(
                        score: viewModel.arousalScore,
                        level: viewModel.arousalLevel,
                        heartRate: viewModel.heartRate,
                        hrv: viewModel.hrv
                    )

                    // 4. Stim score badge
                    StimScoreBadge(
                        appName: viewModel.currentApp,
                        score: viewModel.currentStimScore
                    )

                    // 5. Biometric cards
                    HStack(spacing: NervRestTheme.Spacing.md) {
                        BiometricCard(
                            title: "Heart Rate",
                            value: "\(viewModel.heartRate)",
                            unit: "BPM",
                            icon: "heart.fill",
                            color: NervRestTheme.Arousal.high
                        )
                        BiometricCard(
                            title: "HRV",
                            value: "\(viewModel.hrv)",
                            unit: "ms",
                            icon: "waveform.path.ecg",
                            color: NervRestTheme.Arousal.calm
                        )
                    }
                    .padding(.horizontal, NervRestTheme.Spacing.md)

                    // 6. Session button
                    sessionButton
                        .padding(.horizontal, NervRestTheme.Spacing.md)
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

            // Subtle radial glow anchored behind the gauge area
            RadialGradient(
                gradient: Gradient(colors: [
                    statusColor.opacity(0.08),
                    Color.clear
                ]),
                center: .center,
                startRadius: 40,
                endRadius: 300
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
                          ? NervRestTheme.Arousal.high
                          : NervRestTheme.Arousal.calm)
            )
            .shadow(
                color: (viewModel.isMonitoring
                        ? NervRestTheme.Arousal.high
                        : NervRestTheme.Arousal.calm).opacity(0.35),
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
        HomeScreen()
    }
}
#endif
