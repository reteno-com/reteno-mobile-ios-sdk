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
        isSubscribedOnPush: Bool,
        completionHandler: @escaping (Result<Bool, Error>) -> Void = { _ in }
    ) {
        let languageCode = Locale.current.languageCode
        let pushToken = RetenoNotificationsHelper.deviceToken() ?? ""
        let category = try? DeviceCategoryHelper.deviceType()
        let request = DeviceRequest(
            category: category ?? .mobile,
            languageCode: languageCode,
            pushToken: pushToken,
            isSubscribedOnPush: isSubscribedOnPush,
            externalUserId: externalUserId
        )
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler) { result in
            completionHandler(result)
        }
    }
    
    func updateUserAttributes(
        user: User,
        completionHandler: @escaping (Result<Bool, Error>) -> Void = { _ in }
    ) {
        let externalUserId: String = {
            guard
                let externalUserId = user.externalUserId,
                !externalUserId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else { return ExternalUserIdHelper.getId() ?? "" }
            
            return externalUserId
        }()
        
        guard
            !externalUserId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || user.isAnonymous
        else {
            let error = NetworkError(statusCode: 400, title: "Error", detail: "Empty external user id", invalidParams: nil)
            completionHandler(.failure(error))
            return
        }
        
        let request = UpdateUserAttributesRequest(
            externalUserId: user.isAnonymous ? nil : externalUserId,
            userAttributes: user.userAttributes,
            subscriptionKeys: user.subscriptionKeys,
            groupNamesInclude: user.groupNamesInclude,
            groupNamesExclude: user.groupNamesExclude
        )
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler) { result in
            completionHandler(result)
        }
    }
    
    func getInAppMessage(by id: String, completionHandler: @escaping (Result<InAppMessage, Error>) -> Void) {
        let request = InAppMessageRequest(id: id)
        let handler = DecodableResponseHandler<InAppMessage>()

        requestManager.execute(request: request, responseHandler: handler, completionHandler: completionHandler)
    }
    
}

// MARK: EventsSender

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

// MARK: Inbox Messages

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
    
    func markInboxMessagesAsOpened(ids: [String]? = nil, completion: @escaping (Result<Bool, Error>) -> Void) {
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

// MARK: Recommendations

extension MobileRequestService {
    
    func getRecoms<T: RecommendableProduct>(
        recomVariantId: String,
        productIds: [String],
        categoryId: String,
        filters: [RecomFilter]?,
        fields: [String]?,
        completionHandler: @escaping (Result<[T], Error>) -> Void
    ) {
        let request = RecomsRequest(
            recomVariantId: recomVariantId,
            productIds: productIds,
            categoryId: categoryId,
            filters: filters,
            fields: fields
        )
        let handler = RecomsResponseHandler<T>()
        
        requestManager.execute(request: request, responseHandler: handler, completionHandler: completionHandler)
    }
    
    func sendRecomEvents(_ events: [RecomEvents], completionHandler: @escaping (Result<Bool, Error>) -> Void = { _ in }) {
        let request = RecomEventsRequest(events: events)
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler, completionHandler: completionHandler)
    }
    
}
