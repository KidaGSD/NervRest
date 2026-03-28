import Foundation
import Combine

class RampDownViewModel: ObservableObject {
    @Published var suggestions: [RampDownSuggestion] = []
    @Published var freeTextInput: String = ""
    @Published var isLoading: Bool = false

    var onSuggestionSelected: (() -> Void)?

    func selectSuggestion(_ suggestion: RampDownSuggestion) {
        onSuggestionSelected?()
    }

    func loadMockSuggestions() {
        suggestions = [
            RampDownSuggestion(
                id: UUID(),
                fromApp: "TikTok",
                toApp: "YouTube Longform",
                toAppStimScore: 3.4,
                predictedHRDrop: 12,
                estimatedMinutesToCalm: 15,
                deepLinkURL: URL(string: "youtube://")
            ),
            RampDownSuggestion(
                id: UUID(),
                fromApp: "TikTok",
                toApp: "Podcast",
                toAppStimScore: 2.1,
                predictedHRDrop: 18,
                estimatedMinutesToCalm: 10,
                deepLinkURL: URL(string: "podcasts://")
            ),
            RampDownSuggestion(
                id: UUID(),
                fromApp: "TikTok",
                toApp: "Spotify Lofi",
                toAppStimScore: 1.2,
                predictedHRDrop: 22,
                estimatedMinutesToCalm: 8,
                deepLinkURL: URL(string: "spotify:playlist:37i9dQZF1DWZd79rJ6a7lp")
            ),
        ]
    }
}
