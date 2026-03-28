import Foundation

/// Loads app stimulation scores from bundled JSON, with a hardcoded fallback.
/// Implements StimScoreProvider so it can be swapped with an AI-based provider later.
class StaticStimScoreProvider: StimScoreProvider {
    private var scores: [String: StimulationBreakdown] = [:]
    var allScores: [String: StimulationBreakdown] { scores }

    init() { loadScores() }

    func score(for appName: String) -> StimulationBreakdown? { scores[appName] }

    private func loadScores() {
        guard let url = Bundle.main.url(forResource: "app-stim-scores", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: StimulationBreakdown].self, from: data) else {
            scores = Self.hardcodedScores
            return
        }
        scores = decoded
    }

    // MARK: - Hardcoded fallback (also useful for previews and tests)

    static let hardcodedScores: [String: StimulationBreakdown] = [
        "TikTok": StimulationBreakdown(novelty: 9, emotion: 7, sensory: 9, interactivity: 8, baseScore: 8.3),
        "Twitter": StimulationBreakdown(novelty: 8, emotion: 9, sensory: 5, interactivity: 7, baseScore: 7.5),
        "Instagram": StimulationBreakdown(novelty: 7, emotion: 6, sensory: 7, interactivity: 7, baseScore: 6.8),
        "Reddit": StimulationBreakdown(novelty: 6, emotion: 7, sensory: 4, interactivity: 6, baseScore: 5.9),
        "YouTube": StimulationBreakdown(novelty: 5, emotion: 5, sensory: 6, interactivity: 3, baseScore: 4.8),
        "Netflix": StimulationBreakdown(novelty: 4, emotion: 7, sensory: 6, interactivity: 2, baseScore: 4.8),
        "News": StimulationBreakdown(novelty: 7, emotion: 8, sensory: 4, interactivity: 5, baseScore: 6.2),
        "Messaging": StimulationBreakdown(novelty: 5, emotion: 5, sensory: 2, interactivity: 7, baseScore: 4.9),
        "YouTube_longform": StimulationBreakdown(novelty: 3, emotion: 4, sensory: 5, interactivity: 2, baseScore: 3.4),
        "Podcast": StimulationBreakdown(novelty: 2, emotion: 4, sensory: 1, interactivity: 1, baseScore: 2.1),
        "Kindle": StimulationBreakdown(novelty: 1, emotion: 3, sensory: 1, interactivity: 2, baseScore: 1.7),
        "Spotify_lofi": StimulationBreakdown(novelty: 1, emotion: 1, sensory: 2, interactivity: 1, baseScore: 1.2),
        "Meditation": StimulationBreakdown(novelty: 1, emotion: 2, sensory: 2, interactivity: 2, baseScore: 1.7),
        "Yoga": StimulationBreakdown(novelty: 1, emotion: 2, sensory: 3, interactivity: 2, baseScore: 1.9),
    ]
}
