import Foundation

struct UserContext {
    let currentTime: Date
    let alarmTime: Date?
    let bedtimeStart: Date?
    let motionState: MotionState
    let isInWindDownWindow: Bool

    var minutesUntilAlarm: Int? {
        guard let alarm = alarmTime else { return nil }
        return Int(alarm.timeIntervalSince(currentTime) / 60)
    }
}

enum MotionState: String {
    case still, walking, driving, exercising, unknown
}
