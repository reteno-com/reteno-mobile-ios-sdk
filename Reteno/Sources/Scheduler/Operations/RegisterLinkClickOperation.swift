//
//  RegisterLinkClickOperation.swift
//  Reteno
//
//  Created by Anna Sahaidak on 07.02.2023.
//

import Foundation
import Alamofire

final class RegisterLinkClickOperation: DateOperation {
    
    private var link: StorableLink
    private let storage: KeyValueStorage
    private let requestService: SendingServices
    
    init(requestService: SendingServices, storage: KeyValueStorage, link: StorableLink) {
        self.requestService = requestService
        self.storage = storage
        self.link = link
        
        super.init(date: link.date)
    }
    
    override func main() {
        super.main()
        
        guard !isCancelled else {
            finish()
            
            return
        }
        
        requestService.registerLinkClick(link.value) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.storage.clearLinks([self.link])
                
            case .failure(let error):
                if let responseCode = (error as? NetworkError)?.statusCode ?? (error as? AFError)?.responseCode {
                    switch responseCode {
                    case 400...499:
                        self.storage.clearLinks([self.link])
                        
                    default:
                        break
                    }
                }
            }
            self.finish()
        }
    }

}
