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
    
    private var isAlreadySendRequest: Bool = false
    private var isAlreadyFetchBaseFile: Bool = false
    
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
    func presentInApp(by id: String) {
        mobileRequestService.getInAppMessage(by: id) { [weak self] result in
            switch result {
            case .success(let message):
                guard let self = self else { return }
                
                if self.application?.isActive == true {
                    Reteno.inAppStatusHander?(.inAppShouldBeDisplayed)
                    self.setupWebView(with: message)
                } else {
                    self.currentInAppMessage = message
                }
                
            case .failure(let error):
                Logger.log(error.localizedDescription, eventType: .error)
            }
        }
    }
    
    @available(iOSApplicationExtension, unavailable)
    func presentInApp(by content: InAppContent) {
        Reteno.inAppStatusHander?(.inAppShouldBeDisplayed)
        self.setupWebView(with: content)
    }
    
    func logEventTrigger(eventTypeKey: String, parameters: [Event.Parameter]) {
        if parameters.first(where: { $0.name == ScreenClass })?.value != "InAppMessageWebViewController" {
            for inApp in inAppPresenters {
                if inApp.isHasEventConditions() {
                    inApp.checkEvent(eventTypeName: eventTypeKey, parameters: parameters)
                }
            }
        }
    }
    
    @available(iOSApplicationExtension, unavailable)
    func setInAppMessagesPause(isPaused: Bool) {
        isPausedInApps = isPaused
        
        guard !isPaused, inAppMessagesPauseBehaviour == .postponeInApps, let inAppToShow = postponeInAppInfo.first else {
            return
        }
        
        if let segmentID = inAppToShow.segmentId {
            self.inAppService.checkAsyncRulesSegment(id: segmentID) { checks in
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
    
    func setInAppMessagesPauseBehaviour(pauseBehaviour: PauseBehaviour) {
        inAppMessagesPauseBehaviour = pauseBehaviour
    }
    
    func checkSegments() {
        self.inAppService.checkAsyncRulesSegment()
    }
    
    private func inAppPresentersSelections () {
        sessionService.timeSpendInApp = { [weak self] time in
            guard let self = self else { return }

            for inAppPresenter in inAppPresenters {
                if inAppPresenter.isHasTimeCondition() {
                    inAppPresenter.updateTimeSpendInApp(time: time)
                }
            }
        }
    }
    
    // MARK: Subscribe on notifications
    
    @available(iOSApplicationExtension, unavailable)
    func subscribeOnNotifications() {
        self.sessionService.subscribeOnNotifications()
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
        inAppRequestService.fetchBaseHTML { [weak self] result in
            switch result {
            case .success(let version):
                guard
                    let self = self,
                    let version = version,
                    self.storage.getValue(forKey: StorageKeys.inAppMessageBaseHTMLVersion.rawValue) != version
                else {
                    completion()
                    return
                }
                
                self.inAppRequestService.downloadBaseHTML { result in
                    switch result {
                    case .success:
                        self.storage.set(value: version, forKey: StorageKeys.inAppMessageBaseHTMLVersion.rawValue)
                        
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
        
        inAppService.getInAppMessages()

        inAppService.inAppContents = { [weak self] contents, showModels in
            guard let self = self else { return }
            
            self.isAlreadySendRequest = false
            self.presentingInApp(contents: contents, showModels: showModels)
        }
    }
    
    @available(iOSApplicationExtension, unavailable)
    private func presentingInApp(contents: [InAppContent], showModels: [InAppShowModel]) {
        for showModel in showModels {
            let presenter: InAppMessagePresenter = .init(model: showModel, storage: storage) { inApp, canDelete in
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
            self.inAppPresenters.append(presenter)
        }
        self.inAppPresentersSelections()
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
    private func setupWebView(with message: InApp) {
        let viewController = InAppMessageWebViewController(
            with: message,
            inAppService: inAppService
        )
        viewController.delegate = self
        viewController.view.layoutIfNeeded()
    }
    
    private func presentInAppMessage(animated: Bool = true, in viewController: UIViewController) {
        // window for new In-app message
        var window: UIWindow?
        
        func completion() {
            // Check if some in-app is being already presented
            if self.window.isSome {
                dismissInAppMessage(animated: false)
            }
            self.window = window
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
        window?.isHidden = false
        if window.isNone {
            ErrorLogger.shared.captureWarningEvent(message: "Couldn't resolve window to present InApp")
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.25,
                animations: { window?.alpha = 1.0 },
                completion: { _ in completion() }
            )
        } else {
            window?.alpha = 1.0
            completion()
        }
    }
    
    private func dismissInAppMessage(action: InAppMessageAction? = nil, animated: Bool = true) {
        func hide() {
            window?.removeFromSuperview()
            window = nil
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
    
    // MARK: Processing InApps
    
    private func processingInApp(showModel: InAppShowModel, canDelete: Bool) {
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
        } else if showModel.frequency == .noLimit, showModel.conditions.isEmpty {
            self.storage.addNoLimitDisplayedId(id: showModel.message.messageId)
        }
    }
    
    // MARK: Handle interaction
    
    private func handleInteraction(messageId: String, action: NotificationStatus.Action) {
        let status = NotificationStatus(interactionId: messageId, status: .clicked, date: Date(), action: action)
        storage.addNotificationStatus(status)
        scheduler.forcePushEvents()
    }
    
    // MARK: Handle notifications
    
    @available(iOSApplicationExtension, unavailable)
    @objc
    private func handleApplicationDidBecomeActiveNotification(_ notification: Notification) {
        application = notification.object as? UIApplication
        
        DispatchQueue.global().async { [weak self] in
            self?.fetchBaseHTML { [weak self] in
                self?.isAlreadyFetchBaseFile = true
                guard let currentInAppMessage = self?.currentInAppMessage else { return }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
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
        switch scriptMessage.type {
        case .completedLoading:
            presentInAppMessage(in: viewController)
            Reteno.inAppStatusHander?(.inAppIsDisplayed)
            currentInteractionId = nil
            guard let inAppContent = message as? InAppContent else {
                return
            }
            
            let intecationId = UUID().uuidString
            currentInteractionId = intecationId
            self.inAppService.sendInteraction(with: inAppContent, interactionId: intecationId)
            
        case .failedLoading, .runtimeError:
            currentInteractionId = nil
            Reteno.inAppStatusHander?(.inAppReceivedError(error: "Failed loading in-app"))
            guard let payload = scriptMessage.payload as? InAppScriptMessageErrorPayload else { return }

            Logger.log("Failed loading in-app script: \(payload.reason)", eventType: .error)
            inAppRequestService.sendScriptEvent(
                messageId: message.id,
                data: ["type": scriptMessage.type.rawValue, "payload": ["reason": payload.reason]]
            )
            self.inAppService.sendInteraction(
                with: message,
                status: .failed,
                description: "Failed loading in-app script: \(payload.reason)"
            )
            
        case .close:
            let action: InAppMessageAction = .init(isCloseButtonClicked: true)
            Reteno.inAppStatusHander?(.inAppShouldBeClosed(action: action))
            dismissInAppMessage(action: action)
            
        case .openURL:
            let action: InAppMessageAction = .init(isOpenUrlClicked: true)
            Reteno.inAppStatusHander?(.inAppShouldBeClosed(action: action))
            dismissInAppMessage(action: action)
            let payload = scriptMessage.payload as? InAppScriptMessageURLPayload
            handleInteraction(
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
            dismissInAppMessage(action: action)
            if let payload = scriptMessage.payload as? InAppScriptMessageComponentPayload {
                handleInteraction(
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
