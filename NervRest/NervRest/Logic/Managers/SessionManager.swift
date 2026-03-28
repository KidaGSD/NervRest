import Foundation
import Combine

class SessionManager: ObservableObject {
    enum State { case idle, monitoring, paused }

    @Published var state: State = .idle
    @Published var sessionStartTime: Date?
    @Published var elapsedSeconds: Int = 0

    private var timer: Timer?
    private var tickCount = 0
    let tickInterval: TimeInterval = 2.0  // 2 seconds for demo speed (real would be 30s)

    private let stimEngine: StimulationEngine
    private let mismatchDetector: MismatchDetector
    private let interventionScheduler: InterventionScheduler
    private let biometricProvider: SimulatedBiometricProvider?
    private let appUsageProvider: SimulatedAppUsageProvider?

    init(stimEngine: StimulationEngine,
         mismatchDetector: MismatchDetector,
         interventionScheduler: InterventionScheduler,
         biometricProvider: SimulatedBiometricProvider? = nil,
         appUsageProvider: SimulatedAppUsageProvider? = nil) {
        self.stimEngine = stimEngine
        self.mismatchDetector = mismatchDetector
        self.interventionScheduler = interventionScheduler
        self.biometricProvider = biometricProvider
        self.appUsageProvider = appUsageProvider
    }

    func startSession() {
        state = .monitoring
        sessionStartTime = Date()
        tickCount = 0
        biometricProvider?.startPlayback()
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
        tick()
    }

    func stopSession() {
        state = .idle
        timer?.invalidate()
        timer = nil
        biometricProvider?.stopPlayback()
    }

    private func tick() {
        tickCount += 1
        elapsedSeconds = Int(Double(tickCount) * tickInterval)

        // Advance app usage to match simulated time (each tick ≈ 1 minute in sim).
        // Timeline base is today at 19:00; offset by tickCount minutes.
        if let appUsageProvider {
            let base = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!
            let simDate = base.addingTimeInterval(TimeInterval(tickCount * 60))
            appUsageProvider.advanceToEvent(at: simDate)
        }

        stimEngine.updateScore()
        mismatchDetector.check()
        interventionScheduler.evaluate()
    }
}
