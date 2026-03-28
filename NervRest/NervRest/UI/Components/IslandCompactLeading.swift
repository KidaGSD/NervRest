import SwiftUI

/// Dynamic Island compact leading view — agent character emoji based on mood.
/// Sits in the left side of the pill. Lightweight; uses no external theme
/// so it can be shared with the widget extension target without modification.
struct IslandCompactLeading: View {
    let agentMood: String

    var body: some View {
        Image(moonImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .clipShape(Circle())
    }

    // MARK: - Mood → Moon Phase Mapping

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

// MARK: - Preview

#if DEBUG
struct IslandCompactLeading_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 16) {
            IslandCompactLeading(agentMood: "happy")
            IslandCompactLeading(agentMood: "concerned")
            IslandCompactLeading(agentMood: "worried")
            IslandCompactLeading(agentMood: "relieved")
            IslandCompactLeading(agentMood: "unknown")
        }
        .padding()
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
}
#endif
