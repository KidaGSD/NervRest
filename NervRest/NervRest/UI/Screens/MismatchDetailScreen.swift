import SwiftUI

struct MismatchDetailScreen: View {
    @ObservedObject var viewModel: MismatchViewModel
    var onWindDown: () -> Void = {}

    init(viewModel: MismatchViewModel = MismatchViewModel(), onWindDown: @escaping () -> Void = {}) {
        self.viewModel = viewModel
        self.onWindDown = onWindDown
    }

    @State private var appearAnimation = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: NervRestTheme.Spacing.lg) {
                agentSection
                comparisonCard
                currentAppSection
                reasonSection
                windDownButton
            }
            .padding(.horizontal, NervRestTheme.Spacing.lg)
            .padding(.top, NervRestTheme.Spacing.xl)
            .padding(.bottom, NervRestTheme.Spacing.xxl)
        }
        .background(
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
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appearAnimation = true
            }
        }
    }

    // MARK: - Agent + Title

    private var agentSection: some View {
        VStack(spacing: NervRestTheme.Spacing.md) {
            AgentCharacter(mood: "worried", size: 80)
                .scaleEffect(appearAnimation ? 1.0 : 0.6)
                .opacity(appearAnimation ? 1.0 : 0.0)

            Text("Your body isn't resting")
                .font(NervRestTheme.Fonts.displayMedium)
                .foregroundColor(NervRestTheme.Text.primary)
                .multilineTextAlignment(.center)
                .opacity(appearAnimation ? 1.0 : 0.0)
                .offset(y: appearAnimation ? 0 : 12)
        }
        .padding(.bottom, NervRestTheme.Spacing.sm)
    }

    // MARK: - Comparison Card (HR + HRV side by side)

    private var comparisonCard: some View {
        VStack(spacing: 0) {
            // HR Row
            comparisonRow(
                icon: "heart.fill",
                label: "Heart Rate",
                currentValue: Int(viewModel.currentHR),
                baselineValue: Int(viewModel.baselineHR),
                unit: "BPM",
                deltaLabel: "\(Int(viewModel.hrElevationPercent))% elevated",
                deltaColor: NervRestTheme.Arousal.elevated,
                isUp: true
            )

            Divider()
                .background(NervRestTheme.Surface.cardBorder)

            // HRV Row
            comparisonRow(
                icon: "waveform.path.ecg",
                label: "HRV",
                currentValue: Int(viewModel.currentHRV),
                baselineValue: Int(viewModel.baselineHRV),
                unit: "ms",
                deltaLabel: "\(Int(viewModel.hrvDepressionPercent))% depressed",
                deltaColor: NervRestTheme.Accent.secondary,
                isUp: false
            )
        }
        .background(
            RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .overlay(
                    RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                        .stroke(NervRestTheme.Surface.cardBorder.opacity(0.4), lineWidth: 0.5)
                )
        )
        .opacity(appearAnimation ? 1.0 : 0.0)
        .offset(y: appearAnimation ? 0 : 20)
    }

    @ViewBuilder
    private func comparisonRow(
        icon: String,
        label: String,
        currentValue: Int,
        baselineValue: Int,
        unit: String,
        deltaLabel: String,
        deltaColor: Color,
        isUp: Bool
    ) -> some View {
        HStack(spacing: NervRestTheme.Spacing.md) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(deltaColor)
                .frame(width: 32)

            // Label + delta
            VStack(alignment: .leading, spacing: NervRestTheme.Spacing.xs) {
                Text(label)
                    .font(NervRestTheme.Fonts.caption)
                    .foregroundColor(NervRestTheme.Text.secondary)

                HStack(spacing: NervRestTheme.Spacing.xs) {
                    Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(deltaColor)

                    Text(deltaLabel)
                        .font(NervRestTheme.Fonts.micro)
                        .foregroundColor(deltaColor)
                }
            }

            Spacer()

            // Current vs baseline
            HStack(alignment: .firstTextBaseline, spacing: NervRestTheme.Spacing.sm) {
                VStack(spacing: 2) {
                    Text("\(currentValue)")
                        .font(NervRestTheme.Fonts.displayMedium)
                        .foregroundColor(NervRestTheme.Text.primary)

                    Text("now")
                        .font(NervRestTheme.Fonts.micro)
                        .foregroundColor(NervRestTheme.Text.tertiary)
                }

                Text("vs")
                    .font(NervRestTheme.Fonts.micro)
                    .foregroundColor(NervRestTheme.Text.tertiary)

                VStack(spacing: 2) {
                    Text("\(baselineValue)")
                        .font(NervRestTheme.Fonts.displayMedium)
                        .foregroundColor(NervRestTheme.Text.secondary)

                    Text("baseline")
                        .font(NervRestTheme.Fonts.micro)
                        .foregroundColor(NervRestTheme.Text.tertiary)
                }

                Text(unit)
                    .font(NervRestTheme.Fonts.micro)
                    .foregroundColor(NervRestTheme.Text.tertiary)
            }
        }
        .padding(NervRestTheme.Spacing.md)
    }

    // MARK: - Current App + Stim Score Badge

    private var currentAppSection: some View {
        HStack(spacing: NervRestTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: NervRestTheme.Spacing.xs) {
                Text("Current app")
                    .font(NervRestTheme.Fonts.caption)
                    .foregroundColor(NervRestTheme.Text.secondary)

                Text(viewModel.currentApp)
                    .font(NervRestTheme.Fonts.headline)
                    .foregroundColor(NervRestTheme.Text.primary)
            }

            Spacer()

            StimScoreBadge(appName: viewModel.currentApp, score: viewModel.stimScore)
        }
        .padding(NervRestTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                .fill(NervRestTheme.Surface.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                        .stroke(NervRestTheme.Surface.cardBorder, lineWidth: 1)
                )
        )
        .opacity(appearAnimation ? 1.0 : 0.0)
        .offset(y: appearAnimation ? 0 : 20)
    }

    // MARK: - Reason

    private var reasonSection: some View {
        HStack(spacing: NervRestTheme.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundColor(NervRestTheme.Accent.primary)

            Text(viewModel.reason)
                .font(NervRestTheme.Fonts.body)
                .foregroundColor(NervRestTheme.Text.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(NervRestTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: NervRestTheme.Radius.md)
                .fill(NervRestTheme.Accent.primary.opacity(0.08))
        )
        .opacity(appearAnimation ? 1.0 : 0.0)
    }

    // MARK: - CTA Button

    private var windDownButton: some View {
        Button(action: onWindDown) {
            HStack(spacing: NervRestTheme.Spacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))

                Text("Show me alternatives")
                    .font(NervRestTheme.Fonts.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, NervRestTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                    .fill(NervRestTheme.Accent.primary)
                    .shadow(
                        color: NervRestTheme.Accent.primary.opacity(0.4),
                        radius: 12,
                        y: 4
                    )
            )
        }
        .padding(.top, NervRestTheme.Spacing.sm)
        .opacity(appearAnimation ? 1.0 : 0.0)
        .offset(y: appearAnimation ? 0 : 16)
    }
}

// MARK: - Preview

#if DEBUG
struct MismatchDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        MismatchDetailScreen(viewModel: MismatchViewModel(), onWindDown: {})
            .preferredColorScheme(.dark)
    }
}
#endif
