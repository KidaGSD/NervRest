import Foundation

struct MismatchEvent: Identifiable {
    let id: UUID
    let timestamp: Date
    let currentHR: Double
    let baselineHR: Double
    let currentHRV: Double
    let baselineHRV: Double
    let currentApp: String
    let stimScore: Double
    let context: UserContext

    var hrElevationPercent: Double {
        ((currentHR - baselineHR) / baselineHR) * 100
    }

    var reason: String {
        "HR \(Int(hrElevationPercent))% above resting baseline during rest context"
    }
}
