import SwiftUI

/// Dynamic Island expanded view — shown on long-press.
/// Full card with biometrics, current app, circular arousal gauge,
/// and a "Wind down" action button in warning/critical phases.
///
/// Follows spec Section 7 layout exactly. Self-contained colors
/// for widget-extension portability; hex values mirror NervRestTheme.Arousal.
struct IslandExpandedView: View {
    let arousalScore: Double
    let heartRate: Int
    let hrv: Int
    let currentApp: String
    let phase: String       // "monitoring", "elevated", "warning", "critical", "recovering"
    let agentMood: String   // "happy", "concerned", "worried", "relieved"
    let minutesUntilAlarm: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            topRow
            biometricRow
            actionButton
        }
        .padding(12)
    }

    // MARK: - Top Row

    /// Agent emoji + status message + alarm countdown + circular arousal gauge.
    private var topRow: some View {
        HStack {
            // Agent character (placeholder emoji — swap with designer asset)
            Text(agentEmoji)
                .font(.system(size: 28))

            VStack(alignment: .leading, spacing: 2) {
                Text(statusMessage)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                if let mins = minutesUntilAlarm {
                    Text("Alarm in \(mins / 60)h \(mins % 60)m")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer()

            // Circular arousal gauge (36pt)
            arousalGauge
        }
    }

    // MARK: - Circular Gauge

    private var arousalGauge: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 3)
                .frame(width: 36, height: 36)

            Circle()
                .trim(from: 0, to: min(arousalScore / 10.0, 1.0))
                .stroke(arousalColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 36, height: 36)
                .rotationEffect(.degrees(-90))

            Text(String(format: "%.0f", arousalScore))
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }

    // MARK: - Biometric Row

    /// Heart rate + HRV with SF Symbols, colored by health thresholds.
    /// Current app name sits trailing, dimmed.
    private var biometricRow: some View {
        HStack(spacing: 16) {
            Label("\(heartRate) bpm", systemImage: "heart.fill")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(heartRate > 75 ? Color(hex: "#E24B4A") : Color(hex: "#4CAF50"))

            Label("\(hrv) ms", systemImage: "waveform.path.ecg")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(hrv < 35 ? Color(hex: "#E24B4A") : Color(hex: "#4CAF50"))

            Spacer()

            Text(currentApp)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
        }
    }

    // MARK: - Action Button

    /// "Wind down" deep link — only visible in warning/critical phases.
    @ViewBuilder
    private var actionButton: some View {
        if phase == "warning" || phase == "critical" {
            Link(destination: URL(string: "nervrest://rampdown")!) {
                Text("Wind down")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#1D9E75")) // teal — calm color
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }

    // MARK: - Helpers

    private var agentEmoji: String {
        switch agentMood {
        case "happy":     return "\u{1F60A}" // 😊
        case "concerned": return "\u{1F610}" // 😐
        case "worried":   return "\u{1F61F}" // 😟
        case "relieved":  return "\u{1F60C}" // 😌
        default:          return "\u{1FAE5}" // 🫥
        }
    }

    private var statusMessage: String {
        switch phase {
        case "monitoring": return "Monitoring your evening"
        case "elevated":   return "Stimulation rising..."
        case "warning":    return "Your body isn't relaxing"
        case "critical":   return "Nervous system activated"
        case "recovering": return "Winding down nicely"
        default:           return "NervRest"
        }
    }

    private var arousalColor: Color {
        switch arousalScore {
        case ..<3:   return Color(hex: "#1D9E75")
        case 3..<5:  return Color(hex: "#4CAF50")
        case 5..<7:  return Color(hex: "#EF9F27")
        case 7..<9:  return Color(hex: "#D85A30")
        default:     return Color(hex: "#E24B4A")
        }
    }
}

// MARK: - Preview

#if DEBUG
struct IslandExpandedView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            // Calm state
            IslandExpandedView(
                arousalScore: 2.5,
                heartRate: 62,
                hrv: 55,
                currentApp: "Kindle",
                phase: "monitoring",
                agentMood: "happy",
                minutesUntilAlarm: 420
            )
            .background(Color.black)
            .cornerRadius(24)

            // Critical state with action button
            IslandExpandedView(
                arousalScore: 8.7,
                heartRate: 88,
                hrv: 28,
                currentApp: "TikTok",
                phase: "critical",
                agentMood: "worried",
                minutesUntilAlarm: 180
            )
            .background(Color.black)
            .cornerRadius(24)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
