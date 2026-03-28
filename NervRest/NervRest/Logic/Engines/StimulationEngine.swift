import Foundation
import Combine

/// Computes a real-time arousal score from biometric + app + context data.
/// This is the core algorithm. Everything else depends on this score.
class StimulationEngine: ObservableObject {

    @Published var currentScore: ArousalScore?

    private let biometrics: BiometricDataProvider
    private let appUsage: AppUsageDataProvider
    private let context: ContextDataProvider
    private let stimScores: StimScoreProvider

    // Weights — configurable, could be personalized later
    struct Weights {
        var novelty: Double = 0.30
        var emotion: Double = 0.25
        var sensory: Double = 0.20
        var interactivity: Double = 0.25
    }
    var weights = Weights()

    init(biometrics: BiometricDataProvider,
         appUsage: AppUsageDataProvider,
         context: ContextDataProvider,
         stimScores: StimScoreProvider) {
        self.biometrics = biometrics
        self.appUsage = appUsage
        self.context = context
        self.stimScores = stimScores
    }

    /// Call on a timer (e.g. every 30 seconds) to update the score
    func updateScore() {
        guard let bio = biometrics.latestReading,
              let app = appUsage.currentApp,
              let stim = stimScores.score(for: app.appName) else { return }

        let ctx = context.currentContext

        // Content-based score
        let contentScore = (stim.novelty * weights.novelty +
                            stim.emotion * weights.emotion +
                            stim.sensory * weights.sensory +
                            stim.interactivity * weights.interactivity)

        // Biometric modifier: how much is body elevated above baseline?
        let hrElevation = (bio.heartRate - biometrics.baseline.restingHR) /
                          biometrics.baseline.restingHR
        let hrvDepression = (biometrics.baseline.restingHRV - bio.hrvSDNN) /
                            biometrics.baseline.restingHRV
        let bioModifier = 1.0 + (hrElevation + hrvDepression) * 0.5

        // Time multiplier
        let timeMultiplier = Self.timeMultiplier(for: ctx.currentTime)

        // Combined
        let raw = contentScore * bioModifier * timeMultiplier
        let capped = min(100.0, max(0.0, raw * 10.0))

        currentScore = ArousalScore(
            total: capped,
            noveltyComponent: stim.novelty,
            emotionComponent: stim.emotion,
            sensoryComponent: stim.sensory,
            interactivityComponent: stim.interactivity,
            timeMultiplier: timeMultiplier,
            timestamp: Date()
        )
    }

    static func timeMultiplier(for date: Date) -> Double {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 6..<12: return 1.0
        case 12..<18: return 1.0
        case 18..<21: return 1.2
        case 21..<24: return 1.5
        default: return 1.8  // after midnight
        }
    }
}
