import Foundation
import Combine

/// Simulated app-usage provider that replays a crafted evening timeline.
/// Loads entries from bundled JSON or falls back to hardcoded data.
/// Provides `advanceToEvent(at:)` for demo-control scrubbing.
class SimulatedAppUsageProvider: AppUsageDataProvider {

    // MARK: - Timeline entry (for JSON decoding)

    private struct TimelineEntry: Codable {
        let appName: String
        let category: String
        let startMinute: Int
        let durationMinutes: Int
    }

    // MARK: - State

    private var events: [AppUsageEvent] = []
    private var currentEventIndex: Int = 0

    /// Mock pickup count — typical for a heavy phone user.
    let pickupCountToday: Int = 47

    // MARK: - AppUsageDataProvider conformance

    var currentApp: AppUsageEvent? {
        guard currentEventIndex < events.count else { return nil }
        return events[currentEventIndex]
    }

    var appChanges: AsyncStream<AppUsageEvent> {
        AsyncStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }
            let cancellable = self.appChangeSubject
                .sink { event in
                    continuation.yield(event)
                }
            continuation.onTermination = { @Sendable _ in
                cancellable.cancel()
            }
        }
    }

    func usage(from start: Date, to end: Date) async -> [AppUsageEvent] {
        events.filter { event in
            event.startTime >= start && event.startTime <= end
        }
    }

    func switchCount(lastMinutes: Int) -> Int {
        let cutoff = Date().addingTimeInterval(-Double(lastMinutes) * 60)
        return events.filter { $0.startTime >= cutoff }.count
    }

    // MARK: - Internal publisher

    private let appChangeSubject = PassthroughSubject<AppUsageEvent, Never>()

    // MARK: - Init

    init() {
        loadTimeline()
    }

    // MARK: - Data loading

    private func loadTimeline() {
        let entries: [TimelineEntry]

        if let url = Bundle.main.url(forResource: "evening-timeline", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([TimelineEntry].self, from: data) {
            entries = decoded
        } else {
            entries = Self.hardcodedTimeline
        }

        let stimScores = StaticStimScoreProvider.hardcodedScores
        let baseDate = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!

        events = entries.map { entry in
            let startTime = baseDate.addingTimeInterval(TimeInterval(entry.startMinute * 60))
            let endTime = baseDate.addingTimeInterval(TimeInterval((entry.startMinute + entry.durationMinutes) * 60))
            let category = AppCategory(rawValue: entry.category) ?? .other
            let stimScore = stimScores[entry.appName]?.baseScore ?? 5.0

            return AppUsageEvent(
                id: UUID(),
                appName: entry.appName,
                appCategory: category,
                startTime: startTime,
                endTime: endTime,
                stimulationScore: stimScore
            )
        }
    }

    // MARK: - Demo control

    /// Advance the current event pointer to the entry whose start time contains `date`.
    /// Falls back to the last event if `date` is past all entries.
    func advanceToEvent(at date: Date) {
        for (index, event) in events.enumerated() {
            if let end = event.endTime, date >= event.startTime && date < end {
                setCurrentIndex(index)
                return
            }
        }
        // Past the last event — stay on final entry.
        if let last = events.indices.last {
            setCurrentIndex(last)
        }
    }

    /// Advance to a specific index (for step-through demo).
    func advanceToIndex(_ index: Int) {
        guard events.indices.contains(index) else { return }
        setCurrentIndex(index)
    }

    private func setCurrentIndex(_ index: Int) {
        guard index != currentEventIndex else { return }
        currentEventIndex = index
        if let event = currentApp {
            appChangeSubject.send(event)
        }
    }

    /// All loaded events (read-only, useful for timeline views).
    var allEvents: [AppUsageEvent] { events }

    // MARK: - Hardcoded fallback

    private static let hardcodedTimeline: [TimelineEntry] = [
        TimelineEntry(appName: "Instagram",        category: "socialMedia",    startMinute: 0,   durationMinutes: 20),
        TimelineEntry(appName: "Netflix",           category: "entertainment", startMinute: 20,  durationMinutes: 45),
        TimelineEntry(appName: "Messaging",         category: "messaging",     startMinute: 65,  durationMinutes: 10),
        TimelineEntry(appName: "Twitter",           category: "socialMedia",   startMinute: 75,  durationMinutes: 15),
        TimelineEntry(appName: "TikTok",            category: "socialMedia",   startMinute: 90,  durationMinutes: 15),
        TimelineEntry(appName: "YouTube_longform",  category: "entertainment", startMinute: 105, durationMinutes: 20),
        TimelineEntry(appName: "Podcast",           category: "education",     startMinute: 125, durationMinutes: 25),
    ]
}
