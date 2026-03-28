import SwiftUI

enum NervRestTheme {

    // MARK: - Arousal Spectrum (Warmth → Ember, warm & sleep-safe)
    enum Arousal {
        static let calm = Color(hex: "#402959")         // dusk purple — relaxed
        static let moderate = Color(hex: "#52312F")      // warmth brown — mild
        static let elevated = Color(hex: "#D35200")      // ember orange — rising
        static let high = Color(hex: "#842B00")          // deep ember — high alert
        static let critical = Color(hex: "#E18050")      // bright ember — critical

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

    // MARK: - Surfaces (Dusk Observatory)
    enum Surface {
        static let background = Color(hex: "#171120")       // dusk 100
        static let cardBackground = Color(hex: "#281C38")    // dusk 200
        static let cardBorder = Color(hex: "#402959")        // dusk 300
        static let elevated = Color(hex: "#1C0508")          // warmth dark
    }

    // MARK: - Text (Dusk light end + Ember warm)
    enum Text {
        static let primary = Color(hex: "#CFBEDB")       // dusk 500 — headings/body
        static let secondary = Color(hex: "#A27DBC")      // dusk 400 — labels
        static let tertiary = Color(hex: "#52312F")       // warmth 500 — hints
    }

    // MARK: - Accent (buttons, glows, interactive elements)
    enum Accent {
        static let primary = Color(hex: "#D35200")       // ember 300 — main CTA
        static let secondary = Color(hex: "#A27DBC")      // dusk 400 — secondary actions
        static let glow = Color(hex: "#F8C8A3")           // ember 500 — warm glow
    }

    // MARK: - Typography (SF Pro — clean, professional)
    enum Fonts {
        static let displayLarge = Font.system(size: 40, weight: .bold, design: .default)
        static let displayMedium = Font.system(size: 28, weight: .bold, design: .default)
        static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        static let body = Font.system(size: 15, weight: .regular, design: .default)
        static let caption = Font.system(size: 13, weight: .regular, design: .default)
        static let micro = Font.system(size: 11, weight: .medium, design: .default)
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

    // MARK: - Section Spacing (intentional rhythm, not uniform grid)
    enum SectionSpacing {
        static let tight: CGFloat = 12
        static let normal: CGFloat = 24
        static let breathe: CGFloat = 40
        static let dramatic: CGFloat = 56
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
