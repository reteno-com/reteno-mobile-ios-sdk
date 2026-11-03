//
//  MobileRequestService.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 29.09.2022.
//

import Foundation

final class MobileRequestService {
    
    private let requestManager: RequestManager
    private let identity: () -> RequestIdentity
    private let workflowContext: () -> WorkflowContext.Snapshot
    private let registrationStorage: KeyValueStorage
    
    init(
        requestManager: RequestManager = NetworkBuilder.buildMobileApiManager(),
        identity: @escaping () -> RequestIdentity = { .current },
        workflowContext: @escaping () -> WorkflowContext.Snapshot = WorkflowContext.capture,
        registrationStorage: KeyValueStorage = StorageBuilder.build()
    ) {
        self.requestManager = requestManager
        self.identity = identity
        self.workflowContext = workflowContext
        self.registrationStorage = registrationStorage
    }
    
    /// `self` while `identity` is still the current one, otherwise a mobile API service pinned to `identity`,
    /// so data captured before a multi-account switch is not sent with the next account's device id.
    func pinned(to identity: RequestIdentity?) -> MobileRequestService {
        guard let identity, !identity.isCurrent else { return self }
        
        return MobileRequestServiceBuilder.build(identity: identity)
    }
    
    func upsertDevice(
        externalUserId: String? = nil,
        email: String?,
        phone: String?,
        isSubscribedOnPush: Bool,
        completionHandler: @escaping (Result<Bool, Error>) -> Void = { _ in }
    ) {
        let languageCode = Bundle.main.preferredLocalizations.first ?? "en"
        let pushToken = RetenoNotificationsHelper.deviceToken() ?? ""
        let category = try? DeviceCategoryHelper.deviceType()
        let capturedHeaders = workflowContext().headers
        let registration = WorkflowContext.Snapshot(
            apiKey: capturedHeaders["X-Reteno-Access-Key"] ?? "",
            identity: RequestIdentity(deviceId: identity().deviceId, externalUserId: externalUserId),
            email: email, phone: phone)
        var request = DeviceRequest(
            category: category ?? .mobile,
            languageCode: languageCode,
            pushToken: pushToken,
            isSubscribedOnPush: isSubscribedOnPush,
            externalUserId: externalUserId,
            email: email,
            phone: phone
        )
        request.headers = registration.headers
        request.parameters?["deviceId"] = registration.headers["X-Reteno-Device-ID"]
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler) { result in
            if case .success = result, registration.id == self.workflowContext().id,
               self.registrationStorage.confirmWorkflowRegistration(context: registration.id) {
                NotificationCenter.default.post(name: Reteno.inAppDeviceRegistrationConfirmed, object: nil,
                                                userInfo: ["context": registration.id])
            }
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
            else { return identity().externalUserId ?? "" }
            
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
            deviceId: identity().deviceId,
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
        status: AppInboxMessagesStatus?,
        completion: @escaping (Result<AppInboxMessagesResponse, Error>) -> Void
    ) {
        let request = AppInboxMessagesRequest(
            page: page,
            pageSize: pageSize,
            status: status
        )
        
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
        
    func getRecomJSONs(
        recomVariantId: String,
        productIds: [String],
        categoryId: String?,
        filters: [RecomFilter]?,
        fields: [String]?,
        completionHandler: @escaping (Result<[[String: Any]], Error>) -> Void
    ) {
        let request = RecomsRequest(
            recomVariantId: recomVariantId,
            productIds: productIds,
            categoryId: categoryId,
            filters: filters,
            fields: fields
        )
        let handler = DictionaryResponseHandler()

        requestManager.execute(request: request, responseHandler: handler, completionHandler: { result in
            switch result {
            case .success(let dict):
                let recoms: [[String: Any]]? = dict["recoms"] as? [[String: Any]]
                completionHandler(.success(recoms ?? []))
                
            case .failure(let error):
                completionHandler(.failure(error))
            }
        })
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
    
    func getInAppMessages(eTag: String?, includeWorkflow: Bool = false, completionHandler: @escaping (Result<(list: InAppMessageLists, etag: String?), Error>) -> Void) {
        let request = InAppMessagesRequest(eTag: eTag, includeWorkflow: includeWorkflow)
        let handler = DecodableResponseHandler<InAppMessageLists>()
        
        URLCache.shared.removeAllCachedResponses()
        requestManager.execute(request: request, responseHandler: handler) { result, dataResponse in
            switch result {
            case .success(let resp):
                let etag: String? = dataResponse?.headers.getHeaderValue(for: "ETag")?.replacingOccurrences(of: "\"", with: "")
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
    
    func getWorkflowContent(messages: [Message], completionHandler: @escaping (Result<InAppContents, Error>) -> Void) {
        let request = InAppMessageContentRequest(messages: messages)
        requestManager.execute(request: request, responseHandler: DecodableResponseHandler<InAppContents>(),
                               completionHandler: completionHandler)
    }

    func sendWorkflowInteraction(_ queued: QueuedInAppInteraction,
                                 completion: @escaping (Result<Bool, Error>, ResponseData?) -> Void) {
        let capturedContext = workflowContext()
        guard queued.context == capturedContext.id else {
            completion(.failure(APIClientError.wrongResponse), nil)
            return
        }
        requestManager.execute(request: NewInAppInteractionRequest(workflowInteraction: queued.interaction, headers: capturedContext.headers),
                               responseHandler: EmptyResponseHandler(), completionHandler: completion)
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
