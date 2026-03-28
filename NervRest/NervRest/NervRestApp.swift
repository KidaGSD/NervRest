import SwiftUI
import Combine
import UserNotifications

class NotificationDelegate: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    var onWindDown: (() -> Void)?

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "WIND_DOWN" ||
           response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            DispatchQueue.main.async {
                self.onWindDown?()
            }
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

@main
struct NervRestApp: App {
    @StateObject private var container = AppContainer()
    @StateObject private var router = AppRouter()
    @StateObject private var notificationDelegate = NotificationDelegate()

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
                                .onAppear {
                                    container.rampDownViewModel.loadMockSuggestions()
                                }
                        case .shieldOverlay:
                            ShieldOverlayScreen(
                                arousalScore: container.homeViewModel.arousalScore,
                                currentHR: container.homeViewModel.heartRate,
                                alarmTime: container.contextProvider.currentContext.alarmTime?.hourMinute ?? "7:00 AM",
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
            .onChange(of: container.pendingNavigation) { _, route in
                if let route = route {
                    router.navigate(to: route)
                    container.pendingNavigation = nil
                }
            }
            .task {
                await container.notificationManager.requestPermission()
                container.notificationManager.registerCategories()
                UNUserNotificationCenter.current().delegate = notificationDelegate
                notificationDelegate.onWindDown = {
                    router.navigate(to: .mismatchDetail)
                }
            }
        }
    }
}
