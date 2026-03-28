import SwiftUI

@main
struct NervRestApp: App {
    @StateObject private var container = AppContainer()
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                HomeScreen(viewModel: container.homeViewModel)
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .home:
                            HomeScreen(viewModel: container.homeViewModel)
                        case .mismatchDetail:
                            MismatchDetailScreen(
                                viewModel: container.mismatchViewModel,
                                onWindDown: { router.navigate(to: .rampDown) }
                            )
                        case .rampDown:
                            RampDownScreen(viewModel: container.rampDownViewModel)
                        case .shieldOverlay:
                            ShieldOverlayScreen(
                                arousalScore: container.homeViewModel.arousalScore,
                                currentHR: container.homeViewModel.heartRate,
                                onShowAlternatives: { router.navigate(to: .rampDown) },
                                onFiveMoreMinutes: { router.popToRoot() }
                            )
                        }
                    }
            }
            .environmentObject(container)
            .environmentObject(router)
            .onOpenURL { url in
                guard url.scheme == "nervrest" else { return }
                switch url.host {
                case "rampdown": router.navigate(to: .rampDown)
                case "mismatch": router.navigate(to: .mismatchDetail)
                default: break
                }
            }
            .task {
                await container.notificationManager.requestPermission()
                container.notificationManager.registerCategories()
            }
        }
    }
}
