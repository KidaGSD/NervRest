import Foundation

protocol AppUsageDataProvider {
    var currentApp: AppUsageEvent? { get }
    var appChanges: AsyncStream<AppUsageEvent> { get }
    func usage(from: Date, to: Date) async -> [AppUsageEvent]
    func switchCount(lastMinutes: Int) -> Int
    var pickupCountToday: Int { get }
}
