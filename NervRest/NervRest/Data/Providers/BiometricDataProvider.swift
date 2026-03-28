import Foundation

struct BiometricBaseline {
    let restingHR: Double
    let restingHRV: Double
    let restingRespiratoryRate: Double?
}

protocol BiometricDataProvider {
    var readings: AsyncStream<BiometricReading> { get }
    var latestReading: BiometricReading? { get }
    func readings(from: Date, to: Date) async -> [BiometricReading]
    var baseline: BiometricBaseline { get }
}
