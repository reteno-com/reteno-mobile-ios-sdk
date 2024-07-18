//
//  DecodableResponseHandler.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 14.09.2022.
//

import Foundation

let defaultDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(iso8601Formatter)
    return decoder
}()

let iso8601Formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return formatter
}()

struct DecodableResponseHandler<Result: Decodable>: ResponseHandler {
    typealias Value = Result
    
    func handleResponse(_ responseData: Data) throws -> Result {
        try defaultDecoder.decode(Result.self, from: responseData)
    }
}
