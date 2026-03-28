import SwiftUI

/// Dynamic Island minimal presentation — a tiny colored dot representing
/// the current arousal level. Shown when the Dynamic Island is in its
/// smallest form (e.g. another app also has a Live Activity).
struct IslandMinimal: View {
    let arousalScore: Double

    var body: some View {
        Circle()
            .fill(arousalColor)
            .frame(width: 10, height: 10)
    }

    // MARK: - Score → Color

    private var arousalColor: Color {
        switch arousalScore {
        case ..<3:   return Color(hex: "#402959") // calm — dusk purple
        case 3..<5:  return Color(hex: "#52312F") // moderate — warmth brown
        case 5..<7:  return Color(hex: "#D35200") // elevated — ember orange
        case 7..<9:  return Color(hex: "#842B00") // high — deep ember
        default:     return Color(hex: "#E18050") // critical — bright ember
        }
    }
}

// MARK: - Preview

#if DEBUG
struct IslandMinimal_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 16) {
            IslandMinimal(arousalScore: 2.0)
            IslandMinimal(arousalScore: 4.0)
            IslandMinimal(arousalScore: 6.0)
            IslandMinimal(arousalScore: 8.0)
            IslandMinimal(arousalScore: 9.5)
        }
        .padding()
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
}
#endif
