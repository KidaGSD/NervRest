import Foundation

struct ArousalScore {
    let total: Double              // 1-10, capped
    let noveltyComponent: Double
    let emotionComponent: Double
    let sensoryComponent: Double
    let interactivityComponent: Double
    let timeMultiplier: Double
    let timestamp: Date

    var level: ArousalLevel {
        switch total {
        case 0..<3: return .calm
        case 3..<5: return .moderate
        case 5..<7: return .elevated
        case 7..<9: return .high
        default: return .critical
        }
    }
}

enum ArousalLevel: String {
    case calm, moderate, elevated, high, critical
}
