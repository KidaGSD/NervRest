import UserNotifications

class NotificationManager: NotificationManaging {
    func requestPermission() async {
        try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    func fireNudge(mismatch: MismatchEvent, score: ArousalScore) {
        let content = UNMutableNotificationContent()
        content.title = "Your body isn't resting"
        content.body = "\(mismatch.currentApp) has raised your HR to \(Int(mismatch.currentHR))bpm — \(Int(mismatch.hrElevationPercent))% above your resting baseline."
        content.categoryIdentifier = "NUDGE"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "nudge-\(UUID())", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func fireStrongNudge(mismatch: MismatchEvent?, score: ArousalScore) {
        let content = UNMutableNotificationContent()
        content.title = "Stimulation is high"
        content.body = "You've been on high-stimulation content. Your alarm is in \(mismatch?.context.minutesUntilAlarm ?? 0) minutes. Ready to wind down?"
        content.categoryIdentifier = "STRONG_NUDGE"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "strong-\(UUID())", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func registerCategories() {
        let windDown = UNNotificationAction(identifier: "WIND_DOWN", title: "Show me alternatives", options: .foreground)
        let dismiss = UNNotificationAction(identifier: "DISMISS", title: "Not now", options: .destructive)
        let nudgeCategory = UNNotificationCategory(identifier: "NUDGE", actions: [windDown, dismiss], intentIdentifiers: [])
        let strongCategory = UNNotificationCategory(identifier: "STRONG_NUDGE", actions: [windDown, dismiss], intentIdentifiers: [])
        UNUserNotificationCenter.current().setNotificationCategories([nudgeCategory, strongCategory])
    }
}
