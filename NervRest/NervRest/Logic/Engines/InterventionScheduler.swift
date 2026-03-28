import Foundation
import Combine

// MARK: - Protocols for external managers (stubs for compilation)

protocol NotificationManaging {
    func fireNudge(mismatch: MismatchEvent, score: ArousalScore)
    func fireStrongNudge(mismatch: MismatchEvent?, score: ArousalScore)
}

protocol LiveActivityManaging {
    func updateState(_ state: LiveActivityState)
}

enum LiveActivityState {
    case idle
    case monitoring(score: ArousalScore)
    case elevated(score: ArousalScore)
    case warning(score: ArousalScore)
    case critical(score: ArousalScore)
    case recovering
}

// MARK: - InterventionScheduler

/// Decides WHEN and HOW to intervene based on escalating severity.
/// Phase 1: gentle nudge (notification)
/// Phase 2: stronger nudge (second notification + Dynamic Island alert)
/// Phase 3: intervention (Screen Time shield with options)
class InterventionScheduler: ObservableObject {

    enum Phase: Int, Comparable {
        case monitoring = 0      // watching, no action
        case gentleNudge = 1     // first notification
        case strongNudge = 2     // second notification, island pulses
        case intervention = 3    // shield overlay with ramp-down options
        case recovery = 4        // user switched to calm content

        static func < (lhs: Phase, rhs: Phase) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    @Published var currentPhase: Phase = .monitoring

    private let stimEngine: StimulationEngine
    private let mismatchDetector: MismatchDetector
    private let notificationManager: NotificationManaging
    private let liveActivityManager: LiveActivityManaging

    // Configurable thresholds
    var nudgeThreshold: Double = 5.5         // was 6.0
    var strongNudgeThreshold: Double = 7.0   // was 7.5
    var interventionThreshold: Double = 8.0  // was 8.5
    var nudgeCooldownSeconds: TimeInterval = 15   // 15s for demo (was 300)

    private var lastNudgeTime: Date?

    init(stimEngine: StimulationEngine,
         mismatchDetector: MismatchDetector,
         notificationManager: NotificationManaging,
         liveActivityManager: LiveActivityManaging) {
        self.stimEngine = stimEngine
        self.mismatchDetector = mismatchDetector
        self.notificationManager = notificationManager
        self.liveActivityManager = liveActivityManager
    }

    /// Called on the same timer as StimulationEngine (every 30s)
    func evaluate() {
        guard let score = stimEngine.currentScore else { return }
        let mismatch = mismatchDetector.activeMismatch

        // Don't nudge too frequently
        if let last = lastNudgeTime,
           Date().timeIntervalSince(last) < nudgeCooldownSeconds {
            return
        }

        switch score.total {
        case ..<nudgeThreshold:
            currentPhase = .monitoring

        case nudgeThreshold..<strongNudgeThreshold:
            if mismatch != nil && currentPhase < .gentleNudge {
                currentPhase = .gentleNudge
                notificationManager.fireNudge(mismatch: mismatch!, score: score)
                liveActivityManager.updateState(.elevated(score: score))
                lastNudgeTime = Date()
            }

        case strongNudgeThreshold..<interventionThreshold:
            if currentPhase < .strongNudge {
                currentPhase = .strongNudge
                notificationManager.fireStrongNudge(mismatch: mismatch, score: score)
                liveActivityManager.updateState(.warning(score: score))
                lastNudgeTime = Date()
            }

        default: // >= interventionThreshold
            if currentPhase < .intervention {
                currentPhase = .intervention
                liveActivityManager.updateState(.critical(score: score))
                // Shield activation happens via Screen Time API
                // The shield extension reads the current phase
            }
        }
    }

    func userChoseRampDown() {
        currentPhase = .recovery
        liveActivityManager.updateState(.recovering)
    }
}
