//
//  BundleIdHelper.swift
//  Pods
//
//  Created by Serhii Prykhodko on 22.09.2022.
//

import Foundation

struct BundleIdHelper {
    
    static func getMainAppBundleId() -> String {
        var bundleURL = Bundle.main.bundleURL
        
        if bundleURL.pathExtension == "appex" {
            findAppPath(for: &bundleURL)
        }
        
        return Bundle(url: bundleURL)?.bundleIdentifier ?? ""
    }
    
    static func findAppPath(for url: inout URL) {
        guard url.pathExtension != "app" else { return }
        
        url = url.deletingLastPathComponent()
        findAppPath(for: &url)
    }
    
}
