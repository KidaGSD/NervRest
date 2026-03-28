import Foundation

struct AppUsageEvent: Codable, Identifiable {
    let id: UUID
    let appName: String
    let appCategory: AppCategory
    let startTime: Date
    let endTime: Date?
    let stimulationScore: Double   // 1-10

    var duration: TimeInterval {
        (endTime ?? Date()).timeIntervalSince(startTime)
    }
}

enum AppCategory: String, Codable {
    case socialMedia, news, entertainment, messaging
    case productivity, education, health, music
    case reading, gaming, other
}
