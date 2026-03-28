import SwiftUI

// MARK: - Compact Leading (Moon Phase)

struct IslandCompactLeading: View {
    let agentMood: String

    var body: some View {
        Image(moonImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .clipShape(Circle())
    }

    private var moonImageName: String {
        switch agentMood {
        case "happy": return "moon_full"
        case "concerned": return "moon_last_quarter"
        case "worried": return "moon_waxing_crescent"
        case "relieved": return "moon_waning_gibbous"
        default: return "moon_waning_crescent"
        }
    }
}

// MARK: - Compact Trailing (Score)

struct IslandCompactTrailing: View {
    let arousalScore: Double

    var body: some View {
        Text(String(format: "%.0f", arousalScore))
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(arousalColor)
    }

    private var arousalColor: Color {
        switch arousalScore {
        case ..<30:   return Color(hex: "#402959")
        case 30..<50: return Color(hex: "#52312F")
        case 50..<70: return Color(hex: "#D35200")
        case 70..<90: return Color(hex: "#842B00")
        default:      return Color(hex: "#E18050")
        }
    }
}

// MARK: - Minimal (Colored Dot)

struct IslandMinimal: View {
    let arousalScore: Double

    var body: some View {
        Circle()
            .fill(arousalColor)
            .frame(width: 10, height: 10)
    }

    private var arousalColor: Color {
        switch arousalScore {
        case ..<30:   return Color(hex: "#402959")
        case 30..<50: return Color(hex: "#52312F")
        case 50..<70: return Color(hex: "#D35200")
        case 70..<90: return Color(hex: "#842B00")
        default:      return Color(hex: "#E18050")
        }
    }
}
