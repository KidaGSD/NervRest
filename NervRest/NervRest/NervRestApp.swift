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
    @State private var showOnboarding = !OnboardingViewModel.hasCompletedOnboarding()
    @StateObject private var onboardingVM = OnboardingViewModel()
    @StateObject private var container = AppContainer()
    @StateObject private var router = AppRouter()
    @StateObject private var notificationDelegate = NotificationDelegate()

    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                onboardingFlow
            } else {
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
                        case .demoFlow:
                            DemoFlowScreen(
                                homeViewModel: container.homeViewModel,
                                rampDownViewModel: container.rampDownViewModel,
                                alarmTime: container.contextProvider.currentContext.alarmTime?.hourMinute ?? "7:00 AM",
                                onExit: {
                                    container.homeViewModel.stopMonitoring()
                                    router.popToRoot()
                                }
                            )
                            .navigationBarHidden(true)
                        case .lunaChat:
                            LunaChatScreen(viewModel: container.lunaChatViewModel)
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
            } // else
        }
    }

    @ViewBuilder
    private var onboardingFlow: some View {
        switch onboardingVM.currentStep {
        case 0:
            OnboardingSplashScreen {
                onboardingVM.advance()
            }
        case 1:
            OnboardingPreferencesScreen(
                title: "What helps you wind down?",
                subtitle: "Select at least 3 forms that help the most",
                options: UserPreferences.windDownOptions,
                selections: $onboardingVM.windDownSelections,
                currentStep: 1,
                totalSteps: 3,
                minSelections: 3
            ) {
                onboardingVM.advance()
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        case 2:
            OnboardingPreferencesScreen(
                title: "What content are you most interested in?",
                subtitle: "Select at least 3 topics you are interested in",
                options: UserPreferences.contentOptions,
                selections: $onboardingVM.contentSelections,
                currentStep: 2,
                totalSteps: 3,
                minSelections: 3
            ) {
                onboardingVM.completeOnboarding()
                withAnimation(.easeInOut(duration: 0.5)) {
                    showOnboarding = false
                }
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        default:
            EmptyView()
        }
    }
}
