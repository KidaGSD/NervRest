import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var windDownSelections: Set<String> = []
    @Published var contentSelections: Set<String> = []

    let totalSteps = 3

    var canContinue: Bool {
        switch currentStep {
        case 0: return true
        case 1: return windDownSelections.count >= 3
        case 2: return contentSelections.count >= 3
        default: return false
        }
    }

    func toggleWindDown(_ item: String) {
        if windDownSelections.contains(item) {
            windDownSelections.remove(item)
        } else {
            windDownSelections.insert(item)
        }
    }

    func toggleContent(_ item: String) {
        if contentSelections.contains(item) {
            contentSelections.remove(item)
        } else {
            contentSelections.insert(item)
        }
    }

    func advance() {
        if currentStep < totalSteps - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        }
    }

    func completeOnboarding() {
        let prefs = UserPreferences(
            windDownMethods: windDownSelections,
            contentInterests: contentSelections,
            hasCompletedOnboarding: true
        )
        if let data = try? JSONEncoder().encode(prefs) {
            UserDefaults.standard.set(data, forKey: "userPreferences")
        }
    }

    static func hasCompletedOnboarding() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: "userPreferences"),
              let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return false
        }
        return prefs.hasCompletedOnboarding
    }
}
