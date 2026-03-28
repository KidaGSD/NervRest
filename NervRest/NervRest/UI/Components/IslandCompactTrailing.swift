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
        case ..<3:   return Color(hex: "#1D9E75") // calm — deep teal
        case 3..<5:  return Color(hex: "#4CAF50") // moderate — forest green
        case 5..<7:  return Color(hex: "#EF9F27") // elevated — warm amber
        case 7..<9:  return Color(hex: "#D85A30") // high — burnt coral
        default:     return Color(hex: "#E24B4A") // critical — signal red
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
