import Foundation
import Combine

class AppContainer: ObservableObject {
    @Published var pendingNavigation: AppRoute?

    // Data Layer
    let biometricProvider: SimulatedBiometricProvider
    let appUsageProvider: SimulatedAppUsageProvider
    let contextProvider: RealContextProvider
    let stimScoreProvider: StaticStimScoreProvider

    // Engines
    let stimulationEngine: StimulationEngine
    let mismatchDetector: MismatchDetector
    let rampDownEngine: RampDownEngine
    let profileBuilder: PersonalProfileBuilder
    let interventionScheduler: InterventionScheduler

    // Managers
    let liveActivityManager: LiveActivityManager
    let notificationManager: NotificationManager
    let sessionManager: SessionManager

    // ViewModels
    let homeViewModel: HomeViewModel
    let mismatchViewModel: MismatchViewModel
    let rampDownViewModel: RampDownViewModel

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Data providers
        let bio = SimulatedBiometricProvider()
        let app = SimulatedAppUsageProvider()
        let ctx = RealContextProvider()
        let stim = StaticStimScoreProvider()
        self.biometricProvider = bio
        self.appUsageProvider = app
        self.contextProvider = ctx
        self.stimScoreProvider = stim

        // Engines
        let stimEngine = StimulationEngine(
            biometrics: bio, appUsage: app, context: ctx, stimScores: stim
        )
        let mismatchDet = MismatchDetector(
            biometrics: bio, appUsage: app, context: ctx
        )
        let profBuilder = PersonalProfileBuilder()
        let rampEngine = RampDownEngine(stimScores: stim, profileBuilder: profBuilder)

        self.stimulationEngine = stimEngine
        self.mismatchDetector = mismatchDet
        self.profileBuilder = profBuilder
        self.rampDownEngine = rampEngine

        // Managers
        let liveAct = LiveActivityManager()
        let notif = NotificationManager()
        self.liveActivityManager = liveAct
        self.notificationManager = notif

        // InterventionScheduler uses NotificationManaging & LiveActivityManaging protocols
        let scheduler = InterventionScheduler(
            stimEngine: stimEngine,
            mismatchDetector: mismatchDet,
            notificationManager: notif,
            liveActivityManager: liveAct
        )
        self.interventionScheduler = scheduler

        // Session Manager
        let session = SessionManager(
            stimEngine: stimEngine,
            mismatchDetector: mismatchDet,
            interventionScheduler: scheduler,
            biometricProvider: bio,
            appUsageProvider: app
        )
        self.sessionManager = session

        // ViewModels
        let homeVM = HomeViewModel()
        homeVM.onStartSession = { [weak session, weak liveAct] in
            session?.startSession()
            liveAct?.startActivity(userName: "User")
        }
        homeVM.onStopSession = { [weak session, weak liveAct] in
            session?.stopSession()
            liveAct?.endActivity()
        }
        self.homeViewModel = homeVM

        let mismatchVM = MismatchViewModel()
        self.mismatchViewModel = mismatchVM

        let rampDownVM = RampDownViewModel()
        self.rampDownViewModel = rampDownVM

        rampDownVM.onSuggestionSelected = { [weak scheduler] in
            scheduler?.userChoseRampDown()
        }

        // Bind engine updates to home view model
        stimEngine.$currentScore
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak homeVM, weak bio, weak app] score in
                homeVM?.update(score: score, reading: bio?.latestReading, app: app?.currentApp)
            }
            .store(in: &cancellables)

        // Bind mismatch to mismatch view model
        mismatchDet.$activeMismatch
            .receive(on: DispatchQueue.main)
            .sink { [weak mismatchVM] mismatch in
                if let m = mismatch {
                    mismatchVM?.currentHR = m.currentHR
                    mismatchVM?.baselineHR = m.baselineHR
                    mismatchVM?.currentHRV = m.currentHRV
                    mismatchVM?.baselineHRV = m.baselineHRV
                    mismatchVM?.currentApp = m.currentApp
                    mismatchVM?.stimScore = m.stimScore
                    mismatchVM?.reason = m.reason
                }
            }
            .store(in: &cancellables)

        // Bind live activity updates
        stimEngine.$currentScore
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak liveAct, weak bio, weak app, weak ctx] score in
                guard liveAct?.isActive == true else { return }
                liveAct?.update(
                    score: score,
                    heartRate: Int(bio?.latestReading?.heartRate ?? 64),
                    hrv: Int(bio?.latestReading?.hrvSDNN ?? 55),
                    currentApp: app?.currentApp?.appName ?? "None",
                    minutesUntilAlarm: ctx?.currentContext.minutesUntilAlarm
                )
            }
            .store(in: &cancellables)

        // Bind intervention phase to navigation
        scheduler.$currentPhase
            .receive(on: DispatchQueue.main)
            .sink { [weak self] phase in
                switch phase {
                case .strongNudge:
                    self?.pendingNavigation = .mismatchDetail
                case .intervention:
                    self?.pendingNavigation = .shieldOverlay
                case .monitoring, .gentleNudge, .recovery:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
