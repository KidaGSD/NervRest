import Foundation

struct RampDownSuggestion: Identifiable {
    let id: UUID
    let fromApp: String
    let toApp: String
    let toAppStimScore: Double
    let predictedHRDrop: Double
    let estimatedMinutesToCalm: Int
    let deepLinkURL: URL?
}
