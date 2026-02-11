//
//  PushNotificationsSwizzler.swift
//  Reteno
//
//  Created by George Farafonov on 29.12.2025.
//

import Foundation
import UserNotifications
import UIKit
import ObjectiveC.runtime

@available(iOSApplicationExtension, unavailable)
internal class PushNotificationSwizzler: NSObject {
    
    private static var originalDidRegisterImpl: IMP?
    private static var originalDidFailImpl: IMP?
    private static var hasSwizzled = false
    
    private override init() {
        super.init()
    }
    
    public static func swizzle() {
        guard !hasSwizzled else { return }
        guard let delegate = UIApplication.shared.delegate else {
            Logger.log("Reteno: UIApplication.shared.delegate is nil, cannot swizzle", eventType: .error)
            return
        }
        
        hasSwizzled = true
        
        let appDelegateClass: AnyClass = type(of: delegate)
        Logger.log("Reteno: Swizzling Push Notifications for class \(String(describing: appDelegateClass))", eventType: .info)
        
        swizzleDidRegisterForRemoteNotifications(in: appDelegateClass)
        swizzleDidFailToRegisterForRemoteNotifications(in: appDelegateClass)
    }
    
    private static func swizzleDidRegisterForRemoteNotifications(in cls: AnyClass) {
        let originalSelector = #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        let swizzledSelector = #selector(swizzled_didRegisterForRemoteNotifications(_:deviceToken:))
        
        // Check if the app delegate implements the method
        if let originalMethod = class_getInstanceMethod(cls, originalSelector) {
            Logger.log("Reteno: Found original implementation of didRegisterForRemoteNotifications", eventType: .info)
            // App delegate has the method - exchange implementations
            let swizzledMethod = class_getInstanceMethod(PushNotificationSwizzler.self, swizzledSelector)!
            originalDidRegisterImpl = method_getImplementation(originalMethod)
            method_setImplementation(originalMethod, method_getImplementation(swizzledMethod))
            Logger.log("Reteno: Swizzled didRegisterForRemoteNotifications", eventType: .info)
        } else {
            Logger.log("Reteno: Original implementation of didRegisterForRemoteNotifications not found, adding method", eventType: .info)
            // App delegate doesn't implement it - add our method
            let swizzledMethod = class_getInstanceMethod(PushNotificationSwizzler.self, swizzledSelector)!
            let types = method_getTypeEncoding(swizzledMethod)
            class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), types)
            Logger.log("Reteno: Added didRegisterForRemoteNotifications", eventType: .info)
        }
    }
    
    private static func swizzleDidFailToRegisterForRemoteNotifications(in cls: AnyClass) {
        let originalSelector = #selector(UIApplicationDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:))
        let swizzledSelector = #selector(swizzled_didFailToRegister(_:error:))
        
        if let originalMethod = class_getInstanceMethod(cls, originalSelector) {
            Logger.log("Reteno: Found original implementation of didFailToRegisterForRemoteNotifications", eventType: .info)
            let swizzledMethod = class_getInstanceMethod(PushNotificationSwizzler.self, swizzledSelector)!
            originalDidFailImpl = method_getImplementation(originalMethod)
            method_setImplementation(originalMethod, method_getImplementation(swizzledMethod))
            Logger.log("Reteno: Swizzled didFailToRegisterForRemoteNotifications", eventType: .info)
        } else {
            Logger.log("Reteno: Original implementation of didFailToRegisterForRemoteNotifications not found, adding method", eventType: .info)
            let swizzledMethod = class_getInstanceMethod(PushNotificationSwizzler.self, swizzledSelector)!
            let types = method_getTypeEncoding(swizzledMethod)
            class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), types)
            Logger.log("Reteno: Added didFailToRegisterForRemoteNotifications", eventType: .info)
        }
    }
    
    // MARK: - Swizzled Methods
    @objc private func swizzled_didRegisterForRemoteNotifications(
        _ application: UIApplication,
        deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Reteno.userNotificationService.processRemoteNotificationsToken(tokenString)
        
        if let originalImpl = PushNotificationSwizzler.originalDidRegisterImpl {
            typealias OriginalFunction = @convention(c) (AnyObject, Selector, UIApplication, Data) -> Void
            let original = unsafeBitCast(originalImpl, to: OriginalFunction.self)
            original(self, #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:)), application, deviceToken)
        }
    }
    
    @objc private func swizzled_didFailToRegister(
        _ application: UIApplication,
        error: Error
    ) {
        Logger.log("Reteno failed to fetch APNS token: \(error)", eventType: .error)

        if let originalImpl = PushNotificationSwizzler.originalDidFailImpl {
            typealias OriginalFunction = @convention(c) (AnyObject, Selector, UIApplication, Error) -> Void
            let original = unsafeBitCast(originalImpl, to: OriginalFunction.self)
            original(self, #selector(UIApplicationDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:)), application, error)
        }
    }
}


