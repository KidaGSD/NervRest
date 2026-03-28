import Foundation

struct BiometricReading: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let heartRate: Double          // bpm
    let hrvSDNN: Double            // ms
    let respiratoryRate: Double?   // breaths per min (optional)

    var isElevated: Bool {
        heartRate > 75
    }
}
