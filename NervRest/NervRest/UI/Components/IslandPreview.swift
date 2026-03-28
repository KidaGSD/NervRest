import SwiftUI

/// In-app preview that simulates the Dynamic Island for demo/testing purposes.
/// Renders both the compact pill (leading + trailing) and the expanded card
/// so the full Live Activity appearance can be reviewed without a physical
/// device that supports Dynamic Island.
struct IslandPreview: View {
    let arousalScore: Double
    let heartRate: Int
    let hrv: Int
    let currentApp: String
    let phase: String
    let agentMood: String
    let minutesUntilAlarm: Int?

    var body: some View {
        VStack(spacing: 24) {
            sectionHeader("Compact Pill")
            compactPill

            sectionHeader("Minimal")
            minimalDot

            sectionHeader("Expanded (Long-press)")
            expandedCard
        }
        .padding()
    }

    // MARK: - Compact Pill

    private var compactPill: some View {
        HStack {
            IslandCompactLeading(agentMood: agentMood)
            Spacer()
            IslandCompactTrailing(arousalScore: arousalScore)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black)
        .cornerRadius(20)
        .frame(width: 200)
    }

    // MARK: - Minimal Dot

    private var minimalDot: some View {
        IslandMinimal(arousalScore: arousalScore)
            .padding(8)
            .background(Color.black)
            .cornerRadius(12)
    }

    // MARK: - Expanded Card

    private var expandedCard: some View {
        IslandExpandedView(
            arousalScore: arousalScore,
            heartRate: heartRate,
            hrv: hrv,
            currentApp: currentApp,
            phase: phase,
            agentMood: agentMood,
            minutesUntilAlarm: minutesUntilAlarm
        )
        .background(Color.black)
        .cornerRadius(24)
        .frame(width: 360)
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .tracking(1.2)
    }
}

// MARK: - Preview

#if DEBUG
struct IslandPreview_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 48) {
                // Calm / monitoring state
                IslandPreview(
                    arousalScore: 2.3,
                    heartRate: 64,
                    hrv: 52,
                    currentApp: "Kindle",
                    phase: "monitoring",
                    agentMood: "happy",
                    minutesUntilAlarm: 420
                )

                Divider()

                // Warning state with action button
                IslandPreview(
                    arousalScore: 7.6,
                    heartRate: 85,
                    hrv: 30,
                    currentApp: "TikTok",
                    phase: "warning",
                    agentMood: "worried",
                    minutesUntilAlarm: 90
                )
            }
            .padding()
        }
        .background(Color(hex: "#0D1117"))
        .preferredColorScheme(.dark)
    }
}
#endif
