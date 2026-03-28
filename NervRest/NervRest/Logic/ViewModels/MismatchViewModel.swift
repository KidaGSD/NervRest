import Foundation
import Combine

class MismatchViewModel: ObservableObject {
    @Published var currentHR: Double = 88
    @Published var baselineHR: Double = 64
    @Published var currentHRV: Double = 30
    @Published var baselineHRV: Double = 55
    @Published var currentApp: String = "TikTok"
    @Published var stimScore: Double = 8.3
    @Published var reason: String = "HR 37% above resting baseline during rest context"

    var hrElevationPercent: Double {
        ((currentHR - baselineHR) / baselineHR) * 100
    }

    var hrvDepressionPercent: Double {
        ((baselineHRV - currentHRV) / baselineHRV) * 100
    }
}
