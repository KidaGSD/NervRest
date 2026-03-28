import Foundation
import Combine

/// Uses the real device clock with hardcoded alarm/bedtime values.
/// Wind-down window is active between 21:00 and 02:00.
/// Motion state is always `.still` (no CoreMotion in simulator).
class RealContextProvider: ContextDataProvider {

    // MARK: - Hardcoded schedule

    /// Alarm set for 7:00 AM tomorrow.
    private var alarmTime: Date {
        let cal = Calendar.current
        let now = Date()
        var components = cal.dateComponents([.year, .month, .day], from: now)
        components.hour = 7
        components.minute = 0
        components.second = 0

        guard let todayAlarm = cal.date(from: components) else { return now }
        // If the alarm time has already passed today, use tomorrow.
        return todayAlarm > now ? todayAlarm : cal.date(byAdding: .day, value: 1, to: todayAlarm) ?? todayAlarm
    }

    /// Bedtime target: 10:30 PM tonight.
    private var bedtimeStart: Date {
        let cal = Calendar.current
        let now = Date()
        var components = cal.dateComponents([.year, .month, .day], from: now)
        components.hour = 22
        components.minute = 30
        components.second = 0

        guard let todayBedtime = cal.date(from: components) else { return now }
        // If bedtime has already passed today, use tomorrow.
        return todayBedtime > now ? todayBedtime : cal.date(byAdding: .day, value: 1, to: todayBedtime) ?? todayBedtime
    }

    // MARK: - ContextDataProvider conformance

    var currentContext: UserContext {
        let now = Date()
        return UserContext(
            currentTime: now,
            alarmTime: alarmTime,
            bedtimeStart: bedtimeStart,
            motionState: .still,
            isInWindDownWindow: Self.isWindDown(at: now)
        )
    }

    var contextChanges: AsyncStream<UserContext> {
        AsyncStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }
            // Check once per minute whether wind-down status changed.
            let timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
                guard let self else { return }
                continuation.yield(self.currentContext)
            }
            continuation.onTermination = { @Sendable _ in
                timer.invalidate()
            }
        }
    }

    // MARK: - Wind-down logic

    /// Wind-down window: 9 PM (21:00) through 2 AM (02:00).
    static func isWindDown(at date: Date) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        return hour >= 21 || hour < 2
    }
}
