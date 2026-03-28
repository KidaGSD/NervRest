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
        case ..<3:   return Color(hex: "#1D9E75") // calm
        case 3..<5:  return Color(hex: "#4CAF50") // moderate
        case 5..<7:  return Color(hex: "#EF9F27") // elevated
        case 7..<9:  return Color(hex: "#D85A30") // high
        default:     return Color(hex: "#E24B4A") // critical
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
