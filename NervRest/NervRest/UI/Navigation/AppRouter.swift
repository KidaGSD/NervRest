import SwiftUI
import Combine

enum AppRoute: Hashable {
    case home
    case mismatchDetail
    case rampDown
    case shieldOverlay
    case demoFlow
    case lunaChat
}

class AppRouter: ObservableObject {
    @Published var path = NavigationPath()

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
