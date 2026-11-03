//
//  InAppMessageWebViewController.swift
//  
//
//  Created by Anna Sahaidak on 18.01.2023.
//

import UIKit
import WebKit

protocol InAppScriptMessageHandler: AnyObject {
    
    func inAppMessageWebViewController(
        _ viewController: InAppMessageWebViewController,
        didReceive scriptMessage: InAppScriptMessage,
        in message: InApp
    )
    
}

class InAppMessageWebViewController: UIViewController {
    weak var delegate: InAppScriptMessageHandler?
    
    private let message: InApp
    let webView: WKWebView
    private let inAppService: InAppService
    private var presentationStarted = false

    func beginPresentation() -> Bool {
        guard !presentationStarted else { return false }
        presentationStarted = true
        return true
    }
    
    // MARK: Init
    
    init(with message: InApp, inAppService: InAppService) {
        self.message = message
        self.inAppService = inAppService
        self.webView = InAppWebViewPool.shared.dequeueWebView()
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        guard let htmlContent = FileStorage.shared.getBaseHtmlContent() else {
            reportLoadingFailure("Base HTML unavailable")
            return
        }
        
        let htmlString = InAppPersonalisation().prepareHTML(htmlContent, for: message)
        
        webView.layout(in: view)
        webView.scrollView.bounces = false
        webView.navigationDelegate = self
        webView.configuration.userContentController.add(self, name: "retenoHandler")
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopRendering()
    }

    func stopRendering() {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "retenoHandler")
        webView.navigationDelegate = nil
        webView.stopLoading()
    }

    private func reportLoadingFailure(_ reason: String) {
        delegate?.inAppMessageWebViewController(self, didReceive: .init(type: .failedLoading,
            payload: InAppScriptMessageErrorPayload(reason: reason)), in: message)
    }

    func disableScrolling() {
        webView.scrollView.isScrollEnabled = false
        webView.allowsBackForwardNavigationGestures = false
    }
    
    func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        webView.addGestureRecognizer(gestureRecognizer)
    }
}

extension InAppMessageWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated,
           let url = navigationAction.request.url {
            let payload = InAppScriptMessageURLPayload(url: url.absoluteString)
            let scriptMessage = InAppScriptMessage(type: .openURL, payload: payload)
            delegate?.inAppMessageWebViewController(self, didReceive: scriptMessage, in: message)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Logger.log("Load finished", eventType: .info)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        reportLoadingFailure("Web view navigation failed")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        reportLoadingFailure("Web view navigation failed")
    }
    
}

// MARK: WKScriptMessageHandler

extension InAppMessageWebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard
            message.name == "retenoHandler",
            let body = message.body as? String,
            let bodyData = body.data(using: .utf8)
        else {
            reportLoadingFailure("In-app script message could not be decoded")

            return
        }
        
        do {
            let scriptMessage = try JSONDecoder().decode(InAppScriptMessage.self, from: bodyData)
            
            delegate?.inAppMessageWebViewController(self, didReceive: scriptMessage, in: self.message)
            Logger.log("Received in-app script message: \(scriptMessage.type.rawValue)", eventType: .debug)
        } catch {
            reportLoadingFailure("In-app script message could not be decoded")
        }
    }

}
