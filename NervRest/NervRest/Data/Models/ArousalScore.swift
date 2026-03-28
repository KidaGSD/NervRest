import Foundation

struct ArousalScore {
    let total: Double              // 0-100, capped
    let noveltyComponent: Double
    let emotionComponent: Double
    let sensoryComponent: Double
    let interactivityComponent: Double
    let timeMultiplier: Double
    let timestamp: Date

    var level: ArousalLevel {
        switch total {
        case 0..<30: return .calm
        case 30..<50: return .moderate
        case 50..<70: return .elevated
        case 70..<90: return .high
        default: return .critical
        }
    }
}

enum ArousalLevel: String {
    case calm, moderate, elevated, high, critical
}
