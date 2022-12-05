//
//  EventsSenderScheduler.swift
//  Reteno
//
//  Created by Anna Sahaidak on 12.10.2022.
//

import Foundation
import UIKit

final class EventsSenderScheduler {
    
    weak var messagesCountInbox: AppInbox? {
        didSet {
            if messagesCountInbox.isSome {
                forceFetchMessagesCount()
            }
        }
    }
    
    /// Mobile request service
    private let mobileRequestService: MobileRequestService
    /// Notification interaction status updater
    private let sendingService: SendingServices
    /// Local storage, based on `UserDefaults`
    private let storage: KeyValueStorage
    
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid
    
    private var sendingTimer: Timer?
    
    private var application: UIApplication?
    
    private var lastForcePushTimestamp: Date?
    
    /// time interval resolvers
    private var timeIntervalResolver: () -> TimeInterval
    private var randomOffsetResolver: () -> TimeInterval
    
    // MARK: Lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        sendingTimer?.invalidate()
        sendingTimer = nil
    }
    
    init(
        mobileRequestService: MobileRequestService,
        storage: KeyValueStorage = StorageBuilder.build(),
        sendingService: SendingServices = SendingServiceBuilder.build(),
        timeIntervalResolver: @escaping () -> TimeInterval = { Reteno.eventsSendingTimeInterval },
        randomOffsetResolver: @escaping () -> TimeInterval = { TimeInterval((0...10).randomElement() ?? 1) }
    ) {
        self.mobileRequestService = mobileRequestService
        self.storage = storage
        self.sendingService = sendingService
        self.timeIntervalResolver = timeIntervalResolver
        self.randomOffsetResolver = randomOffsetResolver
        
        subscribeOnNotifications()
    }
        
    func updateNotificationInteractionStatus(interactionId: String, status: InteractionStatus, date: Date) {
        let status = NotificationStatus(interactionId: interactionId, status: status, date: date)
        storage.addNotificationStatus(status)
        
        // Added random time offset to reduce server load
        let randomTimeOffset = TimeInterval((0...5).randomElement() ?? 1)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + randomTimeOffset) { [weak self] in
            self?.forcePushEvents()
        }
    }
    
    func updateUserAttributes(
        externalUserId: String?,
        userAttributes: UserAttributes?,
        subscriptionKeys: [String],
        groupNamesInclude: [String],
        groupNamesExclude: [String]
    ) {
        let user = User(
            externalUserId: externalUserId,
            userAttributes: userAttributes,
            subscriptionKeys: subscriptionKeys,
            groupNamesInclude: groupNamesInclude,
            groupNamesExclude: groupNamesExclude
        )
        storage.addUser(user)
        
        forcePushEvents()
    }
    
    func forcePushEvents() {
        if let lastForcePushTimestamp = lastForcePushTimestamp, Date().timeIntervalSince(lastForcePushTimestamp) < 1 {
            return
        }
        
        sendCollectedData()
        lastForcePushTimestamp = Date()
    }
    
    // MARK: Subscribe on notifications
    
    func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationDidFinishLaunchingNotification(_:)),
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationWillEnterForegroundNotification(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    // MARK: Task scheduling
    
    func scheduleTask() {
        sendingTimer?.invalidate()
        sendingTimer = nil
        sendingTimer = Timer.scheduledTimer(
            withTimeInterval: timeIntervalResolver() + randomOffsetResolver(),
            repeats: true,
            block: { [weak self] _ in
                self?.sendCollectedData()
            }
        )
    }
    
    private func sendCollectedData() {
        backgroundTaskIdentifier = application?.beginBackgroundTask(expirationHandler: { [weak self] in
            guard let self = self else { return }
            
            self.operationQueue.cancelAllOperations()
            self.endTask()
        }) ?? .invalid
        
        let operations = prepareOperationSequence()
        let completionOperation = Operation()
        for operation in operations {
            completionOperation.addDependency(operation)
        }
        completionOperation.completionBlock = { [weak self] in
            guard let self = self else { return }
            
            let oldNotificationStatuses = self.storage.getNotificationStatuses().filter { !$0.isValid }
            if oldNotificationStatuses.isNotEmpty {
                SentryHelper.captureLog(title: NotificationStatus.logTitle, count: oldNotificationStatuses.count)
                self.storage.clearOldNotificationStatusesCache()
            }
            self.endTask()
        }
        
        operationQueue.addOperation(completionOperation)
        operationQueue.addOperations(operations, waitUntilFinished: false)
    }
    
    private func prepareOperationSequence() -> [Operation] {
        var operations = sendNotificationsStatusOperations() + sendUsersOperations()
        if let sendEventOperation = sendEventsOperation() {
            operations.append(sendEventOperation)
        }
        if let sendRecomEventsOperation = sendRecomEventsOperation() {
            operations.append(sendRecomEventsOperation)
        }
        if let sendAppInboxMessagesIdsOperation = sendAppInboxMessagesIdsOperation() {
            operations.append(sendAppInboxMessagesIdsOperation)
        }
        operations.sort(by: { $0.date < $1.date })
        Operation.makeDependencies(forOperations: operations)
        let serviceOperations = prepareServiceOperations()
        
        return operations + serviceOperations
    }
    
    private func prepareServiceOperations() -> [Operation] {
        var operations: [Operation] = []
        if let messageCountOperation = messagesCountOperation() {
            operations.append(messageCountOperation)
        }
        
        return operations
    }
    
    private func endTask() {
        application?.endBackgroundTask(self.backgroundTaskIdentifier)
        backgroundTaskIdentifier = .invalid
    }
    
    func forceFetchMessagesCount() {
        guard let messagesOperation = messagesCountOperation() else { return }
        
        operationQueue.addOperation(messagesOperation)
    }
    
    // MARK: Sending logic
    
    private func sendNotificationsStatusOperations() -> [DateOperation] {
        let statuses = storage.getNotificationStatuses()
        let validStatuses = statuses.filter { $0.isValid }
        
        guard !validStatuses.isEmpty else { return [] }
        
        return statuses.map {
            SendNotificationsStatusOperation(sendingService: sendingService, storage: storage, notificationStatus: $0)
        }
    }
    
    private func sendUsersOperations() -> [DateOperation] {
        let users = storage.getUsers()
        
        guard !users.isEmpty else { return [] }
        
        return users.map { SendUserOperation(storage: storage, user: $0) }
    }
    
    private func sendEventsOperation() -> DateOperation? {
        let oldEvents = storage.getEvents().filter { !$0.isValid }
        if oldEvents.isNotEmpty {
            SentryHelper.captureLog(title: Event.logTitle, count: oldEvents.count)
            storage.clearEvents(oldEvents)
        }
        
        let events = storage.getEvents()
        let validEvents = events.filter { $0.isValid }
        
        guard !validEvents.isEmpty else { return nil }
        
        return SendEventsOperation(requestService: mobileRequestService, storage: storage, events: validEvents)
    }
    
    func messagesCountOperation() -> Operation? {
        guard let inbox = messagesCountInbox else { return nil }
        
        return MessagesCountOperation(requestService: MobileRequestServiceBuilder.buildWithDeviceIdInHeaders(), inbox: inbox)
    }
    
    private func sendRecomEventsOperation() -> DateOperation? {
        let oldEvents = storage.getRecomEvents().filter { !$0.isValid }
        if oldEvents.isNotEmpty {
            SentryHelper.captureLog(title: RecomEvents.logTitle, count: oldEvents.count)
            storage.clearRecomEvents(oldEvents)
        }
        
        let validEvents = storage.getRecomEvents().filter { $0.isValid }
        
        guard validEvents.isNotEmpty else { return nil }
        
        return SendRecomEventsOperation(
            requestService: MobileRequestServiceBuilder.buildWithDeviceIdInHeaders(),
            storage: storage,
            events: validEvents
        )
    }
    
    private func sendAppInboxMessagesIdsOperation() -> DateOperation? {
        let oldIds = storage.getInboxOpenedMessagesIds().filter { !$0.isValid }
        if oldIds.isNotEmpty {
            SentryHelper.captureLog(title: AppInboxMessageStorableId.logTitle, count: oldIds.count)
            storage.clearInboxOpenedMessagesIds(oldIds)
        }
        
        let validIds = storage.getInboxOpenedMessagesIds().filter { $0.isValid }
        
        guard validIds.isNotEmpty else { return nil }
        
        return SendAppInboxMessagesIdsOperation(
            requestService: MobileRequestServiceBuilder.buildWithDeviceIdInHeaders(),
            storage: storage,
            ids: validIds
        )
    }
    
    // MARK: Handle notifications
    
    @objc
    private func handleApplicationDidFinishLaunchingNotification(_ notification: Notification) {
        application = notification.object as? UIApplication
        scheduleTask()
    }
    
    @objc
    private func handleApplicationWillEnterForegroundNotification(_ notification: Notification) {
        application = notification.object as? UIApplication
        scheduleTask()
    }
    
}
