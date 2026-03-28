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
    private let biometricProvider: SimulatedBiometricProvider?

    init(stimEngine: StimulationEngine,
         mismatchDetector: MismatchDetector,
         biometricProvider: SimulatedBiometricProvider? = nil) {
        self.stimEngine = stimEngine
        self.mismatchDetector = mismatchDetector
        self.biometricProvider = biometricProvider
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
        stimEngine.updateScore()
        mismatchDetector.check()
    }
}
