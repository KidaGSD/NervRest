import SwiftUI

struct StimScoreBadge: View {
    let appName: String
    let score: Double

    private var scoreColor: Color {
        NervRestTheme.Arousal.color(for: score)
    }

    var body: some View {
        HStack(spacing: NervRestTheme.Spacing.sm) {
            // App name
            Text(appName)
                .font(NervRestTheme.Fonts.caption)
                .foregroundColor(NervRestTheme.Text.secondary)

            // Score pill
            Text(String(format: "%.1f", score))
                .font(NervRestTheme.Fonts.micro)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, NervRestTheme.Spacing.sm)
                .padding(.vertical, NervRestTheme.Spacing.xs)
                .background(
                    Capsule()
                        .fill(scoreColor)
                )
        }
        .padding(.horizontal, NervRestTheme.Spacing.md)
        .padding(.vertical, NervRestTheme.Spacing.sm)
        .background(
            Capsule()
                .fill(NervRestTheme.Surface.cardBackground)
                .overlay(
                    Capsule()
                        .stroke(NervRestTheme.Surface.cardBorder, lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview

#if DEBUG
struct StimScoreBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: NervRestTheme.Spacing.md) {
            StimScoreBadge(appName: "Instagram", score: 7.5)
            StimScoreBadge(appName: "Kindle", score: 2.1)
            StimScoreBadge(appName: "YouTube", score: 8.9)
        }
        .padding()
        .background(NervRestTheme.Surface.background)
        .preferredColorScheme(.dark)
    }
}
#endif
