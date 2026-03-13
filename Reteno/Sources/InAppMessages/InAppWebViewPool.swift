//
//  InAppWebViewPool.swift
//  Reteno
//

import WebKit

final class InAppWebViewPool {
    
    static let shared = InAppWebViewPool()
    
    let processPool = WKProcessPool()
    
    private var warmedWebView: WKWebView?
    private var isWarmed = false
    
    private init() {}
    
    func warmUp() {
        guard !isWarmed else { return }
        isWarmed = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self, self.warmedWebView == nil else { return }
            let webView = self.makeWebView()
            webView.loadHTMLString("<html></html>", baseURL: nil)
            self.warmedWebView = webView
        }
    }
    
    func dequeueWebView() -> WKWebView {
        if let warmed = warmedWebView {
            warmedWebView = nil
            warmed.stopLoading()
            if #available(iOS 14.0, *) {
                warmed.configuration.userContentController.removeAllScriptMessageHandlers()
            } else {
            }
            return warmed
        }
        return makeWebView()
    }
    
    func makeConfiguration() -> WKWebViewConfiguration {
        let preferences = WKPreferences()
        let configuration = WKWebViewConfiguration()
        configuration.processPool = processPool
        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            preferences.javaScriptEnabled = true
        }
        configuration.preferences = preferences
        return configuration
    }
    
    private func makeWebView() -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: makeConfiguration())
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.isOpaque = false
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        return webView
    }
}
