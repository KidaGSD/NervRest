import Foundation

/// Generates personalized ramp-down suggestions based on the user's
/// current arousal level and their historical body response data.
class RampDownEngine {

    private let stimScores: StimScoreProvider
    private let profileBuilder: PersonalProfileBuilder

    init(stimScores: StimScoreProvider,
         profileBuilder: PersonalProfileBuilder) {
        self.stimScores = stimScores
        self.profileBuilder = profileBuilder
    }

    /// Generate a step-down path from current arousal to calm
    func generatePath(currentScore: Double, currentApp: String) -> [RampDownSuggestion] {
        let allApps = stimScores.allScores

        // Sort apps by stimulation score ascending
        let calmOptions = allApps
            .filter { $0.value.baseScore < currentScore - 1.5 }
            .sorted { $0.value.baseScore < $1.value.baseScore }

        // Pick 3-4 steps that form a gradual ramp
        var path: [RampDownSuggestion] = []
        let targetScores = stride(from: currentScore - 2.5,
                                   through: 1.5,
                                   by: -2.0)

        for target in targetScores {
            if let best = calmOptions.first(where: {
                abs($0.value.baseScore - target) < 1.5
            }) {
                let profile = profileBuilder.response(for: best.key)
                path.append(RampDownSuggestion(
                    id: UUID(),
                    fromApp: path.last?.toApp ?? currentApp,
                    toApp: best.key,
                    toAppStimScore: best.value.baseScore,
                    predictedHRDrop: abs(profile?.avgHRChange ?? -5),
                    estimatedMinutesToCalm: max(5, Int(abs(profile?.avgHRChange ?? -5) * 1.5)),
                    deepLinkURL: Self.deepLink(for: best.key)
                ))
            }
        }

        return path
    }

    /// Attempt to build a URL scheme to open the suggested app
    static func deepLink(for appName: String) -> URL? {
        // Common URL schemes — extend as needed
        let schemes: [String: String] = [
            "Spotify_lofi": "spotify:playlist:37i9dQZF1DWZd79rJ6a7lp",
            "Podcast": "podcasts://",
            "YouTube_longform": "youtube://",
            "Kindle": "kindle://",
            "Headspace": "headspace://",
        ]
        return schemes[appName].flatMap(URL.init(string:))
    }
}
