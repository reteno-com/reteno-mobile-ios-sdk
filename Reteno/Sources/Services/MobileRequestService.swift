//
//  MobileRequestService.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 29.09.2022.
//

import Alamofire

final class MobileRequestService {
    
    private let requestManager: RequestManager
    
    init(requestManager: RequestManager = NetworkBuilder.buildMobileApiManager()) {
        self.requestManager = requestManager
    }
    
    func upsertDevice(completionHandler: @escaping (Result<Bool, Error>) -> Void = { _ in }) {
        let languageCode = Locale.current.languageCode
        let pushToken = RetenoNotificationsHelper.deviceToken() ?? ""
        let request = DeviceRequest(languageCode: languageCode, pushToken: pushToken)
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

extension MobileRequestService: EventsSender {
    
    func sendScreenViewEvent(
        eventTypeKey: String,
        date: Date,
        params: [Event.Parameter],
        completionHandler: @escaping (Result<Void, Error>) -> Void = { _ in }
    ) {
        let request = EventRequest(events: [Event(eventTypeKey: eventTypeKey, date: date, parameters: params)])
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
