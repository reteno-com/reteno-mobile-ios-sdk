//
//  EventsSenderScheduler.swift
//  Reteno
//
//  Created by Anna Sahaidak on 12.10.2022.
//

import Foundation
import UIKit
import Combine

final class EventsSenderScheduler {
    
    weak var messagesCountInbox: AppInbox? {
        didSet {
            if messagesCountInbox.isSome {
                forceFetchMessagesCount()
            }
        }
    }
    
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    private let pendingDeviceOperationsAccessQueue: DispatchQueue = DispatchQueue(label: "com.reteno.pendingDeviceOperationsAccessQueue")
    
    private var pendingSendDeviceOperations: [SendDeviceOperation] = []
    private var sendingTimer: Timer?
    private var application: UIApplication?
    
    private let syncStateQueue = DispatchQueue(label: "com.reteno.syncStateQueue")
    private var isSyncInProgress = false
    private var isSyncRequested = false
    /// time interval resolvers
    private var timeIntervalResolver: () -> TimeInterval
    private var randomOffsetResolver: () -> TimeInterval
    /// Mobile request service
    private let mobileRequestService: MobileRequestService
    /// Notification interaction status updater
    private let sendingService: SendingServices
    /// Local storage, based on `UserDefaults`
    private let storage: KeyValueStorage
    
    private var pendingWorkItem: DispatchWorkItem?
    
    private var sdkStateHelper: SDKStateHelper {
        Reteno.sdkStateHelper
    }
    
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
    
    func upsertDevice(_ device: Device, date: Date = Date()) {
        /// Captured before hopping queues: the upsert belongs to the device id current at the call,
        /// even if a multi-account switch rewrites it before the operation runs.
        let identity = RequestIdentity(deviceId: DeviceIdHelper.deviceId() ?? "", externalUserId: device.externalUserId)
        pendingDeviceOperationsAccessQueue.async { [weak self] in
            guard let self else { return }
            
            /// `prepareOperationSequence` re-requests the device on every sync until the backend
            /// confirms it, so an identical upsert that is still pending has to be dropped here -
            /// otherwise a failing device request piles up one more operation per sync.
            guard !pendingSendDeviceOperations.contains(where: { $0.device == device && $0.identity == identity }) else { return }
            
            if device.isSubscribedOnPush != StorageBuilder.build().getValue(forKey: StorageKeys.isPushSubscribed.rawValue) {
                sendPushSubscriptionEvent(isSubscribed: device.isSubscribedOnPush)
            }
            let operation = SendDeviceOperation(
                requestService: mobileRequestService,
                storage: storage,
                device: device,
                identity: identity,
                date: date
            )
            operation.completionBlock = { [weak self] in
                self?.pendingDeviceOperationsAccessQueue.async {
                    self?.pendingSendDeviceOperations.removeAll(where: { $0.uuid == operation.uuid })
                }
            }
            pendingSendDeviceOperations.append(operation)
            operationQueue.addOperation(operation)
        }
    }
    
    func forceUpdateNotificationInteractionStatus(interactionId: String, status: InteractionStatus, date: Date) {
        let notificationStatus = NotificationStatus(interactionId: interactionId, status: status, date: date)
        let token = RetenoNotificationsHelper.deviceToken() ?? ""
        if token.isEmpty {
            ErrorLogger.shared.captureWarningEvent(
                message: "Sending interaction status with empty token",
                tags: [
                    "reteno.interaction_id": notificationStatus.interactionId,
                    "reteno.interaction_status": notificationStatus.status.rawValue
                ]
            )
        }
        sendingService.updateInteractionStatus(
            status: notificationStatus,
            token: token
        ) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                if let responseCode = (error as? APIStatusError)?.statusCode {
                    switch responseCode {
                    case 400...499:
                        self?.updateNotificationInteractionStatus(
                            interactionId: notificationStatus.interactionId,
                            status: notificationStatus.status,
                            date: notificationStatus.date,
                            action: notificationStatus.action
                        )
                        break
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func updateNotificationInteractionStatus(
        interactionId: String,
        status: InteractionStatus,
        date: Date,
        action: NotificationStatus.Action? = nil
    ) {
        let notificationStatus = NotificationStatus(interactionId: interactionId, status: status, date: date, action: action)
        storage.addNotificationStatus(notificationStatus)
        
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
        groupNamesExclude: [String],
        isAnonymous: Bool
    ) {
        let user: User
        let cachedLastUser: User?
        if let tempUser = storage.getCachedUser(), tempUser.isValid {
            cachedLastUser = tempUser
        } else {
            storage.clearCachedUser()
            cachedLastUser = nil
        }
        if let lastUser = cachedLastUser, lastUser.externalUserId == externalUserId, externalUserId != nil {
            let userUpdates = User(
                externalUserId: externalUserId,
                userAttributes: userAttributes,
                subscriptionKeys: subscriptionKeys,
                groupNamesInclude: groupNamesInclude,
                groupNamesExclude: groupNamesExclude,
                isAnonymous: isAnonymous
            )
            
            guard userUpdates != cachedLastUser else {
                NotificationCenter.default.post(name: Reteno.userUpdateCompleted, object: nil)
                return
            }
            
            let attributesToSend = UserAttributes(
                phone: lastUser.userAttributes?.phone == userAttributes?.phone ? nil : userAttributes?.phone,
                email: lastUser.userAttributes?.email == userAttributes?.email ? nil : userAttributes?.email,
                firstName: lastUser.userAttributes?.firstName == userAttributes?.firstName ? nil : userAttributes?.firstName,
                lastName: lastUser.userAttributes?.lastName == userAttributes?.lastName ? nil : userAttributes?.lastName,
                languageCode: lastUser.userAttributes?.languageCode == userAttributes?.languageCode ? nil : userAttributes?.languageCode,
                timeZone: lastUser.userAttributes?.timeZone == userAttributes?.timeZone ? nil : userAttributes?.timeZone,
                marketId: lastUser.userAttributes?.marketId == userAttributes?.marketId ? nil : userAttributes?.marketId,
                address: lastUser.userAttributes?.address == userAttributes?.address ? nil : userAttributes?.address,
                fields: lastUser.userAttributes?.fields == userAttributes?.fields ? [] : (userAttributes?.fields ?? [])
            )
            
            let userToSend = User(
                externalUserId: externalUserId,
                userAttributes: attributesToSend == lastUser.userAttributes ? nil : attributesToSend ,
                subscriptionKeys: subscriptionKeys == lastUser.subscriptionKeys ? [] : subscriptionKeys,
                groupNamesInclude: groupNamesInclude == lastUser.groupNamesInclude ? [] : groupNamesInclude,
                groupNamesExclude: groupNamesExclude == lastUser.groupNamesExclude ? [] : groupNamesExclude,
                isAnonymous: isAnonymous
            )
            
            let attributes = userToSend.userAttributes
            guard attributes?.phone != nil || attributes?.email != nil || attributes?.firstName != nil || attributes?.lastName != nil || attributes?.languageCode != nil || attributes?.timeZone != nil || attributes?.address != nil || attributes?.marketId != nil || attributes?.fields.isNotEmpty ?? false || userToSend.subscriptionKeys.isNotEmpty || userToSend.groupNamesInclude.isNotEmpty || userToSend.groupNamesExclude.isNotEmpty  else {
                /// Not store, and not send request if all fields are same
                NotificationCenter.default.post(name: Reteno.userUpdateCompleted, object: nil)
                return
            }
            
            let attributesToSave = UserAttributes(
                phone: lastUser.userAttributes?.phone == userAttributes?.phone
                ? userAttributes?.phone : userAttributes?.phone ?? lastUser.userAttributes?.phone,
                email: lastUser.userAttributes?.email == userAttributes?.email ? userAttributes?.email : userAttributes?.email ?? lastUser.userAttributes?.email,
                firstName: lastUser.userAttributes?.firstName == userAttributes?.firstName ? userAttributes?.firstName : userAttributes?.firstName ?? lastUser.userAttributes?.firstName,
                lastName: lastUser.userAttributes?.lastName == userAttributes?.lastName ? userAttributes?.lastName : userAttributes?.lastName ?? lastUser.userAttributes?.lastName,
                languageCode: lastUser.userAttributes?.languageCode == userAttributes?.languageCode ? userAttributes?.languageCode : userAttributes?.languageCode ?? lastUser.userAttributes?.languageCode,
                timeZone: lastUser.userAttributes?.timeZone == userAttributes?.timeZone ? userAttributes?.timeZone : userAttributes?.timeZone ?? lastUser.userAttributes?.timeZone,
                marketId: lastUser.userAttributes?.marketId == userAttributes?.marketId ? userAttributes?.marketId : userAttributes?.marketId ?? lastUser.userAttributes?.marketId,
                address: lastUser.userAttributes?.address == userAttributes?.address ? userAttributes?.address : userAttributes?.address ?? lastUser.userAttributes?.address,
                fields: lastUser.userAttributes?.fields == userAttributes?.fields ? userAttributes?.fields ?? [] : userAttributes?.fields ?? lastUser.userAttributes?.fields ?? []
            )
            let userToSave = User(
                externalUserId: externalUserId,
                userAttributes: attributesToSave,
                subscriptionKeys: lastUser.subscriptionKeys == subscriptionKeys ? subscriptionKeys : subscriptionKeys.isEmpty ? lastUser.subscriptionKeys : [],
                groupNamesInclude: lastUser.groupNamesInclude == groupNamesInclude ? groupNamesInclude : groupNamesInclude.isEmpty ? lastUser.groupNamesInclude : [],
                groupNamesExclude: lastUser.groupNamesExclude == groupNamesExclude ? groupNamesExclude : groupNamesExclude.isEmpty ? lastUser.groupNamesExclude : [],
                isAnonymous: isAnonymous
            )
            
            user = userToSend
            storage.updateCachedUser(userToSave)
        } else {
            user = User(
                externalUserId: externalUserId,
                userAttributes: userAttributes,
                subscriptionKeys: subscriptionKeys,
                groupNamesInclude: groupNamesInclude,
                groupNamesExclude: groupNamesExclude,
                isAnonymous: isAnonymous
            )
            storage.updateCachedUser(user)
        }
        storage.addUser(user)
        
        forcePushEvents()
    }
    
    func forcePushEvents() {
        guard sdkStateHelper.isInitialized else {
            Logger.log("Events could be logged only by initialized Reteno, finish it.", eventType: .warning)
            return
        }
        
        requestSync()
    }
    
    func forceFetchMessagesCount() {
        guard sdkStateHelper.isInitialized else { return }
        
        guard let messagesOperation = messagesCountOperation() else { return }
        
        operationQueue.addOperation(messagesOperation)
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationDidBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationDidBecomeActiveNotification(_:)),
            name: Reteno.retenoDidBecomeActive,
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
                self?.requestSync()
            }
        )
    }
    
    
    private func requestSync() {
        syncStateQueue.async { [weak self] in
            guard let self else { return }
            
            guard !isSyncInProgress else {
                isSyncRequested = true
                return
            }
            
            startSync(previousBackgroundTask: nil)
        }
    }
    
    private func startSync(previousBackgroundTask: SyncBackgroundTask?) {
        isSyncInProgress = true
        sendCollectedData { [weak self] backgroundTask, canStartNextSync in
            guard let self else {
                backgroundTask?.end()
                return
            }
            
            completeSync(backgroundTask: backgroundTask, canStartNextSync: canStartNextSync)
        }
        previousBackgroundTask?.end()
    }
    
    private func completeSync(backgroundTask: SyncBackgroundTask?, canStartNextSync: Bool) {
        syncStateQueue.async { [weak self] in
            guard let self else {
                backgroundTask?.end()
                return
            }
            
            isSyncInProgress = false
            if isSyncRequested, canStartNextSync {
                isSyncRequested = false
                startSync(previousBackgroundTask: backgroundTask)
            } else {
                backgroundTask?.end()
            }
        }
    }
    
    private func sendCollectedData(completion: @escaping (SyncBackgroundTask?, Bool) -> Void) {
        guard Reteno.sdkStateHelper.isInitialized else {
            completion(nil, true)
            return
        }
        
        let syncCompletion = SyncCompletion(handler: completion)
        let backgroundTask = SyncBackgroundTask(application: application) { [weak self] in
            /// Out of background time. Drop everything that has not started yet; an operation that
            /// is already executing keeps its request in flight and finishes on its own callback -
            /// cutting it short is exactly what used to make the next sync resend the same payload.
            ///
            /// The sync slot is released right here so that a response that never arrives cannot
            /// latch the scheduler for the rest of the process lifetime. The serial queue still
            /// keeps the in-flight operation ahead of anything a later sync enqueues, and every
            /// operation re-checks the storage before sending, so nothing goes out twice.
            self?.operationQueue.cancelAllOperations()
            syncCompletion.complete(backgroundTask: nil, canStartNextSync: false)
        }
        
        let operations = prepareOperationSequence()
        let completionOperation = Operation()
        for operation in operations {
            completionOperation.addDependency(operation)
        }
        completionOperation.completionBlock = { [weak self] in
            guard let self = self else {
                syncCompletion.complete(backgroundTask: backgroundTask, canStartNextSync: true)
                return
            }
            
            let oldNotificationStatuses = self.storage.getNotificationStatuses().filter { !$0.isValid }
            if oldNotificationStatuses.isNotEmpty {
                ErrorLogger.shared.captureItems(
                    oldNotificationStatuses,
                    title: NotificationStatus.logTitle,
                    tagTitle: NotificationStatus.keyTitle
                )
                self.storage.clearOldNotificationStatusesCache()
            }
            let oldLinks = self.storage.getLinks().filter { !$0.isValid }
            if oldLinks.isNotEmpty {
                ErrorLogger.shared.captureItems(
                    oldLinks,
                    title: StorableLink.logTitle,
                    tagTitle: StorableLink.keyTitle
                )
                self.storage.clearLinks(oldLinks)
            }
            syncCompletion.complete(backgroundTask: backgroundTask, canStartNextSync: true)
        }
        
        operationQueue.addOperation(completionOperation)
        operationQueue.addOperations(operations, waitUntilFinished: false)
    }
    
    private func prepareOperationSequence() -> [Operation] {
        if storage.hasPendingDeliveryRegistration || storage.getValue(forKey: StorageKeys.isUpdatedDevice.rawValue) == false {
            upsertDevice(
                Device(
                    externalUserId: ExternalUserIdHelper.getId(),
                    phone: ExternalUserDataHelper.getPhone(),
                    email: ExternalUserDataHelper.getEmail(),
                    isSubscribedOnPush: RetenoNotificationsHelper.isPushSubscribed()
                )
            )
        }
        let userOperation = sendUsersOperations()
        var operations = userOperation + registerWrappedLinkClickOperations()
        if let lastUserOperation = userOperation.last {
            lastUserOperation.completionBlock =  {
                let queue = DispatchQueue(label: UUID().uuidString)
                let delay = DispatchTime.now() + .seconds(5)
                queue.asyncAfter(deadline: delay) {
                    Reteno.inAppMessages().checkSegments()
                }
            }
        }
        
        operations.append(contentsOf: storage.pendingDeliveryInteractions(context: DeliveryContext.current, now: Date()).map {
            SendDeliveryInteractionOperation(requestService: mobileRequestService, storage: storage, queued: $0)
        })
        operations.append(contentsOf: sendEventsOperations())
        operations.append(contentsOf: sendRecomEventsOperations())
        operations.append(contentsOf: sendAppInboxMessagesIdsOperations())
        if let sendErrorEventOperation = sendErrorEventsOperation() {
            operations.append(sendErrorEventOperation)
        }
        
        operations.sort(by: { $0.date < $1.date })
        operations.insert(contentsOf: sendNotificationsStatusOperations().sorted(by: { $0.date < $1.date }), at: 0)
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
    
    // MARK: Sending logic
    
    private func sendNotificationsStatusOperations() -> [DateOperation] {
        let statuses = storage.getNotificationStatuses()
        let validStatuses = statuses.filter { $0.isValid }
        
        guard !validStatuses.isEmpty else { return [] }
        
        return validStatuses.map {
            SendNotificationsStatusOperation(sendingService: sendingService, storage: storage, notificationStatus: $0)
        }
    }
    
    private func sendUsersOperations() -> [DateOperation] {
        let users = storage.getUsers()
        
        guard !users.isEmpty else { return [] }
        
        return users.map { SendUserOperation(storage: storage, user: $0) }
    }
    
    /// Splits queued data into groups that are sent with the same identity, keeping the original order.
    private func groupedByIdentity<T>(_ items: [T], identity: (T) -> RequestIdentity?) -> [(identity: RequestIdentity, items: [T])] {
        var groups: [(identity: RequestIdentity, items: [T])] = []
        for item in items {
            let resolvedIdentity = RequestIdentity.resolved(identity(item))
            if let index = groups.firstIndex(where: { $0.identity == resolvedIdentity }) {
                groups[index].items.append(item)
            } else {
                groups.append((resolvedIdentity, [item]))
            }
        }
        
        return groups
    }
    
    private func sendEventsOperations() -> [DateOperation] {
        let oldEvents = storage.getEvents().filter { !$0.isValid }
        if oldEvents.isNotEmpty {
            ErrorLogger.shared.captureItems(oldEvents, title: Event.logTitle, tagTitle: Event.keyTitle)
            storage.clearEvents(oldEvents)
        }
        
        let events = storage.getEvents()
        let validEvents = events.filter { $0.isValid }
        
        return groupedByIdentity(validEvents, identity: \.identity).map { group in
            SendEventsOperation(
                requestService: mobileRequestService,
                storage: storage,
                events: group.items,
                identity: group.identity
            )
        }
    }
    
    func messagesCountOperation() -> Operation? {
        guard let inbox = messagesCountInbox else { return nil }
        
        return MessagesCountOperation(requestService: MobileRequestServiceBuilder.buildWithDeviceIdInHeaders(), inbox: inbox)
    }
    
    private func sendRecomEventsOperations() -> [DateOperation] {
        let oldEvents = storage.getRecomEvents().filter { !$0.isValid }
        if oldEvents.isNotEmpty {
            ErrorLogger.shared.captureLog(title: RecomEvents.logTitle, count: oldEvents.count)
            storage.clearRecomEvents(oldEvents)
        }
        
        let validEvents = storage.getRecomEvents().filter { $0.isValid }
        
        return groupedByIdentity(validEvents, identity: \.identity).map { group in
            SendRecomEventsOperation(
                requestService: MobileRequestServiceBuilder.buildWithDeviceIdInHeaders(identity: group.identity),
                storage: storage,
                events: group.items
            )
        }
    }
    
    private func sendAppInboxMessagesIdsOperations() -> [DateOperation] {
        let oldIds = storage.getInboxOpenedMessagesIds().filter { !$0.isValid }
        if oldIds.isNotEmpty {
            ErrorLogger.shared.captureLog(title: AppInboxMessageStorableId.logTitle, count: oldIds.count)
            storage.clearInboxOpenedMessagesIds(oldIds)
        }
        
        let validIds = storage.getInboxOpenedMessagesIds().filter { $0.isValid }
        
        return groupedByIdentity(validIds, identity: \.identity).map { group in
            SendAppInboxMessagesIdsOperation(
                requestService: MobileRequestServiceBuilder.buildWithDeviceIdInHeaders(identity: group.identity),
                storage: storage,
                ids: group.items
            )
        }
    }
    
    private func registerWrappedLinkClickOperations() -> [DateOperation] {
        let links = storage.getLinks()
        let validLinks = links.filter { $0.isValid }
        
        guard !validLinks.isEmpty else { return [] }
        
        return validLinks.map {
            RegisterLinkClickOperation(
                requestService: SendingServiceBuilder.buildServiceWithEmptyURL(),
                storage: storage,
                link: $0
            )
        }
    }
    
    private func sendErrorEventsOperation() -> DateOperation? {
        let events = storage.getErrorEvents()
        
        guard !events.isEmpty else { return nil }
        
        return SendErrorEventsOperation(
            requestService: SendingServiceBuilder.buildServiceWithEmptyURL(),
            storage: storage,
            events: events
        )
    }
    
    // MARK: Push subscription event
    
    private func sendPushSubscriptionEvent(isSubscribed: Bool) {
        pendingWorkItem?.cancel()
        
        pendingWorkItem = DispatchWorkItem {
            let subscribedKey = "PushNotificationsSubscribed"
            let unsubscribedKey = "PushNotificationsUnsubscribed"
            let eventTypeKey = isSubscribed ? subscribedKey : unsubscribedKey
            Reteno.logEvent(eventTypeKey: eventTypeKey, parameters: [], forcePush: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: pendingWorkItem!)
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
    
    @objc
    private func handleApplicationDidBecomeActiveNotification(_ notification: Notification) {
        guard sdkStateHelper.isInitialized else { return }
        
        RetenoNotificationsHelper.isSubscribedOnNotifications { [weak self] isSubscribed in
            if isSubscribed != StorageBuilder.build().getValue(forKey: StorageKeys.isPushSubscribed.rawValue) {
                self?.sendPushSubscriptionEvent(isSubscribed: isSubscribed)
                StorageBuilder.build().set(value: isSubscribed, forKey: StorageKeys.isPushSubscribed.rawValue)
                let device = Device(
                    externalUserId: ExternalUserIdHelper.getId(),
                    phone: ExternalUserDataHelper.getPhone(),
                    email: ExternalUserDataHelper.getEmail(),
                    isSubscribedOnPush: isSubscribed
                )
                self?.upsertDevice(device)
            }
        }
    }
}


/// Runs a sync's completion exactly once.
///
/// A sync finishes either when its operation sequence drains or when the background task expires
/// with a request still in flight, and both can happen for the same sync. Letting the completion
/// run twice would release the sync slot twice and allow two sequences to be built from the same
/// storage snapshot - the overlap that sends events more than once.
private final class SyncCompletion {
    
    private let lock = NSLock()
    private var handler: ((SyncBackgroundTask?, Bool) -> Void)?
    
    init(handler: @escaping (SyncBackgroundTask?, Bool) -> Void) {
        self.handler = handler
    }
    
    func complete(backgroundTask: SyncBackgroundTask?, canStartNextSync: Bool) {
        lock.lock()
        let handler = self.handler
        self.handler = nil
        lock.unlock()
        
        guard let handler else {
            backgroundTask?.end()
            
            return
        }
        
        handler(backgroundTask, canStartNextSync)
    }
    
}


private final class SyncBackgroundTask {
    
    private let lock = NSLock()
    private let application: UIApplication?
    private var identifier: UIBackgroundTaskIdentifier = .invalid
    private var isEnded = false
    
    init(application: UIApplication?, expirationHandler: @escaping () -> Void) {
        self.application = application
        
        let identifier = application?.beginBackgroundTask(expirationHandler: {
            expirationHandler()
            self.end()
        }) ?? .invalid
        
        lock.lock()
        let isEnded = self.isEnded
        if !isEnded {
            self.identifier = identifier
        }
        lock.unlock()
        
        if isEnded, identifier != .invalid {
            application?.endBackgroundTask(identifier)
        }
    }
    
    func end() {
        lock.lock()
        let identifier = self.identifier
        self.identifier = .invalid
        isEnded = true
        lock.unlock()
        
        guard identifier != .invalid else { return }
        
        application?.endBackgroundTask(identifier)
    }
    
}
