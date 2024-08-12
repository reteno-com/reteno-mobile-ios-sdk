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
        email: String?,
        phone: String?,
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
            externalUserId: externalUserId,
            email: email,
            phone: phone
        )
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler) { result in
            completionHandler(result)
        }
    }
    
    func isEqualDeviceRequest(
        externalUserId: String? = nil,
        email: String?,
        phone: String?,
        isSubscribedOnPush: Bool,
        cachedRequestParams: [String: Any]?
    ) -> (isEqual: Bool, paramsToSave: [String: Any]?) {
        let languageCode = Locale.current.languageCode
        let pushToken = RetenoNotificationsHelper.deviceToken() ?? ""
        let category = try? DeviceCategoryHelper.deviceType()
        let request = DeviceRequest(
            category: category ?? .mobile,
            languageCode: languageCode,
            pushToken: pushToken,
            isSubscribedOnPush: isSubscribedOnPush,
            externalUserId: externalUserId,
            email: email,
            phone: phone
        )
        guard let newParams = request.parameters, let cached = cachedRequestParams else {
            return (false, nil)
        }
        
        return (NSDictionary(dictionary: newParams).isEqual(cached), request.parameters)
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
        categoryId: String?,
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

// MARK: InApp

extension MobileRequestService {
    
    func getInAppMessage(by id: String, completionHandler: @escaping (Result<InAppMessage, Error>) -> Void) {
        let request = InAppMessageRequest(id: id)
        let handler = DecodableResponseHandler<InAppMessage>()
        
        requestManager.execute(request: request, responseHandler: handler, completionHandler: completionHandler)
    }
    
    func getInAppMessages(eTag: String?, completionHandler: @escaping (Result<(list: InAppMessageLists, etag: String?), Error>) -> Void) {
        let request = InAppMessagesRequest(eTag: eTag)
        let handler = DecodableResponseHandler<InAppMessageLists>()
        
        URLCache.shared.removeAllCachedResponses()
        requestManager.execute(request: request, responseHandler: handler) { result, httpHeaders in
            switch result {
            case .success(let resp):
                let etag: String? = httpHeaders?.value(for: "ETag")?.replacingOccurrences(of: "\"", with: "")
                completionHandler(.success((resp, etag)))
                
            case .failure(let failure):
                completionHandler(.failure(failure))
            }
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func getInAppMessageContent(messageInstanceIds: [Int], completionHandler: @escaping (Result< InAppContents, Error>) -> Void) {
        let request = InAppMessageContentRequest(messageInstanceIds: messageInstanceIds)
        let handler = DecodableResponseHandler<InAppContents>()
        
        requestManager.execute(request: request, responseHandler: handler, completionHandler: completionHandler)
    }
    
    func sendInteraction(
        interaction: NewInteraction,
        completionHandler: @escaping (Result<Bool, Error>) -> Void = { _ in }
    ) {
        let request = NewInAppInteractionRequest(newInteraction: interaction)
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler, completionHandler: completionHandler)
    }
    
    func checkAsyncSegmentRules(ids: [Int], completionHandler: @escaping (Result< InAppAsyncChecks, Error>) -> Void) {
        let request = InAppCheckAsyncRulesRequest(segmentsIds: ids)
        let handler = DecodableResponseHandler<InAppAsyncChecks>()
        
        requestManager.execute(request: request, responseHandler: handler, completionHandler: completionHandler)
    }
}
