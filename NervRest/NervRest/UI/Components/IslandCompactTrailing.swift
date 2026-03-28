import SwiftUI

/// Dynamic Island compact trailing view — arousal score with threshold-based color.
/// Sits in the right side of the pill. Self-contained colors (hex literals)
/// so this file can be copied to the widget extension target without dependencies.
struct IslandCompactTrailing: View {
    let arousalScore: Double

    var body: some View {
        Text(String(format: "%.1f", arousalScore))
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(arousalColor)
    }

    // MARK: - Score → Color

    /// Uses the same hex values as NervRestTheme.Arousal to stay visually
    /// consistent, but defined inline for widget-extension portability.
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
struct IslandCompactTrailing_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            IslandCompactTrailing(arousalScore: 1.5)
            IslandCompactTrailing(arousalScore: 4.0)
            IslandCompactTrailing(arousalScore: 6.2)
            IslandCompactTrailing(arousalScore: 7.8)
            IslandCompactTrailing(arousalScore: 9.3)
        }
        .padding()
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
}
#endif
