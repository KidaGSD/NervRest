import SwiftUI

/// Dynamic Island compact leading view — agent character emoji based on mood.
/// Sits in the left side of the pill. Lightweight; uses no external theme
/// so it can be shared with the widget extension target without modification.
struct IslandCompactLeading: View {
    let agentMood: String

    var body: some View {
        Text(emoji)
            .font(.system(size: 20))
    }

    // MARK: - Mood → Emoji Mapping

    private var emoji: String {
        switch agentMood {
        case "happy":     return "\u{1F60A}" // 😊
        case "concerned": return "\u{1F610}" // 😐
        case "worried":   return "\u{1F61F}" // 😟
        case "relieved":  return "\u{1F60C}" // 😌
        default:          return "\u{1FAE5}" // 🫥
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
