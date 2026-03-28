import ActivityKit
import Combine
import SwiftUI

struct NervRestActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var arousalScore: Double
        var heartRate: Int
        var hrv: Int
        var currentApp: String
        var phase: String
        var agentMood: String
        var minutesUntilAlarm: Int?
    }
    let sessionStartTime: Date
    let userName: String
}

class LiveActivityManager: ObservableObject, LiveActivityManaging {
    @Published var isActive = false
    private var currentActivity: Activity<NervRestActivityAttributes>?

    func startActivity(userName: String) {
        let attributes = NervRestActivityAttributes(sessionStartTime: Date(), userName: userName)
        let initialState = NervRestActivityAttributes.ContentState(
            arousalScore: 1.0, heartRate: 64, hrv: 55,
            currentApp: "None", phase: "monitoring",
            agentMood: "happy", minutesUntilAlarm: nil
        )
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            isActive = true
            print("✅ Live Activity started successfully, id: \(currentActivity?.id ?? "nil")")
        } catch {
            print("❌ Failed to start Live Activity: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
        }

        // Debug: check if Live Activities are enabled
        print("📱 ActivityAuthorizationInfo: areActivitiesEnabled = \(ActivityAuthorizationInfo().areActivitiesEnabled)")
        print("📱 Frequent push enabled = \(ActivityAuthorizationInfo().frequentPushesEnabled)")
    }

    func update(score: ArousalScore, heartRate: Int, hrv: Int, currentApp: String, minutesUntilAlarm: Int?) {
        let phase: String
        let mood: String
        switch score.level {
        case .calm: phase = "monitoring"; mood = "happy"
        case .moderate: phase = "monitoring"; mood = "happy"
        case .elevated: phase = "elevated"; mood = "concerned"
        case .high: phase = "warning"; mood = "worried"
        case .critical: phase = "critical"; mood = "worried"
        }
        let state = NervRestActivityAttributes.ContentState(
            arousalScore: score.total, heartRate: heartRate, hrv: hrv,
            currentApp: currentApp, phase: phase,
            agentMood: mood, minutesUntilAlarm: minutesUntilAlarm
        )
        Task {
            await currentActivity?.update(ActivityContent(state: state, staleDate: nil))
        }
    }

    // MARK: - LiveActivityManaging conformance

    func updateState(_ state: LiveActivityState) {
        switch state {
        case .idle:
            break
        case .monitoring(let score):
            update(score: score, heartRate: Int(score.total * 6 + 30), hrv: 55,
                   currentApp: "Monitoring", minutesUntilAlarm: nil)
        case .elevated(let score):
            update(score: score, heartRate: Int(score.total * 6 + 30), hrv: 40,
                   currentApp: "Elevated", minutesUntilAlarm: nil)
        case .warning(let score):
            update(score: score, heartRate: Int(score.total * 6 + 30), hrv: 30,
                   currentApp: "Warning", minutesUntilAlarm: nil)
        case .critical(let score):
            update(score: score, heartRate: Int(score.total * 6 + 30), hrv: 22,
                   currentApp: "Critical", minutesUntilAlarm: nil)
        case .recovering:
            break
        }
    }

    func endActivity() {
        let finalState = NervRestActivityAttributes.ContentState(
            arousalScore: 1.0, heartRate: 64, hrv: 55,
            currentApp: "Done", phase: "monitoring",
            agentMood: "relieved", minutesUntilAlarm: nil
        )
        Task {
            await currentActivity?.end(ActivityContent(state: finalState, staleDate: nil), dismissalPolicy: .default)
        }
        currentActivity = nil
        isActive = false
    }
}
