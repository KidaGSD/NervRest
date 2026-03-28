import Foundation

struct AppBodyResponse: Codable, Identifiable {
    let id: UUID
    let appName: String
    let avgHRChange: Double
    let avgHRVChange: Double
    let avgArousal: Double
    let sampleCount: Int
}
