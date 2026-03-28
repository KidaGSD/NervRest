import ActivityKit
import WidgetKit
import SwiftUI

struct NervRestLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NervRestActivityAttributes.self) { context in
            // Lock screen / banner view
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view (long press)
                DynamicIslandExpandedRegion(.leading) {
                    IslandCompactLeading(agentMood: context.state.agentMood)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    IslandCompactTrailing(arousalScore: context.state.arousalScore)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 2) {
                        Text(statusMessage(for: context.state.phase))
                            .font(.system(size: 13, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                        if let mins = context.state.minutesUntilAlarm {
                            Text("Alarm in \(mins / 60)h \(mins % 60)m")
                                .font(.system(size: 11, design: .default))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
            } compactLeading: {
                IslandCompactLeading(agentMood: context.state.agentMood)
            } compactTrailing: {
                IslandCompactTrailing(arousalScore: context.state.arousalScore)
            } minimal: {
                IslandMinimal(arousalScore: context.state.arousalScore)
            }
        }
    }

    private func statusMessage(for phase: String) -> String {
        switch phase {
        case "monitoring": return "Monitoring your evening"
        case "elevated": return "Stimulation rising..."
        case "warning": return "Your body isn't relaxing"
        case "critical": return "Nervous system activated"
        case "recovering": return "Winding down nicely"
        default: return "NervRest"
        }
    }
}

// MARK: - Lock Screen Banner View

struct LockScreenView: View {
    let context: ActivityViewContext<NervRestActivityAttributes>

    var body: some View {
        HStack(spacing: 12) {
            // Moon mascot
            Image(moonImageName(for: context.state.agentMood))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(statusMessage(for: context.state.phase))
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .foregroundColor(.white)

                HStack(spacing: 16) {
                    Label("\(context.state.heartRate) bpm", systemImage: "heart.fill")
                        .font(.system(size: 12, design: .default))
                        .foregroundColor(context.state.heartRate > 75 ? Color(hex: "#D35200") : Color(hex: "#402959"))

                    Label("\(context.state.hrv) ms", systemImage: "waveform.path.ecg")
                        .font(.system(size: 12, design: .default))
                        .foregroundColor(context.state.hrv < 35 ? Color(hex: "#D35200") : Color(hex: "#402959"))
                }
            }

            Spacer()

            // Arousal gauge
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 3)
                    .frame(width: 40, height: 40)
                Circle()
                    .trim(from: 0, to: min(context.state.arousalScore / 10.0, 1.0))
                    .stroke(arousalColor(for: context.state.arousalScore), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                Text(String(format: "%.0f", context.state.arousalScore))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .background(Color(hex: "#171120"))
    }

    private func moonImageName(for mood: String) -> String {
        switch mood {
        case "happy": return "moon_full"
        case "concerned": return "moon_last_quarter"
        case "worried": return "moon_waxing_crescent"
        case "relieved": return "moon_waning_gibbous"
        default: return "moon_waning_crescent"
        }
    }

    private func statusMessage(for phase: String) -> String {
        switch phase {
        case "monitoring": return "Monitoring your evening"
        case "elevated": return "Stimulation rising..."
        case "warning": return "Your body isn't relaxing"
        case "critical": return "Nervous system activated"
        case "recovering": return "Winding down nicely"
        default: return "NervRest"
        }
    }

    private func arousalColor(for score: Double) -> Color {
        switch score {
        case ..<3:   return Color(hex: "#402959")
        case 3..<5:  return Color(hex: "#52312F")
        case 5..<7:  return Color(hex: "#D35200")
        case 7..<9:  return Color(hex: "#842B00")
        default:     return Color(hex: "#E18050")
        }
    }
}

// MARK: - Expanded Bottom View

struct ExpandedBottomView: View {
    let context: ActivityViewContext<NervRestActivityAttributes>

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                Label("\(context.state.heartRate) bpm", systemImage: "heart.fill")
                    .font(.system(size: 12, design: .default))
                    .foregroundColor(context.state.heartRate > 75 ? Color(hex: "#D35200") : Color(hex: "#402959"))

                Label("\(context.state.hrv) ms", systemImage: "waveform.path.ecg")
                    .font(.system(size: 12, design: .default))
                    .foregroundColor(context.state.hrv < 35 ? Color(hex: "#D35200") : Color(hex: "#402959"))

                Spacer()

                Text(context.state.currentApp)
                    .font(.system(size: 11, design: .default))
                    .foregroundColor(.white.opacity(0.5))
            }

            if context.state.phase == "warning" || context.state.phase == "critical" {
                Link(destination: URL(string: "nervrest://rampdown")!) {
                    Text("Wind down")
                        .font(.system(size: 13, weight: .semibold, design: .default))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#D35200"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
}
