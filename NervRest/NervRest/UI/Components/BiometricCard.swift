import SwiftUI

struct BiometricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: NervRestTheme.Spacing.sm) {
            // Header row: icon + title
            HStack(spacing: NervRestTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)

                Text(title)
                    .font(NervRestTheme.Fonts.caption)
                    .foregroundColor(NervRestTheme.Text.secondary)
            }

            // Value
            HStack(alignment: .firstTextBaseline, spacing: NervRestTheme.Spacing.xs) {
                Text(value)
                    .font(NervRestTheme.Fonts.displayMedium)
                    .foregroundColor(NervRestTheme.Text.primary)

                Text(unit)
                    .font(NervRestTheme.Fonts.caption)
                    .foregroundColor(NervRestTheme.Text.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(NervRestTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                .fill(NervRestTheme.Surface.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                        .stroke(NervRestTheme.Surface.cardBorder, lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview

#if DEBUG
struct BiometricCard_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: NervRestTheme.Spacing.md) {
            BiometricCard(
                title: "Heart Rate",
                value: "72",
                unit: "BPM",
                icon: "heart.fill",
                color: NervRestTheme.Arousal.high
            )
            BiometricCard(
                title: "HRV",
                value: "55",
                unit: "ms",
                icon: "waveform.path.ecg",
                color: NervRestTheme.Arousal.calm
            )
        }
        .padding()
        .background(NervRestTheme.Surface.background)
        .preferredColorScheme(.dark)
    }
}
#endif
