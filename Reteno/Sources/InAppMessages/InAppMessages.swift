//
//  InAppMessages.swift
//  
//
//  Created by Anna Sahaidak on 18.01.2023.
//

import UIKit

final class InAppMessages {
    
    private var isPausedInApps: Bool = false
    private var inAppMessagesPauseBehaviour: PauseBehaviour = .postponeInApps
    
    private var application: UIApplication?
    private var window: UIWindow?
    private var slideUpVC: SlideUpMessageViewController?
    private var renderingController: InAppMessageWebViewController?
    private var workflowPresentationPending = false
    
    private var currentInAppMessage: InApp?
    private var currentInteractionId: String?
    
    private let mobileRequestService: MobileRequestService
    private let inAppRequestService: InAppRequestService
    private let storage: KeyValueStorage
    private let scheduler: EventsSenderScheduler
    private let sessionService: SessionService
    private let inAppService: InAppService
    
    private var inAppPresenters: [InAppMessagePresenter] = []
    private var postponeInAppInfo: [(showModel: InAppShowModel, canDelete: Bool, content: InAppContent, segmentId: Int?)] = []
    
    private var pendingEventTriggers: [PendingEventTrigger] = []
    private let pendingEventTriggersQueue = DispatchQueue(label: "com.reteno.in-app-messages.pending-event-triggers")
    
    private var isAlreadySendRequest: Bool = false
    private var isAlreadyFetchBaseFile: Bool = false
    private var slideUpTransitioningDelegate: SlideUpTransitioningDelegate?
    
    private var sdkStateHelper: SDKStateHelper {
        Reteno.sdkStateHelper
    }
    
    private static let baseHTMLFetchThreshold: TimeInterval = 4 * 60 * 60
    private static let pendingEventTriggerLifetime: TimeInterval = 60
    private static let pendingEventTriggersLimit: Int = 50
    
    private struct PendingEventTrigger {
        let eventTypeKey: String
        let parameters: [Event.Parameter]
        let date: Date
    }
    
    init(
        mobileRequestService: MobileRequestService,
        inAppRequestService: InAppRequestService,
        storage: KeyValueStorage,
        scheduler: EventsSenderScheduler = Reteno.senderScheduler,
        sessionService: SessionService
    ) {
        self.mobileRequestService = mobileRequestService
        self.inAppRequestService = inAppRequestService
        self.storage = storage
        self.scheduler = scheduler
        self.sessionService = sessionService
        self.inAppService = .init(requestService: mobileRequestService, storage: storage)
    }
    
    @available(iOSApplicationExtension, unavailable)
    func presentInApp(by id: String, isPushInApp: Bool = false) {
        mobileRequestService.getInAppMessage(by: id) { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleInAppMessage(message, isPushInApp: isPushInApp)
                
            case .failure(let error):
                Logger.log(error.localizedDescription, eventType: .error)
            }
        }
    }
    
    @available(iOSApplicationExtension, unavailable)
    private func handleInAppMessage(_ message: InAppMessage, isPushInApp: Bool) {
        if application?.isActive == true {
            DispatchQueue.main.async {
                Reteno.inAppStatusHander?(.inAppShouldBeDisplayed)
                self.setupWebView(with: message, isPushInApp: isPushInApp)
            }
        } else {
            currentInAppMessage = message
        }
    }
    
    @available(iOSApplicationExtension, unavailable)
    func presentInApp(by content: InAppContent) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if content.isWorkflow && (UIApplication.shared.applicationState != .active ||
                !self.inAppService.canPresentWorkflow(content)) { return }
            Reteno.inAppStatusHander?(.inAppShouldBeDisplayed)
            self.setupWebView(with: content)
        }
    }
    
    func logEventTrigger(eventTypeKey: String, parameters: [Event.Parameter]) {
        guard !isInAppWebViewController(parameters: parameters) else { return }
        
        guard isReadyToEvaluateEventTriggers else {
            bufferEventTrigger(eventTypeKey: eventTypeKey, parameters: parameters)
            return
        }
        
        evaluateEventTrigger(eventTypeKey: eventTypeKey, parameters: parameters)
    }
    
    private var isReadyToEvaluateEventTriggers: Bool {
        isAlreadyFetchBaseFile && inAppPresenters.isNotEmpty
    }
    
    private func evaluateEventTrigger(eventTypeKey: String, parameters: [Event.Parameter]) {
        for inAppPresenter in inAppPresenters where inAppPresenter.isHasEventConditions() {
            inAppPresenter.checkEvent(eventTypeName: eventTypeKey, parameters: parameters)
        }
    }
    
    private func bufferEventTrigger(eventTypeKey: String, parameters: [Event.Parameter]) {
        pendingEventTriggersQueue.sync {
            pendingEventTriggers.append(
                .init(eventTypeKey: eventTypeKey, parameters: parameters, date: Date())
            )
            let overflow = pendingEventTriggers.count - Self.pendingEventTriggersLimit
            if overflow > 0 {
                pendingEventTriggers.removeFirst(overflow)
            }
        }
        Logger.log("inApp event trigger: \(eventTypeKey) postponed until in-apps are ready", eventType: .verbose)
    }
    
    private func drainPendingEventTriggers() {
        guard isReadyToEvaluateEventTriggers else { return }
        
        let earliestValidDate = Date().addingTimeInterval(-Self.pendingEventTriggerLifetime)
        let triggers: [PendingEventTrigger] = pendingEventTriggersQueue.sync {
            let actualTriggers = pendingEventTriggers.filter { $0.date > earliestValidDate }
            pendingEventTriggers.removeAll()
            return actualTriggers
        }
        
        for trigger in triggers {
            Logger.log("inApp event trigger: \(trigger.eventTypeKey) replayed", eventType: .verbose)
            evaluateEventTrigger(eventTypeKey: trigger.eventTypeKey, parameters: trigger.parameters)
        }
    }
    
    @available(iOSApplicationExtension, unavailable)
    func setInAppMessagesPause(isPaused: Bool) {
        isPausedInApps = isPaused
        if !isPaused { inAppService.reprocessWorkflowMessages() }

        guard !isPaused, inAppMessagesPauseBehaviour == .postponeInApps, let inAppToShow = postponeInAppInfo.first else {
            return
        }
        
        if let segmentID = inAppToShow.segmentId {
            self.inAppService.checkAsyncRulesSegment(id: segmentID) { [weak self] checks in
                guard let self else { return }
                for segment in checks {
                    if segment.segmentId == segmentID, segment.checkResult {
                        self.processingInApp(showModel: inAppToShow.showModel, canDelete: inAppToShow.canDelete)
                        self.presentInApp(by: inAppToShow.content)
                        break
                    }
                }
            }
        } else {
            self.processingInApp(showModel: inAppToShow.showModel, canDelete: inAppToShow.canDelete)
            self.presentInApp(by: inAppToShow.content)
        }
        postponeInAppInfo.removeAll()
    }
    
    func endSession() {
        sessionService.sendEndSessionEventIfNeeded()
        sessionService.invalidateTimer()
        storage.clearOncePerSessionEvents()
        storage.clearNoLimitEvents()
        storage.clearEventsCache()
        storage.set(value: 0, forKey: StorageKeys.sessionDuration.rawValue)
    }
    
    func clearInApps() {
        guard Thread.isMainThread else {
            DispatchQueue.main.sync { self.clearInApps() }
            return
        }
        dismissInAppMessage(animated: false)
        dismissSlideUp(animated: false)
        isAlreadySendRequest = false
        inAppService.clearInApps()
        inAppPresenters = []
        postponeInAppInfo = []
        currentInAppMessage = nil
        currentInteractionId = nil
        pendingEventTriggersQueue.sync { pendingEventTriggers.removeAll() }
    }
    
    func startSession() {
        sessionService.sendStartSessionEventIfNeeded()
        sessionService.sessionDurationTimer()
    }

    private func handleNewSessionStarted() {
        inAppService.reprocessInAppMessages()
    }

    func updateSessionConfiguration(
        previous: RetenoSessionConfiguration?,
        new configuration: RetenoSessionConfiguration
    ) {
        sessionService.reconfigure(previous: previous, new: configuration)
    }
    
    func setInAppMessagesPauseBehaviour(pauseBehaviour: PauseBehaviour) {
        inAppMessagesPauseBehaviour = pauseBehaviour
    }
    
    func checkSegments() {
        self.inAppService.checkAsyncRulesSegment()
    }
    
    private func inAppPresentersSelections() {
        sessionService.timeSpendInApp = { [weak self] time in
            guard let self = self else { return }

            for inAppPresenter in inAppPresenters {
                if inAppPresenter.isHasTimeCondition() {
                    inAppPresenter.updateTimeSpendInApp(time: time)
                }
            }
        }
    }
    
    private func isInAppWebViewController(parameters: [Event.Parameter]) -> Bool {
        parameters.first(where: { $0.name == ScreenClass })?.value == "InAppMessageWebViewController"
    }
    
    // MARK: Subscribe on notifications
    
    @available(iOSApplicationExtension, unavailable)
    func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceRegistrationConfirmed(_:)),
                                               name: Reteno.inAppDeviceRegistrationConfirmed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelPendingWorkflowPresentation),
                                               name: UIApplication.willResignActiveNotification, object: nil)
        InAppWebViewPool.shared.warmUp()
        self.sessionService.subscribeOnNotifications()
        self.sessionService.onSessionStarted = { [weak self] in
            self?.handleNewSessionStarted()
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationDidBecomeActiveNotification),
            name: Reteno.retenoDidBecomeActive,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationDidBecomeActiveNotification),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationWillTerminateNotification(_:)),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationDidEnterBackgroundNotification(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    private func fetchBaseHTML(completion: @escaping () -> Void = {}) {
        let currentPath = inAppRequestService.baseHTMLPath
        let lastFetchedPath: String? = storage.getValue(forKey: StorageKeys.lastBaseHTMLPath.rawValue)
        let isPathChanged = lastFetchedPath != currentPath
        
        if !isPathChanged,
           let lastFetchTimestamp: Double = storage.getValue(forKey: StorageKeys.lastBaseHTMLFetchDate.rawValue),
           lastFetchTimestamp > 0 {
            let elapsed = Date().timeIntervalSince1970 - lastFetchTimestamp
            if elapsed < Self.baseHTMLFetchThreshold {
                completion()
                return
            }
        }
        
        inAppRequestService.fetchBaseHTML { [weak self] result in
            switch result {
            case .success(let version):
                guard let self else {
                    completion()
                    return
                }
                
                let isVersionChanged = version != nil
                    && self.storage.getValue(forKey: StorageKeys.inAppMessageBaseHTMLVersion.rawValue) != version
                
                guard isPathChanged || isVersionChanged || !self.inAppRequestService.baseHTMLExists() else {
                    self.storage.set(value: Date().timeIntervalSince1970, forKey: StorageKeys.lastBaseHTMLFetchDate.rawValue)
                    self.storage.set(value: currentPath, forKey: StorageKeys.lastBaseHTMLPath.rawValue)
                    completion()
                    return
                }
                
                self.inAppRequestService.downloadBaseHTML { result in
                    switch result {
                    case .success:
                        if let version {
                            self.storage.set(value: version, forKey: StorageKeys.inAppMessageBaseHTMLVersion.rawValue)
                        } else {
                            self.storage.removeValue(forKey: StorageKeys.inAppMessageBaseHTMLVersion.rawValue)
                        }
                        self.storage.set(value: Date().timeIntervalSince1970, forKey: StorageKeys.lastBaseHTMLFetchDate.rawValue)
                        self.storage.set(value: currentPath, forKey: StorageKeys.lastBaseHTMLPath.rawValue)
                        
                    case .failure(let error):
                        ErrorLogger.shared.capture(error: error)
                    }
                    completion()
                }
                
            case .failure(let error):
                ErrorLogger.shared.capture(error: error)
                completion()
            }
        }
    }
    
    @available(iOSApplicationExtension, unavailable)
    func getInAppMessages() {
        guard !isAlreadySendRequest else {
            return
        }
        
        isAlreadySendRequest = true
        
        inAppService.workflowShowModels = { [weak self] models in
            self?.presentingInApp(contents: [], showModels: models, workflowOnly: true)
        }
        inAppService.discoveryFailed = { [weak self] in
            self?.isAlreadySendRequest = false
        }
        inAppService.inAppContents = { [weak self] contents, showModels in
            guard let self = self else { return }
            
            self.isAlreadySendRequest = false
            self.presentingInApp(contents: contents, showModels: showModels)
        }
        inAppService.getInAppMessages()
    }
    
    @available(iOSApplicationExtension, unavailable)
    private func presentingInApp(contents: [InAppContent], showModels: [InAppShowModel], workflowOnly: Bool = false) {
        let discoveryContext = WorkflowContext.current
        let keys = Set(showModels.map { $0.message.executionKey })
        inAppPresenters.removeAll {
            (!workflowOnly || $0.model.message.isWorkflow) && !keys.contains($0.model.message.executionKey)
        }
        for showModel in showModels {
            let presenter: InAppMessagePresenter = .init(model: showModel, storage: storage) { inApp, canDelete in
                guard discoveryContext == WorkflowContext.current else { return }
                if inApp.isWorkflow {
                    guard !self.isPausedInApps, self.isAlreadyFetchBaseFile else { return }
                    let authorize = {
                        self.inAppService.authorizeWorkflow(inApp) { content in
                            guard let content else { return }
                            self.presentInApp(by: content)
                        }
                    }
                    if inApp.displayRules.async.segment.enabled {
                        guard let id = inApp.displayRules.async.segment.segmentId else { return }
                        self.inAppService.checkAsyncRulesSegment(id: id) { checks in
                            guard discoveryContext == WorkflowContext.current,
                                  checks.contains(where: { $0.segmentId == id && $0.checkResult }) else { return }
                            authorize()
                        }
                    } else {
                        authorize()
                    }
                    return
                }
                guard !self.isPausedInApps else {
                    
                    if let content = contents.first(where: { $0.messageInstanceId == inApp.messageInstanceId }) {
                        let segmentId = inApp.displayRules.async.segment.enabled ? inApp.displayRules.async.segment.segmentId : nil
                        self.postponeInAppInfo.append((showModel, canDelete, content, segmentId))
                    }
                    
                    
                    return
                }
                
                guard self.isAlreadyFetchBaseFile else {
                    return
                }
                
                if let content = contents.first(where: { $0.messageInstanceId == inApp.messageInstanceId }) {
                    if inApp.displayRules.async.segment.enabled, let segmentID = inApp.displayRules.async.segment.segmentId {
                        self.inAppService.checkAsyncRulesSegment(id: segmentID) { checks in
                            for segment in checks {
                                if segment.segmentId == segmentID, segment.checkResult {
                                    self.processingInApp(showModel: showModel, canDelete: canDelete)
                                    self.presentInApp(by: content)
                                    break
                                }
                            }
                        }
                    } else {
                        self.processingInApp(showModel: showModel, canDelete: canDelete)
                        self.presentInApp(by: content)
                    }
                }
            }
            
            self.updateAllPresenters(
                newPresenter: presenter,
                isExistMessageId: { message in
                    message.executionKey == showModel.message.executionKey
                }
            )
        }
        if !workflowOnly {
            self.inAppPresentersSelections()
            self.drainPendingEventTriggers()
        }
    }
    
    private func updateAllPresenters(
        newPresenter: InAppMessagePresenter,
        isExistMessageId: (Message) -> Bool
    ) {
        self.inAppPresenters.removeAll(where: {
            let isExist = isExistMessageId($0.model.message)
            if isExist {
                Logger.log("inApp messageId: \($0.model.message.messageId) deleted", eventType: .verbose)
            }
            return isExist
        })
        self.inAppPresenters.append(newPresenter)
        Logger.log("inApp messageId: \(newPresenter.model.message.messageId) added", eventType: .verbose)
    }
    
    private func sendInteraction(with inApp: InApp, status: NewInteractionStatus = .opened, description: String? = nil) {
        guard let inAppContent = inApp as? InAppContent else {
            return
        }
        
        mobileRequestService.sendInteraction(
            interaction: .init(
                time: Date(),
                messageInstanceId: inAppContent.messageInstanceId,
                status: status,
                statusDescription: description
            )
        )
    }
        
    @available(iOSApplicationExtension, unavailable)
    private func setupWebView(with message: InApp, isPushInApp: Bool = false) {
        if isPushInApp {
            if window.isSome {
                dismissInAppMessage(animated: false)
            } else if slideUpVC.isSome {
                dismissSlideUp(animated: false)
            }
        }
        guard slideUpVC.isNone && window.isNone else { return }
        currentInteractionId = nil
        if let content = message as? InAppContent, content.isWorkflow,
           !inAppService.canPresentWorkflow(content) { return }
        workflowPresentationPending = (message as? InAppContent)?.isWorkflow == true
        if message.layoutType == .slideUp || message.layoutType == .bottomBar {
            let viewController = SlideUpMessageViewController(
                inApp: message,
                inAppService: inAppService
            )
            viewController.delegate = self
            slideUpVC = viewController
            renderingController = viewController
            viewController.loadViewIfNeeded()
        } else {
            let viewController = InAppMessageWebViewController(
                with: message,
                inAppService: inAppService
            )
            viewController.delegate = self
            self.window = UIWindow()
            renderingController = viewController
            viewController.loadViewIfNeeded()
        }
    }
    
    private func presentInAppMessage(animated: Bool = true, in viewController: UIViewController,
                                     visible: @escaping () -> Void) {
        // window for new In-app message
        var window: UIWindow?
        
        func completion() {
            // Check if some in-app is being already presented
            guard self.window === window, renderingController === viewController else { return }
            if window?.isHidden == false, window?.alpha == 1,
               viewController.viewIfLoaded?.window != nil {
                visible()
            }
        }
        
        if #available(iOS 13.0, *) {
            application?.connectedScenes.forEach {
                guard $0.activationState == .foregroundActive, let windowScene = $0 as? UIWindowScene else { return }
                
                window = UIWindow(frame: windowScene.coordinateSpace.bounds)
                window?.windowScene = windowScene
            }
        } else {
            window = UIWindow(frame: CGRect(origin: .zero, size: UIScreen.main.bounds.size))
        }
        window?.alpha = 0.0
        window?.backgroundColor = .clear
        window?.windowLevel = .normal
        window?.rootViewController = viewController
        self.window?.isHidden = true
        self.window = window
        window?.isHidden = false
        if window.isNone {
            dismissInAppMessage(animated: false)
            ErrorLogger.shared.captureWarningEvent(message: "Couldn't resolve window to present InApp")
            return
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.25,
                animations: { window?.alpha = 1.0 },
                completion: { finished in if finished { completion() } }
            )
        } else {
            window?.alpha = 1.0
            completion()
        }
    }
    
    @available(iOSApplicationExtension, unavailable)
    private func presentSlideUpMessage(_ inApp: InApp,
                                       in viewController: UIViewController,
                                       height: CGFloat,
                                       animated: Bool = true,
                                       visible: @escaping () -> Void) {
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController,
              rootVC.presentedViewController == nil,
              let slideUpVC = viewController as? SlideUpMessageViewController,
              height.isFinite, height > 0 else {
            dismissSlideUp(animated: false)
            Logger.log("In-app presentation unavailable", eventType: .warning)
            return
        }
        switch inApp.layoutType {
        case .bottomBar:
            slideUpTransitioningDelegate = SlideUpTransitioningDelegate(slidePosition: .bottom)
            slideUpVC.setupBottomBar(height: height)
        case .slideUp:
            slideUpTransitioningDelegate = SlideUpTransitioningDelegate(slidePosition: inApp.layoutParams?.position ?? .top)
            slideUpVC.setWebViewLayout(position: inApp.layoutParams?.position ?? .top, height: height)
        default: break
        }
        slideUpVC.modalPresentationStyle = .custom
        slideUpVC.transitioningDelegate = slideUpTransitioningDelegate
        rootVC.present(slideUpVC, animated: animated) {
            if slideUpVC.viewIfLoaded?.window != nil { visible() }
        }
    }
    
    private func dismissInAppMessage(action: InAppMessageAction? = nil, animated: Bool = true) {
        func hide() {
            window?.isHidden = true
            window?.removeFromSuperview()
            renderingController?.stopRendering()
            window = nil
            renderingController = nil
            workflowPresentationPending = false
            if let action = action {
                Reteno.inAppStatusHander?(.inAppIsClosed(action: action))
            }
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.25,
                animations: { self.window?.alpha = 0.0 },
                completion: { _ in hide() }
            )
        } else {
            hide()
        }
    }
    
    private func dismissSlideUp(animated: Bool = true,
                                swipeDirection: UISwipeGestureRecognizer.Direction = .left,
                                action: InAppMessageAction? = nil) {
        if let vc = slideUpVC {
            if !animated { vc.viewIfLoaded?.isHidden = true }
            vc.stopRendering()
            slideUpTransitioningDelegate?.swipeDirection = swipeDirection
            vc.dismiss(animated: animated) {
                if let action {
                    Reteno.inAppStatusHander?(.inAppIsClosed(action: action))
                }
            }
            slideUpVC = nil
            renderingController = nil
            workflowPresentationPending = false
        }
    }
    
    // MARK: Processing InApps
    
    private func processingInApp(showModel: InAppShowModel, canDelete: Bool) {
        guard !showModel.message.isWorkflow else { return }
        if canDelete || showModel.frequency == .oncePerApp || showModel.frequency == .oncePerSession {
            self.inAppPresenters.removeAll(where: { $0.model.message.messageId == showModel.message.messageId })
        }
        if showModel.frequency == .oncePerApp {
            self.storage.addOnlyOnceDisplayedId(id: showModel.message.messageId)
        } else if showModel.frequency == .oncePerSession {
            self.storage.addOncePerSessionDisplayedId(id: showModel.message.messageId)
        } else if showModel.frequency == .minInterval {
            self.storage.addMinIntervalInApps(id: showModel.message.messageId)
        } else if showModel.frequency == .timesPerTimeUnit {
            self.storage.addTimePerTimeUnitInApps(id: showModel.message.messageId)
        } else if showModel.frequency == .noLimit, !showModel.hasEventCondition {
            self.storage.addNoLimitDisplayedId(id: showModel.message.messageId)
        }
    }
    
    // MARK: Handle interaction
    
    private func handleInteraction(in message: InApp, messageId: String, action: NotificationStatus.Action) {
        if let content = message as? InAppContent, content.isWorkflow {
            inAppService.sendInteraction(with: content, status: .clicked, action: action)
        } else {
            let status = NotificationStatus(interactionId: messageId, status: .clicked, date: Date(), action: action)
            storage.addNotificationStatus(status)
        }
        scheduler.forcePushEvents()
    }
    
    // Called synchronously after Core has written the complete local identity.
    func userIdentityDidChange(from previousContext: String) {
        guard Thread.isMainThread else {
            DispatchQueue.main.sync { self.userIdentityDidChange(from: previousContext) }
            return
        }
        let current = WorkflowContext.current
        guard previousContext != current else { return }
        clearInApps()
        storage.set(value: current, forKey: StorageKeys.inAppContext.rawValue)
        storage.beginWorkflowRegistration(context: current)
        // Reuse the scheduler's existing current-device registration/recovery path.
        storage.set(value: false, forKey: StorageKeys.isUpdatedDevice.rawValue)
    }

    @available(iOSApplicationExtension, unavailable)
    @objc private func handleDeviceRegistrationConfirmed(_ notification: Notification) {
        guard let context = notification.userInfo?["context"] as? String else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self, context == WorkflowContext.current,
                  !self.storage.hasPendingWorkflowRegistration else { return }
            self.getInAppMessages()
        }
    }

    // MARK: Handle notifications
    
    @available(iOSApplicationExtension, unavailable)
    @objc
    private func handleApplicationDidBecomeActiveNotification(_ notification: Notification) {
        guard sdkStateHelper.isInitialized else { return }
        
        application = notification.object as? UIApplication
        
        DispatchQueue.global().async { [weak self] in
            self?.fetchBaseHTML { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.isAlreadyFetchBaseFile = true
                    self.inAppService.reprocessWorkflowMessages()
                    self.drainPendingEventTriggers()
                    guard let currentInAppMessage = self.currentInAppMessage else { return }
                    self.setupWebView(with: currentInAppMessage)
                    self.currentInAppMessage = nil
                }
            }
        }
    }
    
    @objc
    private func handleApplicationWillTerminateNotification(_ notification: Notification) {
        application = notification.object as? UIApplication
    }
    
    @objc
    private func handleApplicationDidEnterBackgroundNotification(_ notification: Notification) {
        application = notification.object as? UIApplication
        cancelPendingWorkflowPresentation()
    }

    @objc private func cancelPendingWorkflowPresentation() {
        guard workflowPresentationPending else { return }
        dismissInAppMessage(animated: false)
        dismissSlideUp(animated: false)
    }
}

// MARK: InAppScriptMessageHandler

@available(iOSApplicationExtension, unavailable)
extension InAppMessages: InAppScriptMessageHandler {
    
    func inAppMessageWebViewController(
        _ viewController: InAppMessageWebViewController,
        didReceive scriptMessage: InAppScriptMessage,
        in message: InApp
    ) {
        guard renderingController === viewController else { return }
        switch scriptMessage.type {
        case .completedLoading:
            guard viewController.beginPresentation() else { return }
            if let content = message as? InAppContent, content.isWorkflow,
               (UIApplication.shared.applicationState != .active || !inAppService.canPresentWorkflow(content)) {
                dismissInAppMessage(animated: false)
                dismissSlideUp(animated: false)
                return
            }
            let visible = { [weak self, weak viewController] in
                guard let self, let viewController,
                      self.renderingController === viewController,
                      viewController.viewIfLoaded?.window != nil else { return }
                if let content = message as? InAppContent, content.isWorkflow {
                    guard UIApplication.shared.applicationState == .active,
                          self.inAppService.canPresentWorkflow(content) else {
                        self.dismissInAppMessage(animated: false)
                        self.dismissSlideUp(animated: false)
                        return
                    }
                    self.workflowPresentationPending = false
                    self.currentInteractionId = content.iid
                    self.inAppService.sendInteraction(with: content)
                    self.scheduler.forcePushEvents()
                    self.inAppPresenters.removeAll { $0.model.message.isWorkflow && $0.model.message.iid == content.iid }
                } else if let content = message as? InAppContent {
                    let interactionId = UUID().uuidString
                    self.currentInteractionId = interactionId
                    self.inAppService.sendInteraction(with: content, interactionId: interactionId)
                }
                Reteno.inAppStatusHander?(.inAppIsDisplayed)
            }
            if let slideUpVC = viewController as? SlideUpMessageViewController,
               let payload = scriptMessage.payload as? SlideAppContentHeightPayload,
               message.layoutType == .slideUp || message.layoutType == .bottomBar {
                presentSlideUpMessage(message, in: slideUpVC, height: payload.contentHeight, animated: true, visible: visible)
            } else {
                presentInAppMessage(in: viewController, visible: visible)
            }
        case .failedLoading, .runtimeError:
            dismissInAppMessage(animated: false)
            dismissSlideUp(animated: false)
            currentInteractionId = nil
            Reteno.inAppStatusHander?(.inAppReceivedError(error: "Failed loading in-app"))
            guard let payload = scriptMessage.payload as? InAppScriptMessageErrorPayload else { return }

            let reason = (message as? InAppContent)?.isWorkflow == true ? "Workflow renderer failed" : payload.reason
            Logger.log("Failed loading in-app script: \(reason)", eventType: .error)
            inAppRequestService.sendScriptEvent(
                messageId: message.id,
                data: ["type": scriptMessage.type.rawValue, "payload": ["reason": reason]]
            )
            self.inAppService.sendInteraction(
                with: message,
                status: .failed,
                description: "Failed loading in-app script: \(reason)"
            )
            
        case .close:
            let action: InAppMessageAction = .init(isCloseButtonClicked: true)
            Reteno.inAppStatusHander?(.inAppShouldBeClosed(action: action))
            if message.layoutType == .slideUp || message.layoutType == .bottomBar {
                dismissSlideUp(swipeDirection: (scriptMessage.payload as? DismissSlideUpPayload)?.swipeDirection ?? .left,
                               action: action)
            } else {
                dismissInAppMessage(action: action)
            }
            
        case .openURL:
            let action: InAppMessageAction = .init(isOpenUrlClicked: true)
            Reteno.inAppStatusHander?(.inAppShouldBeClosed(action: action))
            if message.layoutType == .slideUp || message.layoutType == .bottomBar {
                dismissSlideUp(action: action)
            } else {
                dismissInAppMessage(action: action)
            }
            let payload = scriptMessage.payload as? InAppScriptMessageURLPayload
            handleInteraction(
                in: message,
                messageId: currentInteractionId ?? message.id,
                action: .init(
                    type: scriptMessage.type.rawValue,
                    targetComponentId: payload?.targetComponentId,
                    url: payload?.urlString
                )
            )
            DeepLinksProcessor.processLinks(
                wrappedUrl: nil,
                rawURL: payload?.urlString.flatMap { URL(string: $0) },
                customData: payload?.customData,
                isInAppMessageLink: true
            )
            
        case .click:
            let action: InAppMessageAction = .init(isButtonClicked: true)
            Reteno.inAppStatusHander?(.inAppShouldBeClosed(action: action))
            if message.layoutType == .slideUp || message.layoutType == .bottomBar {
                dismissSlideUp(action: action)
            } else {
                dismissInAppMessage(action: action)
            }
            if let payload = scriptMessage.payload as? InAppScriptMessageComponentPayload {
                handleInteraction(
                    in: message,
                    messageId: currentInteractionId ?? message.id,
                    action: .init(type: scriptMessage.type.rawValue, targetComponentId: payload.targetComponentId)
                )
            }
            
        case .unknown:
            Logger.log("Received unknown script message", eventType: .warning)
            self.inAppService.sendInteraction(
                with: message,
                status: .failed,
                description: "Received unknown script message"
            )
            currentInteractionId = nil
        }
    }
    
}
