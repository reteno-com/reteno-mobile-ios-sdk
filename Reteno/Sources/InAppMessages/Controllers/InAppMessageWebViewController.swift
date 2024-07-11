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

final class InAppMessageWebViewController: UIViewController {
    weak var delegate: InAppScriptMessageHandler?
    
    private let message: InApp
    private let webView: WKWebView
    private let inAppService: InAppService
    
    // MARK: Init
    
    init(with message: InApp, inAppService: InAppService) {
        self.message = message
        self.inAppService = inAppService
        
        let preferences = WKPreferences()
        let configuration = WKWebViewConfiguration()
        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            preferences.javaScriptEnabled = true
        }
        configuration.preferences = preferences

        webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("index.html")
            let htmlContent = try String(contentsOf: url, encoding: .utf8)
            let htmlString = htmlContent
                .replacingOccurrences(of: "${documentModel}", with: message.model)
                .replacingOccurrences(of: "${personalisation}", with: message.personalisation ?? "{}")
            webView.layout(in: view)
            webView.scrollView.bounces = false
            webView.navigationDelegate = self
            webView.configuration.userContentController.add(self, name: "retenoHandler")
            webView.loadHTMLString(htmlString, baseURL: nil)
        } catch {
            ErrorLogger.shared.capture(error: error)
            Logger.log(error.localizedDescription, eventType: .error)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        webView.stopLoading()
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "retenoHandler")
    }

}

extension InAppMessageWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Logger.log("Load finished", eventType: .info)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Logger.log(error.localizedDescription, eventType: .error)
        ErrorLogger.shared.capture(error: error)
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
            Logger.log("Received message\nname: \(message.name);\nbody: \(message.body)", eventType: .debug)
            ErrorLogger.shared.captureWarningEvent(
                message: "Couldn't parse script message [\(message.body)]",
                tags: ["reteno.in_app_message_id": self.message.id]
            )
            self.inAppService.sendInteraction(
                with: self.message,
                status: .failed,
                description: "Couldn't parse script message [\(message.body)]"
            )
            
            return
        }
        
        do {
            let scriptMessage = try JSONDecoder().decode(InAppScriptMessage.self, from: bodyData)
            
            delegate?.inAppMessageWebViewController(self, didReceive: scriptMessage, in: self.message)
            Logger.log("Received message: \(scriptMessage)", eventType: .debug)
        } catch {
            Logger.log(error, eventType: .error)
            ErrorLogger.shared.capture(error: error)
            self.inAppService.sendInteraction(
                with: self.message,
                status: .failed,
                description: error.localizedDescription
            )
        }
    }
    
}
