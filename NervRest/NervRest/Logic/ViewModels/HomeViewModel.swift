import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var arousalScore: Double = 0
    @Published var arousalLevel: ArousalLevel = .calm
    @Published var heartRate: Int = 64
    @Published var hrv: Int = 55
    @Published var currentApp: String = "None"
    @Published var currentStimScore: Double = 0
    @Published var agentMood: String = "happy"
    @Published var isMonitoring: Bool = false
    @Published var elapsedTime: String = "0:00"

    private var cancellables = Set<AnyCancellable>()

    // These will be injected by AppContainer
    var onStartSession: (() -> Void)?
    var onStopSession: (() -> Void)?

    func startMonitoring() {
        isMonitoring = true
        onStartSession?()
    }

    func stopMonitoring() {
        isMonitoring = false
        onStopSession?()
    }

    func update(score: ArousalScore?, reading: BiometricReading?, app: AppUsageEvent?) {
        if let s = score {
            arousalScore = s.total
            arousalLevel = s.level
            switch s.level {
            case .calm, .moderate: agentMood = "happy"
            case .elevated: agentMood = "concerned"
            case .high, .critical: agentMood = "worried"
            }
        }
        if let r = reading {
            heartRate = Int(r.heartRate)
            hrv = Int(r.hrvSDNN)
        }
        if let a = app {
            currentApp = a.appName
            currentStimScore = a.stimulationScore
        }
    }
}
