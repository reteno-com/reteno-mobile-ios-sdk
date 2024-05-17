//
//  AppLifecycleAnalyticsSevice.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 24.04.2024.
//

import Foundation
import UIKit

final class AppLifecycleAnalyticsSevice {
    private let storage = StorageBuilder.build()

    var isLaunchedFromForeground: Bool = false
    var applicationOpenTime: Date?
    
    // MARK: Subscribe on notifications
    
    func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationDidFinishLaunchingNotification),
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationWillEnterForegroundNotification),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationDidBecomeActiveNotification),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationDidEnterBackgroundNotification(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    // MARK: Application instal/update event

    private func handleInstallUpdateEvent() {
        guard let version: String = storage.getValue(forKey: StorageKeys.previousVersion.rawValue),
           let build: String = storage.getValue(forKey: StorageKeys.previousBuild.rawValue) else {
            handleInstallEvent()
            return
        } 
        
        handleUpdateEvent(previousVersion: version, previousBuild: build)
    }
     
    private func handleInstallEvent() {
        storage.set(value: AppVersionHelper.appVersion() ?? "", forKey: StorageKeys.previousVersion.rawValue)
        storage.set(value: AppVersionHelper.appBuild() ?? "", forKey: StorageKeys.previousBuild.rawValue)
        Reteno.logEvent(
            eventTypeKey: AppLifecycleEventKeys.applicationInstalled.rawValue,
            parameters: [
                .init(name: AppLifecycleEventKeys.versionKey.rawValue, value: AppVersionHelper.appVersion() ?? ""),
                .init(name: AppLifecycleEventKeys.buildKey.rawValue, value: AppVersionHelper.appBuild() ?? "")
            ]
        )
    }
    
    private func handleUpdateEvent(previousVersion: String, previousBuild: String) {
        guard AppVersionHelper.appVersion() != previousVersion || AppVersionHelper.appBuild() != previousBuild else {
            return
        }

        storage.set(value: AppVersionHelper.appVersion() ?? "", forKey: StorageKeys.previousVersion.rawValue)
        storage.set(value: AppVersionHelper.appBuild() ?? "", forKey: StorageKeys.previousBuild.rawValue)
        Reteno.logEvent(
            eventTypeKey: AppLifecycleEventKeys.applicationUpdated.rawValue,
            parameters: [
                .init(name: AppLifecycleEventKeys.versionKey.rawValue, value: AppVersionHelper.appVersion() ?? ""),
                .init(name: AppLifecycleEventKeys.buildKey.rawValue, value: AppVersionHelper.appBuild() ?? ""),
                .init(name: AppLifecycleEventKeys.previousVersionKey.rawValue, value: previousVersion),
                .init(name: AppLifecycleEventKeys.previousBuildKey.rawValue, value: previousBuild)
            ]
        )
    }
    
    // MARK: Handle notifications
    
    @objc
    private func handleApplicationDidFinishLaunchingNotification(_ notification: Notification) {
        handleInstallUpdateEvent()
    }
    
    @objc
    private func handleApplicationWillEnterForegroundNotification(_ notification: Notification) {
        isLaunchedFromForeground = true
    }
    
    @objc
    private func handleApplicationDidBecomeActiveNotification(_ notification: Notification) {
        applicationOpenTime = Date()
        Reteno.logEvent(
            eventTypeKey: AppLifecycleEventKeys.applicationOpenedKey.rawValue,
            parameters: [
                .init(name: AppLifecycleEventKeys.fromBackgroundKey.rawValue, value: "\(!self.isLaunchedFromForeground)")
            ]
        )
    }

    @objc
    private func handleApplicationDidEnterBackgroundNotification(_ notification: Notification) {
        guard let applicationOpenTime = applicationOpenTime else {
            return
        }
        
        let openedTime = DateFormatter.baseBEDateFormatter.string(from: applicationOpenTime)
        let secondInForeground = Date().timeIntervalSince1970 - applicationOpenTime.timeIntervalSince1970
        
        Reteno.logEvent(
            eventTypeKey: AppLifecycleEventKeys.applicationBackgroundedKey.rawValue,
            parameters: [
                .init(name: AppLifecycleEventKeys.applicationOpenedTimeKey.rawValue, value: openedTime),
                .init(name: AppLifecycleEventKeys.secondsInForegroundKey.rawValue, value: String(secondInForeground))
            ]
        )
    }
}

fileprivate enum AppLifecycleEventKeys: String {
    /// Events Name
    case applicationInstalled = "ApplicationInstalled"
    case applicationOpenedKey = "ApplicationOpened"
    case applicationBackgroundedKey = "ApplicationBackgrounded"
    case applicationUpdated = "ApplicationUpdated"
    /// Event Params Name
    case versionKey = "version"
    case buildKey = "build"
    case previousVersionKey = "previousVersion"
    case previousBuildKey = "previousBuild"
    case fromBackgroundKey = "fromBackground"
    case applicationOpenedTimeKey = "applicationOpenedTime"
    case secondsInForegroundKey = "secondsInForeground"
}
