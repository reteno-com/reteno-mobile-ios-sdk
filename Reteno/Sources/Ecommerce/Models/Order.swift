//
//  Order.swift
//  
//
//  Created by Anna Sahaidak on 30.11.2022.
//

import Foundation

extension Ecommerce {
    
    public struct Order {
        
        public struct Item {
            
            let externalItemId: String
            let name: String
            let category: String
            let quantity: Double
            let cost: Float
            let url: String
            let imageUrl: String?
            let description: String?
            
            public init(
                externalItemId: String,
                name: String,
                category: String,
                quantity: Double,
                cost: Float,
                url: String,
                imageUrl: String?,
                description: String?
            ) {
                self.externalItemId = externalItemId
                self.name = name
                self.category = category
                self.quantity = quantity
                self.cost = cost
                self.url = url
                self.imageUrl = imageUrl
                self.description = description
            }
            
            func toJSON() -> [String: Any] {
                var json: [String: Any] = [
                    "externalItemId": externalItemId,
                    "name": name,
                    "category": category,
                    "quantity": quantity,
                    "cost": cost,
                    "url": url
                ]
                if let imageUrl = imageUrl {
                    json["imageUrl"] = imageUrl
                }
                if let description = description {
                    json["description"] = description
                }
                
                return json
            }
            
        }
        
        public enum Status: String {
            case INITIALIZED, IN_PROGRESS, DELIVERED, CANCELLED
        }
        
        let externalOrderId: String
        let totalCost: Float
        let status: Status
        let date: Date
        let cartId: String?
        let email: String?
        let phone: String?
        let firstName: String?
        let lastName: String?
        let shipping: Float?
        let discount: Float?
        let taxes: Float?
        let restoreUrl: String?
        let statusDescription: String?
        let storeId: String?
        let source: String?
        let deliveryMethod: String?
        let paymentMethod: String?
        let deliveryAddress: String?
        let items: [Item]?
        let attributes: [String: [String: Any]]?
        
        public init(
            externalOrderId: String, totalCost: Float, status: Status,
            date: Date, cartId: String? = nil, email: String? = nil, phone: String? = nil,
            firstName: String? = nil, lastName: String? = nil, shipping: Float? = nil,
            discount: Float? = nil, taxes: Float? = nil, restoreUrl: String? = nil,
            statusDescription: String? = nil, storeId: String? = nil, source: String? = nil,
            deliveryMethod: String? = nil, paymentMethod: String? = nil,
            deliveryAddress: String? = nil, items: [Item]? = nil, attributes: [String: [String: Any]]? = nil
        ) {
            self.externalOrderId = externalOrderId
            self.totalCost = totalCost
            self.status = status
            self.date = date
            self.cartId = cartId
            self.email = email
            self.phone = phone
            self.firstName = firstName
            self.lastName = lastName
            self.shipping = shipping
            self.discount = discount
            self.taxes = taxes
            self.restoreUrl = restoreUrl
            self.statusDescription = statusDescription
            self.storeId = storeId
            self.source = source
            self.deliveryMethod = deliveryMethod
            self.paymentMethod = paymentMethod
            self.deliveryAddress = deliveryAddress
            self.items = items
            self.attributes = attributes
        }
        
        func eventParameters() -> [Event.Parameter] {
            var parameters: [Event.Parameter] = [
                .init(name: "externalOrderId", value: externalOrderId),
                .init(name: "totalCost", value: "\(totalCost)"),
                .init(name: "status", value: status.rawValue),
                .init(name: "date", value: DateFormatter.baseBEDateFormatter.string(from: date))
            ]
            if let cartId = cartId {
                parameters.append(.init(name: "cartId", value: cartId))
            }
            if let email = email {
                parameters.append(.init(name: "email", value: email))
            }
            if let phone = phone {
                parameters.append(.init(name: "phone", value: phone))
            }
            if let firstName = firstName {
                parameters.append(.init(name: "firstName", value: firstName))
            }
            if let lastName = lastName {
                parameters.append(.init(name: "lastName", value: lastName))
            }
            if let shipping = shipping {
                parameters.append(.init(name: "shipping", value: "\(shipping)"))
            }
            if let discount = discount {
                parameters.append(.init(name: "discount", value: "\(discount)"))
            }
            if let taxes = taxes {
                parameters.append(.init(name: "taxes", value: "\(taxes)"))
            }
            if let restoreUrl = restoreUrl {
                parameters.append(.init(name: "restoreUrl", value: restoreUrl))
            }
            if let statusDescription = statusDescription {
                parameters.append(.init(name: "statusDescription", value: statusDescription))
            }
            if let storeId = storeId {
                parameters.append(.init(name: "storeId", value: storeId))
            }
            if let source = source {
                parameters.append(.init(name: "source", value: source))
            }
            if let deliveryMethod = deliveryMethod {
                parameters.append(.init(name: "deliveryMethod", value: deliveryMethod))
            }
            if let paymentMethod = paymentMethod {
                parameters.append(.init(name: "paymentMethod", value: paymentMethod))
            }
            if let deliveryAddress = deliveryAddress {
                parameters.append(.init(name: "deliveryAddress", value: deliveryAddress))
            }
            if let items = items,
               items.isNotEmpty,
               let escapedItems = JSONConverterHelper.convertJSONToString(items.map { $0.toJSON() }) {
                parameters.append(.init(name: "items", value: escapedItems))
            }
            if let attributes = attributes, !attributes.isEmpty {
                attributes.keys.forEach {
                    if let json = attributes[$0], let escapedJSON = JSONConverterHelper.convertJSONToString(json) {
                        parameters.append(.init(name: $0, value: escapedJSON))
                    }
                }
            }
            
            return parameters
        }
        
    }
    
}
