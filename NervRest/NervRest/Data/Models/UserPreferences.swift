import Foundation

struct UserPreferences: Codable {
    var windDownMethods: Set<String>
    var contentInterests: Set<String>
    var hasCompletedOnboarding: Bool

    static let windDownOptions = [
        "Lo-fi music", "Nature sounds", "Sleep stories",
        "Slow TV", "Breathwork", "Podcast"
    ]

    static let contentOptions = [
        "Lo-fi music", "Nature sounds", "Sleep stories",
        "Slow TV", "Breathwork", "Podcast"
    ]

    static var empty: UserPreferences {
        UserPreferences(windDownMethods: [], contentInterests: [], hasCompletedOnboarding: false)
    }
}
