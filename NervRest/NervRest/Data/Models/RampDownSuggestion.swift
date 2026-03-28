import Foundation

struct RampDownSuggestion: Identifiable {
    let id: UUID
    let fromApp: String
    let toApp: String
    let toAppStimScore: Double
    let predictedHRDrop: Double
    let estimatedMinutesToCalm: Int
    let deepLinkURL: URL?
    var coverImageName: String
    var durationMinutes: Int

    init(
        id: UUID = UUID(),
        fromApp: String,
        toApp: String,
        toAppStimScore: Double,
        predictedHRDrop: Double,
        estimatedMinutesToCalm: Int,
        deepLinkURL: URL?,
        coverImageName: String = "headphones",
        durationMinutes: Int = 30
    ) {
        self.id = id
        self.fromApp = fromApp
        self.toApp = toApp
        self.toAppStimScore = toAppStimScore
        self.predictedHRDrop = predictedHRDrop
        self.estimatedMinutesToCalm = estimatedMinutesToCalm
        self.deepLinkURL = deepLinkURL
        self.coverImageName = coverImageName
        self.durationMinutes = durationMinutes
    }
}
