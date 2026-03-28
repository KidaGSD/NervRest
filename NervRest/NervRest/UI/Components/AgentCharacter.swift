import SwiftUI

struct AgentCharacter: View {
    let mood: String  // "happy", "concerned", "worried", "relieved"
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(NervRestTheme.Arousal.color(for: moodLevel).opacity(0.15))
                .frame(width: size * 1.2, height: size * 1.2)
            Text(emoji)
                .font(.system(size: size * 0.7))
        }
    }

    private var emoji: String {
        switch mood {
        case "happy": return "\u{1F60A}"
        case "concerned": return "\u{1F610}"
        case "worried": return "\u{1F61F}"
        case "relieved": return "\u{1F60C}"
        default: return "\u{1FAE5}"
        }
    }

    private var moodLevel: ArousalLevel {
        switch mood {
        case "happy": return .calm
        case "concerned": return .moderate
        case "worried": return .high
        case "relieved": return .calm
        default: return .moderate
        }
    }
}
