import Foundation

struct StimulationBreakdown: Codable {
    let novelty: Double
    let emotion: Double
    let sensory: Double
    let interactivity: Double
    let baseScore: Double
}

protocol StimScoreProvider {
    func score(for appName: String) -> StimulationBreakdown?
    var allScores: [String: StimulationBreakdown] { get }
}
