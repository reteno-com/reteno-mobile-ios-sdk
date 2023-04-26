//
//  InAppMessages.swift
//  
//
//  Created by Anna Sahaidak on 18.01.2023.
//

import UIKit

@available(iOSApplicationExtension, unavailable)
final class InAppMessages {
    
    private var application: UIApplication?
    private var window: UIWindow?
    
    private var currentInAppMessage: InAppMessage?
    
    private let mobileRequestService: MobileRequestService
    private let inAppRequestService: InAppRequestService
    private let storage: KeyValueStorage
    private let scheduler: EventsSenderScheduler
    
    init(
        mobileRequestService: MobileRequestService,
        inAppRequestService: InAppRequestService,
        storage: KeyValueStorage,
        scheduler: EventsSenderScheduler = Reteno.senderScheduler
    ) {
        self.mobileRequestService = mobileRequestService
        self.inAppRequestService = inAppRequestService
        self.storage = storage
        self.scheduler = scheduler
    }
    
    func presentInApp(by id: String) {
        mobileRequestService.getInAppMessage(by: id) { [weak self] result in
            switch result {
            case .success(let message):
                guard let self = self else { return }
                
                if self.application?.isActive == true {
                    self.setupWebView(with: message)
                } else {
                    self.currentInAppMessage = message
                }
                
            case .failure(let error):
                Logger.log(error.localizedDescription, eventType: .error)
            }
        }
    }
    
    // MARK: Subscribe on notifications
    
    func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationDidBecomeActiveNotification),
            name: UIApplication.didBecomeActiveNotification,
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
                        SentryHelper.capture(error: error)
                    }
                    completion()
                }
                
            case .failure(let error):
                SentryHelper.capture(error: error)
                completion()
            }
        }
    }
    
    private func setupWebView(with message: InAppMessage) {
        let viewController = InAppMessageWebViewController(with: message)
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
            SentryHelper.captureWarningEvent(message: "Couldn't resolve window to present InApp")
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
    
    private func dismissInAppMessage(animated: Bool = true) {
        func hide() {
            window?.removeFromSuperview()
            window = nil
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
    
    // MARK: Handle interaction
    
    private func handleInteraction(messageId: String, action: NotificationStatus.Action) {
        let status = NotificationStatus(interactionId: messageId, status: .clicked, date: Date(), action: action)
        storage.addNotificationStatus(status)
        scheduler.forcePushEvents()
    }
    
    // MARK: Handle notifications
    
    @objc
    private func handleApplicationDidBecomeActiveNotification(_ notification: Notification) {
        application = notification.object as? UIApplication
        
        DispatchQueue.global().async { [weak self] in
            self?.fetchBaseHTML { [weak self] in
                guard let currentInAppMessage = self?.currentInAppMessage else { return }

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }

                    self.setupWebView(with: currentInAppMessage)
                    self.currentInAppMessage = nil
                }
            }
        }
    }

}

// MARK: InAppScriptMessageHandler

@available(iOSApplicationExtension, unavailable)
extension InAppMessages: InAppScriptMessageHandler {
    
    func inAppMessageWebViewController(
        _ viewController: InAppMessageWebViewController,
        didReceive scriptMessage: InAppScriptMessage,
        in message: InAppMessage
    ) {
        switch scriptMessage.type {
        case .completedLoading:
            presentInAppMessage(in: viewController)
            
        case .failedLoading, .runtimeError:
            guard let payload = scriptMessage.payload as? InAppScriptMessageErrorPayload else { return }

            Logger.log("Failed loading in-app script: \(payload.reason)", eventType: .error)
            inAppRequestService.sendScriptEvent(
                messageId: message.id,
                data: ["type": scriptMessage.type.rawValue, "payload": ["reason": payload.reason]]
            )
            
        case .close:
            dismissInAppMessage()
            
        case .openURL:
            dismissInAppMessage()
            if let payload = scriptMessage.payload as? InAppScriptMessageURLPayload,
               let url = URL(string: payload.urlString) {
                handleInteraction(
                    messageId: message.id,
                    action: .init(
                        type: scriptMessage.type.rawValue,
                        targetComponentId: payload.targetComponentId,
                        url: payload.urlString
                    )
                )
                DeepLinksProcessor.processLinks(wrappedUrl: nil, rawURL: url)
            }
            
        case .click:
            dismissInAppMessage()
            if let payload = scriptMessage.payload as? InAppScriptMessageComponentPayload {
                handleInteraction(
                    messageId: message.id,
                    action: .init(type: scriptMessage.type.rawValue, targetComponentId: payload.targetComponentId)
                )
            }
            
        case .unknown:
            Logger.log("Received unknown script message", eventType: .warning)
        }
    }
    
}
