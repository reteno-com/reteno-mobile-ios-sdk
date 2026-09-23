//
//  RegisterLinkClickOperation.swift
//  Reteno
//
//  Created by Anna Sahaidak on 07.02.2023.
//

import Foundation

final class RegisterLinkClickOperation: DateOperation, @unchecked Sendable {
    
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
        
        guard !isCancelled, storage.getLinks().contains(link) else {
            finish()
            
            return
        }
        
        requestService.registerLinkClick(link.value) { result in
            switch result {
            case .success:
                self.storage.clearLinks([self.link])
                
            case .failure(let error):
                if let responseCode = (error as? APIStatusError)?.statusCode {
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
