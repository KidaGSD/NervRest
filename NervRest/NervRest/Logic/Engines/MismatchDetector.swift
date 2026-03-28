import Foundation
import Combine

/// Detects when body state contradicts rest intent.
/// Fires when: user is still + it's evening + HR is elevated + HRV is depressed
class MismatchDetector: ObservableObject {

    @Published var activeMismatch: MismatchEvent?

    private let biometrics: BiometricDataProvider
    private let appUsage: AppUsageDataProvider
    private let context: ContextDataProvider

    // Thresholds — configurable
    var hrElevationThreshold: Double = 0.15   // 15% above baseline
    var hrvDepressionThreshold: Double = 0.20 // 20% below baseline

    init(biometrics: BiometricDataProvider,
         appUsage: AppUsageDataProvider,
         context: ContextDataProvider) {
        self.biometrics = biometrics
        self.appUsage = appUsage
        self.context = context
    }

    func check() {
        guard let bio = biometrics.latestReading else { return }
        let ctx = context.currentContext

        let hrElevation = (bio.heartRate - biometrics.baseline.restingHR) /
                          biometrics.baseline.restingHR
        let hrvDepression = (biometrics.baseline.restingHRV - bio.hrvSDNN) /
                            biometrics.baseline.restingHRV

        let isMismatch = ctx.motionState == .still &&
                         ctx.isInWindDownWindow &&
                         hrElevation > hrElevationThreshold &&
                         hrvDepression > hrvDepressionThreshold

        if isMismatch {
            activeMismatch = MismatchEvent(
                id: UUID(),
                timestamp: Date(),
                currentHR: bio.heartRate,
                baselineHR: biometrics.baseline.restingHR,
                currentHRV: bio.hrvSDNN,
                baselineHRV: biometrics.baseline.restingHRV,
                currentApp: appUsage.currentApp?.appName ?? "Unknown",
                stimScore: appUsage.currentApp?.stimulationScore ?? 0,
                context: ctx
            )
        } else {
            activeMismatch = nil
        }
    }
}
