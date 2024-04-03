//
//  InAppService.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 30.01.2024.
//

import Foundation

final class InAppService {
    private let requestService: MobileRequestService
    private let storage: KeyValueStorage
    
    private var showModels: [InAppShowModel] = []
    
    private var inAppSegments: [InAppAsyncCheck] = []
    private var segmentCheck: InAppAsyncCheck.AsyncRetry?
    private var lastTimeSegmentsUpdate: [Int: Date] = [:]
    private var messages: [Message] = []
    private var contents: [InAppContent] = []
    
    var inAppContents: (([InAppContent], [InAppShowModel]) -> Void)?

    init(
        requestService: MobileRequestService,
        storage: KeyValueStorage
    ) {
        self.requestService = requestService
        self.storage = storage
        self.checkForActiveCache()
    }
    
    func getInAppMessages() {
        let eTAg: String? = self.storage.getValue(forKey: StorageKeys.eTag.rawValue)
        requestService.getInAppMessages(eTag: eTAg) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let success):
                self.messages = success.list.messages
                self.storage.saveInAppMessages(messages: success.list.messages)
                self.processingInApps(messages: success.list.messages)
                if let eTag = success.etag {
                    self.storage.set(value: eTag, forKey: StorageKeys.eTag.rawValue)
                    self.storage.set(value: Date().timeIntervalSince1970, forKey: StorageKeys.inAppCacheLastUpdate.rawValue)
                }

            case .failure(let failure):
                if failure.asAFError?.responseCode == 304 {
                    self.messages = storage.getInAppMessages()
                    self.contents = storage.getInAppMessageContents()
                    
                    self.processingInApps(messages: self.messages, isNeedDownloadContent: false)
                }
            }
        }
    }
    
    func sendInteraction(
        with inApp: InApp,
        interactionId: String = UUID().uuidString,
        status: NewInteractionStatus = .opened,
        description: String? = nil
    ) {
        guard let inAppContent = inApp as? InAppContent else {
            return
        }
        
        requestService.sendInteraction(
            interaction: .init(
                id: interactionId,
                time: Date(),
                messageInstanceId: inAppContent.messageInstanceId,
                status: status,
                statusDescription: description
            )
        )
    }
    
    private func processingInApps(messages: [Message], isNeedDownloadContent: Bool = true) {
        self.checkAsyncRulesSegment()
        var messageInstanceIds: [Int] = []
        self.showModels = []
        
        let filteredMessage = self.shedulerChecks(messages)
                
        for item in filteredMessage {
            let frequencyInfo = frequencyChecks(item)
            if frequencyInfo.isActive {
                
                messageInstanceIds.append(item.messageInstanceId)
                
                var conditions:[Condition] = []
                if item.displayRules.targeting.enabled {
                    for conditionGroups in item.displayRules.targeting.schema!.include.groups {
                        conditions.append(contentsOf: conditionGroups!.conditions!)
                    }
                }
                showModels.append(
                    .init(
                        message: item,
                        frequency: frequencyInfo.frequency,
                        frequencyParams: frequencyInfo.params,
                        conditions: conditions
                    )
                )
            }
        }
        
        if isNeedDownloadContent || self.contents.isEmpty {
            self.downloadInAppContents(messageInstanceIds: messageInstanceIds)
        } else {
            self.inAppContents?(self.contents, self.showModels)
        }
    }
    
    private func frequencyChecks(_ message: Message) -> (isActive: Bool, frequency: PredicateName, params: FrequencyBaseParams?) {
        guard message.displayRules.frequency.enabled else {
            return (false, .unknown, nil)
        }
        
        for predicate in message.displayRules.frequency.predicates.filter({ $0.isActive }) {
            switch predicate.name {
            case .noLimit:
                if message.displayRules.targeting.schema?.include.groups.isNotEmpty ?? false {
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
                                isValidPredicate = Date() > date
                            } else {
                                isValidPredicate = date > Date()
                            }
                        } else {
                            isValidPredicate = false
                            break
                        }
                    case .specificDaysAndTime:
                        let dayInWeek = dayFormatter.string(from: Date()).lowercased()
                        let time = Calendar.current.dateComponents([.hour, .minute], from: Date())
                        if let params = predicate.params as? Schedule.SchedulePredicate.SpecificDate,
                           params.days.contains(dayInWeek) {
                            let timeFrom = "\(params.time.from.hours):\(params.time.from.minutes)"
                            let timeTo = "\(params.time.to.hours):\(params.time.to.minutes)" == "00:00" 
                                ? "23:59"
                                : "\(params.time.to.hours):\(params.time.to.minutes)"
                            let currentTime = "\(time.hour ?? 0):\(time.minute ?? 0) "

                            if timeFrom == "00:00", timeTo == "23:59" {
                                isValidPredicate = true
                            } else if let time = timeFormatter.date(from: currentTime), let timeFrom = timeFormatter.date(from: timeFrom), let timeTo = timeFormatter.date(from: timeTo), time >= timeFrom, time <= timeTo {
                                isValidPredicate = true
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
        
        requestService.getInAppMessageContent(messageInstanceIds: messageInstanceIds) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let result):
                self.contents = result.contents
                self.storage.saveInAppMessageContents(contents: result.contents)
                self.inAppContents?(result.contents, self.showModels)
                
            case .failure(let failure):
                print(failure)
            }
        }
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
        if let id = id, self.inAppSegments.isNotEmpty {
            if isNeedRetryAsyncRules(id: id) {
                requestService.checkAsyncSegmentRules(ids: [id]) { [weak self] result in
                    guard let self = self else { return }

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
                completion(self.inAppSegments)
            }
        } else {
            let segments = messages.compactMap { $0.displayRules.async.segment.enabled ? $0.displayRules.async.segment.segmentId : nil }

            guard segments.isNotEmpty else {
                completion([])
                return
            }
            
            requestService.checkAsyncSegmentRules(ids: segments) { [weak self] result in
                guard let self = self else { return }

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
                if let date = lastTimeSegmentsUpdate[id], date.addingTimeInterval(timeInterval) >= Date() {
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
