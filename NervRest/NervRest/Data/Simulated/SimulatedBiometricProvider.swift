import Foundation
import Combine

/// Reads WESAD biometric data from bundled JSON and emits readings on a timer.
/// For the hackathon demo this replaces real HealthKit data.
/// Falls back to synthetic data generated across 5 physiological phases.
class SimulatedBiometricProvider: BiometricDataProvider {

    // MARK: - Stored readings & playback state

    private var storedReadings: [BiometricReading] = []
    private var currentIndex = 0
    private var timer: Timer?

    /// How fast to play through the data (1.0 = real-time, 0.1 = 10x speed).
    var playbackSpeed: TimeInterval = 0.5  // 2x speed for demo

    // MARK: - BiometricDataProvider conformance

    let baseline = BiometricBaseline(restingHR: 64, restingHRV: 55, restingRespiratoryRate: 14)

    var latestReading: BiometricReading? {
        guard currentIndex < storedReadings.count else { return nil }
        return storedReadings[currentIndex]
    }

    /// Continuous stream backed by an AsyncStream that yields on each timer tick.
    var readings: AsyncStream<BiometricReading> {
        AsyncStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }
            // Yield all future readings via a Combine-based bridge.
            let cancellable = self.readingSubject
                .sink { reading in
                    continuation.yield(reading)
                }
            continuation.onTermination = { @Sendable _ in
                cancellable.cancel()
            }
        }
    }

    func readings(from start: Date, to end: Date) async -> [BiometricReading] {
        storedReadings.filter { $0.timestamp >= start && $0.timestamp <= end }
    }

    // MARK: - Internal publisher (bridges Timer → AsyncStream)

    private let readingSubject = PassthroughSubject<BiometricReading, Never>()

    // MARK: - Init

    init() {
        loadData()
    }

    // MARK: - Data loading

    private func loadData() {
        // Attempt to load the processed WESAD JSON from app bundle.
        guard let url = Bundle.main.url(forResource: "wesad-evening", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            storedReadings = Self.generateSyntheticEvening()
            return
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([BiometricReading].self, from: data) {
            storedReadings = decoded
        } else {
            storedReadings = Self.generateSyntheticEvening()
        }
    }

    // MARK: - Playback control

    func startPlayback() {
        timer = Timer.scheduledTimer(withTimeInterval: playbackSpeed, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.currentIndex < self.storedReadings.count - 1 {
                self.currentIndex += 1
                self.readingSubject.send(self.storedReadings[self.currentIndex])
            }
        }
    }

    func stopPlayback() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Synthetic data generation

    /// Generates 150 readings across 5 phases that model a typical overstimulated evening:
    ///   1. Calm baseline       (19:00–19:20, Instagram browsing)
    ///   2. Netflix plateau     (19:20–20:05, mostly calm)
    ///   3. Twitter doomscroll  (20:05–20:30, rising HR / falling HRV)
    ///   4. TikTok peak         (20:30–20:45, peak stress)
    ///   5. Recovery            (20:45–21:30, YouTube longform → Podcast)
    static func generateSyntheticEvening() -> [BiometricReading] {
        var result: [BiometricReading] = []
        let baseDate = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!

        // Phase 1: Calm baseline (minutes 0–19, 20 readings)
        for i in 0..<20 {
            let time = baseDate.addingTimeInterval(TimeInterval(i * 60))
            result.append(BiometricReading(
                id: UUID(), timestamp: time,
                heartRate: 68 + Double.random(in: -2...4),
                hrvSDNN: 50 + Double.random(in: -3...3),
                respiratoryRate: 14
            ))
        }

        // Phase 2: Netflix (minutes 20–64, 45 readings)
        for i in 20..<65 {
            let time = baseDate.addingTimeInterval(TimeInterval(i * 60))
            result.append(BiometricReading(
                id: UUID(), timestamp: time,
                heartRate: 66 + Double.random(in: -2...3),
                hrvSDNN: 52 + Double.random(in: -2...3),
                respiratoryRate: 14
            ))
        }

        // Phase 3: Twitter doomscroll (minutes 65–89, 25 readings — HR climbs, HRV drops)
        for i in 65..<90 {
            let progress = Double(i - 65) / 25.0
            let time = baseDate.addingTimeInterval(TimeInterval(i * 60))
            result.append(BiometricReading(
                id: UUID(), timestamp: time,
                heartRate: 72 + progress * 16 + Double.random(in: -2...2),
                hrvSDNN: 48 - progress * 22 + Double.random(in: -2...2),
                respiratoryRate: 14 + progress * 4
            ))
        }

        // Phase 4: TikTok peak (minutes 90–104, 15 readings — sustained high)
        for i in 90..<105 {
            let time = baseDate.addingTimeInterval(TimeInterval(i * 60))
            result.append(BiometricReading(
                id: UUID(), timestamp: time,
                heartRate: 86 + Double.random(in: -2...4),
                hrvSDNN: 24 + Double.random(in: -2...3),
                respiratoryRate: 18 + Double.random(in: -1...1)
            ))
        }

        // Phase 5: Recovery — YouTube longform then Podcast (minutes 105–149, 45 readings)
        for i in 105..<150 {
            let progress = Double(i - 105) / 45.0
            let time = baseDate.addingTimeInterval(TimeInterval(i * 60))
            result.append(BiometricReading(
                id: UUID(), timestamp: time,
                heartRate: 86 - progress * 24 + Double.random(in: -2...2),
                hrvSDNN: 24 + progress * 32 + Double.random(in: -2...2),
                respiratoryRate: 18 - progress * 4
            ))
        }

        return result
    }
}
