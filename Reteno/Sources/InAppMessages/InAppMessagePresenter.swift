//
//  InAppMessagePresenter.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 06.02.2024.
//

import Foundation

struct InAppShowModel {
    let message: Message
    let frequency: PredicateName
    let frequencyParams: FrequencyBaseParams?
    let conditions: [Condition]
}

class InAppMessagePresenter {
    let model: InAppShowModel
    private let storage: KeyValueStorage
    
    private let presentInApp: ((Message, Bool) -> Void)?
    private var fireTime: Int = 0
    private var events: [Condition.EventValue] = []

    init(model: InAppShowModel, storage: KeyValueStorage, presentInApp: ((Message, Bool) -> Void)?) {
        self.model = model
        self.storage = storage
        self.presentInApp = presentInApp
        self.procesingInApp()
    }
    
    func isEqual(id: Int) -> Bool {
        model.message.messageId == id
    }
    
    func procesingInApp() {
        let conditions = model.conditions.filter { $0.operator != .newUser }
        
        if conditions.isEmpty {
            self.procesignInApp(noCondition: true)
        } else {
            if let timeSpendInAppCondition = conditions.first(where: { $0.operator == .timeSpentInApp
            }), let values = timeSpendInAppCondition.values as? [Condition.Value]  {
                for value in values {
                    switch value.unit {
                    case .seconds:
                        self.fireTime += value.amount ?? 0
                        
                    case .minute:
                        self.fireTime += (value.amount ?? 0) * 60
                        
                    default:
                        self.fireTime = 0
                    }
                }
            }
            
            if let afterEvent = conditions.first(where: { $0.operator == nil && $0.operand.name == .event}), let events = afterEvent.values as? [Condition.EventValue] {
                self.events = events
            }
        }
    }
    
    func isHasTimeCondition() -> Bool {
        fireTime > 0 || model.frequency == .minInterval
    }
    
    func isHasEventConditions() -> Bool {
        events.count > 0 || model.frequency == .minInterval
    }
    
    private func isHasAllCondition() -> Bool {
        isHasTimeCondition() && isHasEventConditions()
    }
    
    func updateTimeSpendInApp(time: Int) {
        if model.frequency == .minInterval || model.frequency == .timesPerTimeUnit {
            if fireTime == 0 {
                self.procesignInApp(isTimeCondition: true)
            } else if time >= fireTime  {
                self.procesignInApp(isTimeCondition: true)
            }
        } else if time == fireTime {
            self.procesignInApp(isTimeCondition: true)
        }
    }
    
    func checkEvent(eventTypeName: String, parameters: [Event.Parameter]) {
        if let event = self.events.first(where: { eventTypeName == $0.event }) {
            var allConditionsFine: Bool = event.parameters.values.isEmpty
            for trigerEvent in event.parameters.values {
                if let customParams = parameters.first(where: { $0.name == trigerEvent.name }) {
                    switch trigerEvent.operator {
                    case .contains, .containsOneOf:
                        allConditionsFine = trigerEvent.value.contains(customParams.value)
    
                    case .equals:
                        let filtered = trigerEvent.value.filter { customParams.value.elementsEqual($0) }
                        allConditionsFine = filtered.isNotEmpty
                        
                    case .startsWith:
                        let filtered = trigerEvent.value.filter { customParams.value.hasPrefix($0) }
                        allConditionsFine = filtered.isNotEmpty

                    case .endsWith:
                        let filtered = trigerEvent.value.filter { customParams.value.hasSuffix($0) }
                        allConditionsFine = filtered.isNotEmpty
                        
                    case .regex:
                        let filtered = trigerEvent.value.filter { customParams.value.range(of: $0, options: .regularExpression, range: nil, locale: nil) != nil }
                        allConditionsFine = filtered.isNotEmpty
                        
                    case .none:
                        allConditionsFine = false
                        break
                    }
                    if !allConditionsFine {
                        break
                    }
                } else {
                    allConditionsFine = false
                    break
                }
            }
            if allConditionsFine {
                self.procesignInApp(isTimeCondition: false)
            }
        }
    }
    
    private func procesignInApp(noCondition:Bool = false, isTimeCondition: Bool = false) {
        if isCanBePresented() {
            self.presentInApp?(self.model.message, isCanBeDelete(noCondition: noCondition, isTimeCondition: isTimeCondition))
        }
    }
    
    private func isCanBeDelete(noCondition:Bool = false, isTimeCondition: Bool = false) -> Bool {
        guard model.frequency != .minInterval && model.frequency != .noLimit && model.frequency != .timesPerTimeUnit else  {
            return false
        }
        
        guard !noCondition else {
            return true
        }
        
        if isTimeCondition {
            return events.isEmpty
        } else {
            return fireTime == 0
        }
    }
    
    private func isCanBePresented() -> Bool {
        switch model.frequency {
        case .minInterval:
            return minIntervalPresentedCheck()
            
        case .timesPerTimeUnit:
            return timePerUnitPresentedCheck()
            
        default:
            return true
        }
    }
    
    private func minIntervalPresentedCheck() -> Bool {
        guard let params = model.frequencyParams as? FrequencyParams else {
            return false
        }
                    
        guard let lastPresentedDate = storage.getMinIntervalInApps()[model.message.messageId] else {
            return true
        }
        
        let units: [Calendar.Component] =  [.second, .minute, .hour, .day, .weekOfYear]
        let component = Date.dateComponets(units: units, date: lastPresentedDate)
        switch params.unit {
        case .seconds:
            return component.second ?? 0 >= params.amount
            
        case .minute:
            return component.minute ?? 0 >= params.amount
            
        case .hour:
            return component.hour ?? 0 >= params.amount
            
        case .day:
            return component.day ?? 0 >= params.amount
            
        case .week:
            return component.weekOfYear ?? 0 >= params.amount
        }
    }
    
    private func timePerUnitPresentedCheck() -> Bool {
        guard let params = model.frequencyParams as? FrequencyPerUnitParams else {
            return false
        }
        
        guard let dates = storage.getTimePerTimeUnitInApps()[model.message.messageId], let lastPresentedDate = dates.last else {
            return true
        }
        
        guard dates.count < params.count  else {
            return false
        }
        
        let units: [Calendar.Component] =  [.minute, .hour, .day, .weekOfYear]
        let component = Date.dateComponets(units: units, date: lastPresentedDate)

        
        switch params.unit {
        case .seconds:
            return component.second ?? 0 >= 1
            
        case .minute:
            return component.minute ?? 0 >= 1

        case .hour:
            return component.hour ?? 0 >= 1

        case .day:
            return component.day ?? 0 >= 1
            
        case .week:
            return component.weekOfYear ?? 0 >= 1
        }
    }
}
