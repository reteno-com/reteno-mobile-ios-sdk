//
//  MobileRequestService.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 29.09.2022.
//

import Alamofire
import Foundation

final class MobileRequestService {
    
    private let requestManager: RequestManager
    
    init(requestManager: RequestManager = NetworkBuilder.buildMobileApiManager()) {
        self.requestManager = requestManager
    }
    
    func upsertDevice(
        externalUserId: String? = nil,
        completionHandler: @escaping (Result<Bool, Error>) -> Void = { _ in }
    ) {
        let languageCode = Locale.current.languageCode
        let pushToken = RetenoNotificationsHelper.deviceToken() ?? ""
        let category = try? DeviceCategoryHelper.deviceType()
        let request = DeviceRequest(
            category: category ?? .mobile,
            languageCode: languageCode,
            pushToken: pushToken,
            externalUserId: externalUserId
        )
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler) { result in
            switch result {
            case .success(let success):
                print("request result: \(success)")
            case .failure(let failure):
                print("request failure: \(failure)")
            }
            completionHandler(result)
        }
    }
    
    func updateUserAttributes(
        user: User,
        completionHandler: @escaping (Result<Bool, Error>) -> Void = { _ in }
    ) {
        let externalUserId = user.externalUserId ?? ExternalUserIdHelper.getId() ?? ""
        let request = UpdateUserAttributesRequest(
            externalUserId: externalUserId,
            userAttributes: user.userAttributes,
            subscriptionKeys: user.subscriptionKeys,
            groupNamesInclude: user.groupNamesInclude,
            groupNamesExclude: user.groupNamesExclude
        )
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler) { result in
            switch result {
            case .success(let success):
                print("request result: \(success)")
            case .failure(let failure):
                print("request failure: \(failure)")
            }
            completionHandler(result)
        }
    }
    
}

// MARK: - EventsSender

extension MobileRequestService: EventsSender {
    
    func sendEvents(_ events: [Event], completionHandler: @escaping (Result<Void, Error>) -> Void = { _ in }) {
        let request = EventRequest(events: events)
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler) { result in
            switch result {
            case .success:
                completionHandler(.success(()))
                
            case .failure(let failure):
                completionHandler(.failure(failure))
            }
        }
    }
    
}

// MARK: - Inbox Messages

extension MobileRequestService {
    
    func getInboxMessages(
        page: Int?,
        pageSize: Int?,
        completion: @escaping (Result<AppInboxMessagesResponse, Error>) -> Void
    ) {
        let request = AppInboxMessagesRequest(page: page, pageSize: pageSize)
        let handler = DecodableResponseHandler<AppInboxMessagesResponse>()
        
        requestManager.execute(request: request, responseHandler: handler, completionHandler: completion)
    }
    
    func markInboxMessagesAsOpened(ids: [String], completion: @escaping (Result<Bool, Error>) -> Void) {
        let request = AppInboxMarkAsOpenedRequest(ids: ids)
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler, completionHandler: completion)
    }
    
    func getInboxMessagesCount(completion: @escaping (Result<AppInboxMessagesCountResponse, Error>) -> Void) {
        let request = AppInboxMessagesCountRequest()
        let handler = DecodableResponseHandler<AppInboxMessagesCountResponse>()
        
        requestManager.execute(request: request, responseHandler: handler, completionHandler: completion)
    }
    
}
