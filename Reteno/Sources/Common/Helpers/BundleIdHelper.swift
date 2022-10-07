//
//  BundleIdHelper.swift
//  Pods
//
//  Created by Serhii Prykhodko on 22.09.2022.
//

import Foundation

struct BundleIdHelper {
    
    private init() {}
    
    static func getMainAppBundleId(bundle: Bundle = Bundle.main) -> String {
        var bundleURL = bundle.bundleURL
        
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
