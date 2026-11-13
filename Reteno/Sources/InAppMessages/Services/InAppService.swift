//
//  InAppService.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 30.01.2024.
//

import Foundation

final class InAppService {
    private static let cacheVersion = 1
    
    private let requestService: MobileRequestService
    private let storage: KeyValueStorage
    private let now: () -> Date
    private let context: () -> String
    private var activeContext: String
    private var authorizing: Set<String> = []
    private var authorizationGeneration = UUID()
    
    private var showModels: [InAppShowModel] = []
    
    private var inAppSegments: [InAppAsyncCheck] = []
    private var segmentCheck: InAppAsyncCheck.AsyncRetry?
    private var lastTimeSegmentsUpdate: [Int: Date] = [:]
    private var messages: [Message] = []
    private var contents: [InAppContent] = []
    
    var inAppContents: (([InAppContent], [InAppShowModel]) -> Void)?
    var discoveryFailed: (() -> Void)?
    var deliveryShowModels: (([InAppShowModel]) -> Void)?

    init(
        requestService: MobileRequestService,
        storage: KeyValueStorage,
        now: @escaping () -> Date = Date.init,
        context: @escaping () -> String = { DeliveryContext.current }
    ) {
        self.requestService = requestService
        self.storage = storage
        self.now = now
        self.context = context
        self.activeContext = context()
        self.ensureContext()
        self.migrateCacheIfNeeded()
        self.checkForActiveCache()
    }
    
    func getInAppMessages() {
        ensureContext()
        guard !storage.hasPendingDeliveryRegistration else {
            discoveryFailed?()
            return
        }
        let requestedContext = activeContext
        let eTAg: String? = self.storage.getValue(forKey: StorageKeys.eTag.rawValue)
        requestService.getInAppMessages(eTag: eTAg) { [weak self] result in
            guard let self else { return }
            guard requestedContext == self.context(), !self.storage.hasPendingDeliveryRegistration else { return }

            switch result {
            case .success(let success):
                self.messages = self.preserveDeliveryDeadlines(success.list.messages)
                self.storage.saveInAppMessages(messages: self.messages)
                self.processingInApps(messages: self.messages)
                if let eTag = success.etag {
                    self.storage.set(value: eTag, forKey: StorageKeys.eTag.rawValue)
                    self.storage.set(value: Date().timeIntervalSince1970, forKey: StorageKeys.inAppCacheLastUpdate.rawValue)
                }

            case .failure(let failure):
                if (failure as? APIStatusError)?.statusCode == 304 {
                    self.messages = storage.getInAppMessages()
                    self.contents = storage.getInAppMessageContents()
                    
                    self.processingInApps(messages: self.messages, isNeedDownloadContent: false)
                } else {
                    self.discoveryFailed?()
                }
            }
        }
    }
    
    func sendInteraction(
        with inApp: InApp,
        interactionId: String = UUID().uuidString,
        status: NewInteractionStatus = .opened,
        description: String? = nil,
        action: NotificationStatus.Action? = nil
    ) {
        guard let inAppContent = inApp as? InAppContent else {
            return
        }
        
        if inAppContent.hasServerAssignedIid {
            guard let iid = inAppContent.iid, UUID(uuidString: iid) != nil,
                  inAppContent.deliveryContext == context(), status != .clicked || action != nil else { return }
            var observation = NewInteraction(id: iid, time: now(), messageInstanceId: inAppContent.messageInstanceId,
                                             status: status, statusDescription: description, action: action)
            observation.serverAssignedIid = true
            if status == .opened {
                guard canPresentDelivery(inAppContent) else { return }
            }
            storage.recordDeliveryInteraction(observation, context: context(), now: now())
            return
        }
        let observation = NewInteraction(
            id: interactionId,
            time: now(),
            messageInstanceId: inAppContent.messageInstanceId,
            status: status,
            statusDescription: description,
            action: action
        )
        if status == .clicked {
            storage.recordDeliveryInteraction(observation, context: context(), now: now())
        } else {
            requestService.sendInteraction(interaction: observation)
        }
    }
    
    func clearInApps() {
        activeContext = context()
        storage.clearInApps()
        contents = []
        messages = []
        showModels = []
        cancelDeliveryAuthorizations()
        inAppSegments = []
        lastTimeSegmentsUpdate = [:]
        storage.removeValue(forKey: StorageKeys.eTag.rawValue)
        storage.removeValue(forKey: StorageKeys.inAppCacheLastUpdate.rawValue)
    }
    
    func reprocessInAppMessages() {
        ensureContext()
        guard !storage.hasPendingDeliveryRegistration, !messages.isEmpty else { return }
        processingInApps(messages: messages, isNeedDownloadContent: false)
    }
    
    func reprocessDeliveryMessages() {
        ensureContext()
        guard !storage.hasPendingDeliveryRegistration else {
            deliveryShowModels?([])
            return
        }
        processingInApps(messages: messages.filter { $0.hasServerAssignedIid }, isNeedDownloadContent: false, deliveryOnly: true)
    }

    private func processingInApps(messages: [Message], isNeedDownloadContent: Bool = true, deliveryOnly: Bool = false) {
        self.checkAsyncRulesSegment()
        var messageInstanceIds: [Int] = []
        var models: [InAppShowModel] = []

        let filteredMessage = self.shedulerChecks(messages)
                
        for item in filteredMessage {
            if item.hasServerAssignedIid && (!item.isAvailable(at: now()) || !deliveryRulesSupported(item) ||
                storage.hasShownDelivery(iid: item.iid ?? "", context: context())) { continue }
            let frequencyInfo = frequencyChecks(item)
            if frequencyInfo.isActive {
                
                if !item.hasServerAssignedIid { messageInstanceIds.append(item.messageInstanceId) }
                
                var conditions:[Condition] = []
                if item.displayRules.targeting.enabled {
                    for group in item.displayRules.targeting.schema?.include.groups ?? [] {
                        conditions.append(contentsOf: group?.conditions ?? [])
                    }
                }
                models.append(
                    .init(
                        message: item,
                        frequency: frequencyInfo.frequency,
                        frequencyParams: frequencyInfo.params,
                        conditions: conditions
                    )
                )
            }
        }
        
        if deliveryOnly {
            deliveryShowModels?(models)
            return
        }
        self.showModels = models
        if isNeedDownloadContent || self.contents.isEmpty {
            self.downloadInAppContents(messageInstanceIds: messageInstanceIds)
        } else {
            self.inAppContents?(self.contents, self.showModels)
        }
    }
    
    private func ensureContext() {
        let current = context()
        let saved: String? = storage.getValue(forKey: StorageKeys.inAppContext.rawValue)
        if saved != current || activeContext != current {
            if activeContext != current || (saved != nil && saved != current) {
                // Establish the barrier before advancing shared cache ownership.
                storage.beginDeliveryRegistration(context: current)
                storage.set(value: false, forKey: StorageKeys.isUpdatedDevice.rawValue)
            }
            clearInApps()
            storage.set(value: current, forKey: StorageKeys.inAppContext.rawValue)
        }
    }

    private func preserveDeliveryDeadlines(_ messages: [Message]) -> [Message] {
        messages.map { message in
            var message = message
            if message.hasServerAssignedIid, let iid = message.iid, UUID(uuidString: iid) != nil,
               let expiry = message.expiresAt, DeliveryDate.parse(expiry) != nil {
                message.expiresAt = storage.deliveryDeadline(iid: iid, proposed: expiry, context: context())
            }
            return message
        }
    }

    private func deliveryRulesSupported(_ message: Message) -> Bool {
        guard message.displayRules.deliverySupported else { return false }
        let targeting = message.displayRules.targeting
        guard targeting.enabled else { return true }
        guard let schema = targeting.schema, schema.include.relation == "AND" else { return false }
        var timeConditions = 0
        var eventConditions = 0
        for group in schema.include.groups {
            guard let group, group.relation == "AND", let conditions = group.conditions else { return false }
            for condition in conditions {
                guard condition.deliverySupported else { return false }
                if condition.operator == .timeSpentInApp,
                   let values = condition.values as? [Condition.Value], !values.isEmpty,
                   values.allSatisfy({ ($0.unit == .seconds || $0.unit == .minute) && ($0.amount ?? -1) >= 0 }) {
                    timeConditions += 1
                } else if condition.operand.name == .event, condition.operator == nil,
                          let events = condition.values as? [Condition.EventValue], !events.isEmpty,
                          events.allSatisfy({ $0.parameters.relation == "AND" && $0.parameters.values.allSatisfy { $0.operator != nil } }) {
                    eventConditions += 1
                } else {
                    Logger.log("Delivery deferred: unsupported targeting condition", eventType: .verbose)
                    return false
                }
            }
        }
        return timeConditions <= 1 && eventConditions <= 1
    }

    func canPresentDelivery(_ content: InAppContent) -> Bool {
        guard !storage.hasPendingDeliveryRegistration, content.hasServerAssignedIid, content.deliveryContext == context(), content.isAvailable(at: now()),
              let iid = content.iid, !storage.hasShownDelivery(iid: iid, context: context()),
              let message = messages.first(where: { $0.hasServerAssignedIid && $0.iid == iid && $0.messageInstanceId == content.messageInstanceId }),
              message.isAvailable(at: now()), deliveryRulesSupported(message),
              let evaluatedRules = content.deliveryRules,
              message.displayRules.nonFrequencyRulesData() == evaluatedRules,
              !shedulerChecks([message]).isEmpty else {
            return false
        }
        return true
    }

    func cancelDeliveryAuthorizations() {
        authorizationGeneration = UUID()
        authorizing.removeAll()
    }

    // Called only after the existing presenter has satisfied targeting/event/time rules.
    func authorizeDelivery(_ message: Message, completion: @escaping (InAppContent?) -> Void) {
        ensureContext()
        guard !storage.hasPendingDeliveryRegistration, message.hasServerAssignedIid, message.isAvailable(at: now()), deliveryRulesSupported(message),
              let iid = message.iid, !storage.hasShownDelivery(iid: iid, context: context()),
              !shedulerChecks([message]).isEmpty, !authorizing.contains(iid),
              let evaluatedRules = message.displayRules.nonFrequencyRulesData(),
              messages.contains(where: { $0.hasServerAssignedIid && $0.iid == iid &&
                  $0.messageInstanceId == message.messageInstanceId &&
                  $0.displayRules.nonFrequencyRulesData() == evaluatedRules }) else {
            completion(nil)
            return
        }
        let requestedContext = context()
        let generation = authorizationGeneration
        authorizing.insert(iid)
        requestService.getDeliveryContent(messages: [message]) { [weak self] result in
            guard let self else { completion(nil); return }
            guard generation == self.authorizationGeneration else { completion(nil); return }
            self.authorizing.remove(iid)
            guard requestedContext == self.context(), case .success(let response) = result,
                  var content = response.contents.first(where: { $0.iid == iid && $0.messageInstanceId == message.messageInstanceId }) else {
                Logger.log("Delivery content authorization unavailable", eventType: .verbose)
                completion(nil)
                return
            }
            content.expiresAt = message.expiresAt
            content.deliveryContext = requestedContext
            content.deliveryRules = evaluatedRules
            completion(self.canPresentDelivery(content) ? content : nil)
        }
    }

    private func frequencyChecks(_ message: Message) -> (isActive: Bool, frequency: PredicateName, params: FrequencyBaseParams?) {
        guard message.displayRules.frequency.enabled else {
            return (true, .noLimit, nil)
        }
        
        for predicate in message.displayRules.frequency.predicates.filter({ $0.isActive }) {
            switch predicate.name {
            case .noLimit:
                if hasEventCondition(in: message) {
                    return (true, predicate.name, predicate.params)
                } else {
                    let displayedInApps = storage.getNoLimitDisplayedInAppIds()
                    return (!displayedInApps.contains(message.messageId), predicate.name, predicate.params)
                }
                
            case .oncePerApp:
                let displayedInApps = storage.getOnlyOnceDisplayedInAppIds()
                return (!displayedInApps.contains(message.messageId), predicate.name, predicate.params)
                
            case .oncePerSession:
                let displayedInApps = storage.getOncePerSessionDisplayedInAppIds()
                return (!displayedInApps.contains(message.messageId), predicate.name, predicate.params)
            
            case .minInterval:
                let minIntervals = storage.getMinIntervalInApps()
                if let lastPresentDate = minIntervals[message.messageId], let params = predicate.params as? FrequencyParams {
                    let dateComponents = Date.dateComponets(units: [.hour, .day, .weekOfYear], date: lastPresentDate)
                    switch params.unit {
                    case .seconds, .minute, .hour:
                        return (true, predicate.name, predicate.params)

                    case .day:
                        if let day = dateComponents.day, day > params.amount {
                            return (true, predicate.name, predicate.params)
                        } else {
                            return (false, predicate.name, predicate.params)
                        }
                        
                    case .week:
                        if let week = dateComponents.weekOfYear, week > params.amount {
                            return (true, predicate.name, predicate.params)
                        } else {
                            return (false, predicate.name, predicate.params)
                        }
                    }
                } else {
                    return (true, predicate.name, predicate.params)
                }
            
            case .timesPerTimeUnit:
                let timesPerTimeUnits = storage.getTimePerTimeUnitInApps()
                if let dates = timesPerTimeUnits[message.messageId], dates.isNotEmpty,
                   let params = predicate.params as? FrequencyPerUnitParams, let lastPresentedDate = dates.last, params.count < dates.count {
                    
                    let dateComponents = Date.dateComponets(units: [.day, .weekOfYear], date: lastPresentedDate)
                    switch params.unit {
                    case .seconds, .minute, .hour:
                        return (true, predicate.name, predicate.params)

                    case .day:
                        if let day = dateComponents.day, day >= 1 {
                            return (true, predicate.name, predicate.params)
                        } else {
                            return (false, predicate.name, predicate.params)
                        }
                        
                    case .week:
                        if let week = dateComponents.weekOfYear, week >= 1 {
                            return (true, predicate.name, predicate.params)
                        } else {
                            return (false, predicate.name, predicate.params)
                        }
                    }
                } else {
                    return (true, predicate.name, predicate.params)
                }
            default:
                return (false, predicate.name, predicate.params)
            }
        }
        
        return (false, .unknown, nil)
    }

    private func hasEventCondition(in message: Message) -> Bool {
        guard message.displayRules.targeting.enabled,
              let groups = message.displayRules.targeting.schema?.include.groups
        else {
            return false
        }
        return groups.contains { group in
            guard let conditions = group?.conditions else { return false }
            return conditions.contains { $0.operator == nil && $0.operand.name == .event }
        }
    }
    
    private func shedulerChecks(_ messages: [Message]) -> [Message] {
        var filteredMessage: [Message] = []
        let dateFormatter = DateFormatter.scheduleDateFormatter
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        for message in messages {
            if message.displayRules.schedule.enabled {
                let schedulePredicates = message.displayRules.schedule.predicates
                var isValidPredicate: Bool = false
                for predicate in schedulePredicates {
                    dateFormatter.timeZone = TimeZone(identifier: predicate.params?.timeZone ?? "")
                    switch predicate.name {
                    case .showAfter, .hideAfter:
                        if let params = predicate.params as? Schedule.SchedulePredicate.DateParams,
                            let date = dateFormatter.date(from: params.date) {
                            if predicate.name == .showAfter {
                                isValidPredicate = now() > date
                            } else {
                                isValidPredicate = date > now()
                            }
                        } else {
                            isValidPredicate = false
                            break
                        }
                    case .specificDaysAndTime:
                        let dayInWeek = dayFormatter.string(from: now()).lowercased()
                        let time = Calendar.current.dateComponents([.hour, .minute], from: now())
                        if let params = predicate.params as? Schedule.SchedulePredicate.SpecificDate,
                           params.days.contains(dayInWeek) {
                            let timeFrom = "\(params.time.from.hours):\(params.time.from.minutes)"
                            let timeTo = "\(params.time.to.hours):\(params.time.to.minutes)" == "00:00" 
                                ? "23:59"
                                : "\(params.time.to.hours):\(params.time.to.minutes)"
                            let currentTime = "\(time.hour ?? 0):\(time.minute ?? 0) "

                            if timeFrom == "00:00", timeTo == "23:59" {
                                isValidPredicate = true
                            } else if let time = timeFormatter.date(from: currentTime),
                                      let timeFrom = timeFormatter.date(from: timeFrom),
                                      let timeTo = timeFormatter.date(from: timeTo) {
                                if time >= timeFrom, time <= timeTo {
                                    isValidPredicate = true
                                } else if timeTo < timeFrom,
                                          let toDate = Calendar.current.date(byAdding: .day, value: 1, to: timeTo) {
                                    if (time >= timeFrom && time <= toDate) || time <= timeTo {
                                        isValidPredicate = true
                                    } else {
                                        isValidPredicate = false
                                        break
                                    }
                                } else {
                                    isValidPredicate = false
                                    break
                                }
                            } else {
                                isValidPredicate = false
                                break
                            }
                        } else {
                            isValidPredicate = false
                            break
                        }
                    default:
                        isValidPredicate = false
                        break
                    }
                    if !isValidPredicate {
                        break
                    }
                }
                if isValidPredicate {
                    filteredMessage.append(message)
                }
            } else {
                filteredMessage.append(message)
            }
        }
        return filteredMessage
    }
    
    private func downloadInAppContents(messageInstanceIds: [Int]) {
        guard messageInstanceIds.isNotEmpty else {
            self.inAppContents?(self.contents, self.showModels)
            return
        }
        
        let requestedContext = context()
        requestService.getInAppMessageContent(messageInstanceIds: messageInstanceIds) { [weak self] result in
            guard let self else { return }
            guard requestedContext == self.context(), !self.storage.hasPendingDeliveryRegistration else { return }

            switch result {
            case .success(let result):
                self.contents = result.contents.filter { !$0.hasServerAssignedIid }
                self.storage.saveInAppMessageContents(contents: self.contents)
                self.inAppContents?(self.contents, self.showModels)
                
            case .failure:
                Logger.log("Ordinary in-app content unavailable", eventType: .warning)
                self.inAppContents?([], self.showModels.filter { $0.message.hasServerAssignedIid })
            }
        }
    }
    
    private func migrateCacheIfNeeded() {
        let storedVersion: Int = storage.getValue(forKey: StorageKeys.inAppCacheVersion.rawValue) ?? 0
        guard storedVersion < Self.cacheVersion else { return }
        
        /// Messages, contents and the eTag are dropped together: keeping the eTag would get `304 Not Modified`
        /// back and the SDK would restore messages without any contents, so no in-app could be shown until the
        /// eTag expires.
        clearInApps()
        storage.set(value: Self.cacheVersion, forKey: StorageKeys.inAppCacheVersion.rawValue)
    }
    
    private func checkForActiveCache() {
        guard let lastUpdatedDate: Double = storage.getValue(forKey: StorageKeys.inAppCacheLastUpdate.rawValue), lastUpdatedDate > 0 else {
            return
        }
        
        let lastDate = Date(timeIntervalSince1970: lastUpdatedDate)
        if DebugModeHelper.isDebugModeOn() {
            if Date().minutes(from: lastDate) >= 10 {
                self.storage.removeValue(forKey: StorageKeys.eTag.rawValue)
            }
        } else {
            let totalWeeks = Calendar.current.dateComponents([.weekOfMonth], from: lastDate, to: Date()).weekOfMonth
            
            if (totalWeeks ?? 0) >= 1 {
                self.storage.removeValue(forKey: StorageKeys.eTag.rawValue)
            }
        }
    }
    
    func checkAsyncRulesSegment(id: Int? = nil, completion: @escaping ([InAppAsyncCheck]) -> Void = { _ in }) {
        let requestedContext = context()
        if let id = id, self.inAppSegments.isNotEmpty {
            if isNeedRetryAsyncRules(id: id) {
                requestService.checkAsyncSegmentRules(ids: [id]) { [weak self] result in
                    guard let self = self, requestedContext == self.context() else { completion([]); return }

                    switch result {
                    case .success(let success):
                        self.inAppSegments.removeAll(where: { $0.segmentId == id })
                        self.inAppSegments.append(contentsOf: success.checks)
                        self.lastTimeSegmentsUpdate[id] = Date()
                        
                        completion(success.checks)
                        
                    default:
                        completion([])
                    }
                }
            } else {
                completion(self.inAppSegments.filter { $0.error == nil })
            }
        } else {
            let segments = messages.compactMap { $0.displayRules.async.segment.enabled ? $0.displayRules.async.segment.segmentId : nil }

            guard segments.isNotEmpty else {
                completion([])
                return
            }
            
            requestService.checkAsyncSegmentRules(ids: segments) { [weak self] result in
                guard let self = self, requestedContext == self.context() else { completion([]); return }

                switch result {
                case .success(let success):
                    self.inAppSegments = success.checks
                    _ = success.checks.map { self.lastTimeSegmentsUpdate[$0.segmentId] = Date() }
                    completion(success.checks)
                    
                default:
                    completion([])
                }
            }
        }
    }
    
    private func isNeedRetryAsyncRules(id: Int) -> Bool {
        guard let segment = self.inAppSegments.first(where: { $0.segmentId == id }) else {
            return true
        }
        
        if let error = segment.error {
            switch error.status {
            case 500, 422:
                return false
                
            case 429:
                let timeInterval = getRetryAfterTimeInterval(retry: error.retryAfter)
                if let date = lastTimeSegmentsUpdate[id], date.addingTimeInterval(timeInterval) <= Date() {
                    return true
                } else {
                    return false
                }
                
            default:
                return false
            }
        } else {
            if let date = lastTimeSegmentsUpdate[id], Date().minutes(from: date) >= 5 {
                return true
            } else {
                return false
            }
        }
    }
    
    private func getRetryAfterTimeInterval(retry: InAppAsyncCheck.AsyncRetry.RetryAfter?) -> TimeInterval {
        guard let retry = retry else {
            return 0
        }
        
        switch retry.unit {
        case .seconds:
            return TimeInterval(retry.amount)
            
        case .minute:
            return TimeInterval(retry.amount * 60)

        case .hour:
            return TimeInterval(retry.amount * 60 * 60)
        
        default:
            return TimeInterval(300)
        }
    }
}
