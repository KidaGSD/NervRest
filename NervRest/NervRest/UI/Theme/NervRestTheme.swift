import SwiftUI

enum NervRestTheme {

    // MARK: - Arousal Spectrum (teal -> red, like star temperature)
    enum Arousal {
        static let calm = Color(hex: "#1D9E75")         // deep teal
        static let moderate = Color(hex: "#4CAF50")      // forest green
        static let elevated = Color(hex: "#EF9F27")      // warm amber
        static let high = Color(hex: "#D85A30")          // burnt coral
        static let critical = Color(hex: "#E24B4A")      // signal red

        static func color(for level: ArousalLevel) -> Color {
            switch level {
            case .calm: return calm
            case .moderate: return moderate
            case .elevated: return elevated
            case .high: return high
            case .critical: return critical
            }
        }

        static func color(for score: Double) -> Color {
            switch score {
            case ..<3: return calm
            case 3..<5: return moderate
            case 5..<7: return elevated
            case 7..<9: return high
            default: return critical
            }
        }
    }

    // MARK: - Surfaces (Midnight Observatory)
    enum Surface {
        static let background = Color(hex: "#0D1117")       // deep space
        static let cardBackground = Color(hex: "#161B22")    // raised card
        static let cardBorder = Color(hex: "#21262D")        // subtle edge
        static let elevated = Color(hex: "#1C2128")          // modal/sheet
    }

    // MARK: - Text
    enum Text {
        static let primary = Color(hex: "#E6EDF3")
        static let secondary = Color(hex: "#8B949E")
        static let tertiary = Color(hex: "#484F58")
    }

    // MARK: - Typography (SF Rounded — warm, approachable)
    enum Fonts {
        static let displayLarge = Font.system(size: 40, weight: .bold, design: .rounded)
        static let displayMedium = Font.system(size: 28, weight: .bold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 15, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 13, weight: .regular, design: .rounded)
        static let micro = Font.system(size: 11, weight: .medium, design: .rounded)
        static let score = Font.system(size: 56, weight: .heavy, design: .rounded)
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 999
    }
}

// Convenience extension on ArousalLevel
extension ArousalLevel {
    var swiftUIColor: Color {
        NervRestTheme.Arousal.color(for: self)
    }
}
