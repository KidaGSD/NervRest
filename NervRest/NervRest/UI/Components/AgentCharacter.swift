import SwiftUI

struct AgentCharacter: View {
    let mood: String  // "happy", "concerned", "worried", "relieved"
    let size: CGFloat

    var body: some View {
        ZStack {
            // Warm glow behind moon
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            glowColor.opacity(0.2),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: size * 0.2,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)

            Image(moonImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
    }

    private var moonImageName: String {
        switch mood {
        case "happy": return "moon_full"
        case "concerned": return "moon_last_quarter"
        case "worried": return "moon_waxing_crescent"
        case "relieved": return "moon_waning_gibbous"
        default: return "moon_waning_crescent"
        }
    }

    private var glowColor: Color {
        switch mood {
        case "happy": return NervRestTheme.Accent.glow
        case "concerned": return NervRestTheme.Arousal.elevated
        case "worried": return NervRestTheme.Arousal.high
        case "relieved": return NervRestTheme.Accent.glow
        default: return NervRestTheme.Text.secondary
        }
    }
}
