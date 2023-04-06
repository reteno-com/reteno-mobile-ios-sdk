import Foundation

struct JSONCodingKeys: CodingKey {
    
    var stringValue: String
    var intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
    
}

extension KeyedDecodingContainer {
    
    func decode(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any] {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        
        return try container.decode(type)
    }
    
    func decode(_ type: [Any].Type, forKey key: K) throws -> [Any] {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        
        return try container.decode(type)
    }
    
    func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        var dictionary = [String: Any]()
        
        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode([String: Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode([Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        
        return dictionary
    }
    
}

extension UnkeyedDecodingContainer {
    
    mutating func decode(_ type: [Any].Type) throws -> [Any] {
        var array: [Any] = []
        
        while isAtEnd == false {
            if try decodeNil() {
                continue
            }
            
            if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Int.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode([String: Any].self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode([Any].self) {
                array.append(nestedArray)
            }
        }
        return array
    }
    
    mutating func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        
        return try nestedContainer.decode(type)
    }
    
}

extension KeyedEncodingContainerProtocol where Key == JSONCodingKeys {
    
    mutating func encode(_ value: [String: Any]) throws {
        try value.forEach { key, value in
            let key = JSONCodingKeys(stringValue: key)
            switch value {
            case let value as Int:
                try encode(value, forKey: key)
            case let value as Bool:
                try encode(value, forKey: key)
            case let value as String:
                try encode(value, forKey: key)
            case let value as Double:
                try encode(value, forKey: key)
            case let value as [String: Any]:
                try encode(value, forKey: key)
            case let value as [Any]:
                try encode(value, forKey: key)
            case _ as NSNull:
                try encodeNil(forKey: key)
            default:
                throw EncodingError.invalidValue(
                    value,
                    EncodingError.Context(
                        codingPath: codingPath + [key],
                        debugDescription: "Invalid JSON value"
                    )
                )
            }
        }
    }
    
}

extension KeyedEncodingContainerProtocol {
    
    mutating func encode(_ value: [String: Any]?, forKey key: Key) throws {
        guard let value = value else { return }
        
        var container = self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        try container.encode(value)
    }
    
    mutating func encode(_ value: [Any]?, forKey key: Key) throws {
        guard let value = value else { return }
        
        var container = self.nestedUnkeyedContainer(forKey: key)
        try container.encode(value)
    }
    
}

extension UnkeyedEncodingContainer {
    
    mutating func encode(_ value: [Any]) throws {
        try value.enumerated().forEach { index, value in
            switch value {
            case let value as Bool:
                try encode(value)
            case let value as Int:
                try encode(value)
            case let value as Bool:
                try encode(value)
            case let value as String:
                try encode(value)
            case let value as Double:
                try encode(value)
            case let value as [String: Any]:
                try encode(value)
            case let value as [Any]:
                try encode(value)
            case _ as NSNull:
                try encodeNil()
            default:
                let keys = JSONCodingKeys(intValue: index).map { [$0] } ?? []
                throw EncodingError.invalidValue(
                    value,
                    EncodingError.Context(
                        codingPath: codingPath + keys,
                        debugDescription: "Invalid JSON value"
                    )
                )
            }
        }
    }
    
    mutating func encode(_ value: [String: Any]) throws {
        var nestedContainer = self.nestedContainer(keyedBy: JSONCodingKeys.self)
        try nestedContainer.encode(value)
    }
    
}
