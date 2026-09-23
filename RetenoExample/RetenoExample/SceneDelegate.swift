//
//  SceneDelegate.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 14.09.2022.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private var appDelegate: AppDelegate? {
        UIApplication.shared.delegate as? AppDelegate
    }
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        appDelegate?.configureMainWindow(window)
        
        if let url = connectionOptions.urlContexts.first?.url {
            appDelegate?.handleOpenURL(url)
        }
        
        if let userActivity = connectionOptions.userActivities.first {
            appDelegate?.handleUserActivity(userActivity)
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        URLContexts.forEach { appDelegate?.handleOpenURL($0.url) }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        appDelegate?.handleUserActivity(userActivity)
    }
    
}
