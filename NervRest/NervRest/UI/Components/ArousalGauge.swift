import SwiftUI

struct ArousalGauge: View {
    let score: Double
    let level: ArousalLevel
    let heartRate: Int
    let hrv: Int

    @State private var animatedProgress: Double = 0

    private var levelLabel: String {
        switch level {
        case .calm: return "Calm"
        case .moderate: return "Moderate"
        case .elevated: return "Elevated"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }

    private var levelColor: Color {
        level.swiftUIColor
    }

    /// Normalized progress [0, 1] for the arc.
    private var targetProgress: Double {
        min(max(score / 10.0, 0), 1)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: NervRestTheme.Spacing.lg) {
            gaugeRing
            biometricPills
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                animatedProgress = targetProgress
            }
        }
        .onChange(of: score) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                animatedProgress = targetProgress
            }
        }
    }

    // MARK: - Gauge Ring

    private var gaugeRing: some View {
        ZStack {
            // Track ring (dim background arc)
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(
                    NervRestTheme.Surface.cardBorder,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(135))

            // Filled arc
            Circle()
                .trim(from: 0, to: animatedProgress * 0.75)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            levelColor.opacity(0.6),
                            levelColor
                        ]),
                        center: .center,
                        startAngle: .degrees(135),
                        endAngle: .degrees(135 + 270 * animatedProgress)
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(135))
                .shadow(color: levelColor.opacity(0.5), radius: 8)

            // Center content
            VStack(spacing: NervRestTheme.Spacing.xs) {
                Text(String(format: "%.1f", score))
                    .font(NervRestTheme.Fonts.score)
                    .foregroundColor(NervRestTheme.Text.primary)

                Text(levelLabel.uppercased())
                    .font(NervRestTheme.Fonts.micro)
                    .tracking(1.5)
                    .foregroundColor(levelColor)
            }
        }
        .frame(width: 220, height: 220)
    }

    // MARK: - Biometric Pills

    private var biometricPills: some View {
        HStack(spacing: NervRestTheme.Spacing.md) {
            pillView(
                icon: "heart.fill",
                value: "\(heartRate)",
                unit: "BPM",
                color: NervRestTheme.Arousal.high,
                isPulsing: heartRate > 80
            )

            pillView(
                icon: "waveform.path.ecg",
                value: "\(hrv)",
                unit: "ms",
                color: NervRestTheme.Arousal.calm,
                isPulsing: false
            )
        }
    }

    @ViewBuilder
    private func pillView(
        icon: String,
        value: String,
        unit: String,
        color: Color,
        isPulsing: Bool
    ) -> some View {
        HStack(spacing: NervRestTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
                .scaleEffect(isPulsing ? 1.15 : 1.0)
                .animation(
                    isPulsing
                        ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                        : .default,
                    value: isPulsing
                )

            Text(value)
                .font(NervRestTheme.Fonts.headline)
                .foregroundColor(NervRestTheme.Text.primary)

            Text(unit)
                .font(NervRestTheme.Fonts.micro)
                .foregroundColor(NervRestTheme.Text.secondary)
        }
        .padding(.horizontal, NervRestTheme.Spacing.md)
        .padding(.vertical, NervRestTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: NervRestTheme.Radius.full)
                .fill(NervRestTheme.Surface.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: NervRestTheme.Radius.full)
                        .stroke(NervRestTheme.Surface.cardBorder, lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview

#if DEBUG
struct ArousalGauge_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            NervRestTheme.Surface.background.ignoresSafeArea()
            ArousalGauge(score: 6.2, level: .elevated, heartRate: 82, hrv: 48)
        }
        .preferredColorScheme(.dark)
    }
}
#endif
