//
//  SlideUpMessageViewController.swift
//  Reteno
//
//  Created by George Farafonov on 10.02.2025.
//

import Foundation
import UIKit

final class PassthroughView: UIView {
    weak var touchDelegate: UIView? = nil
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }
        
        guard view === self, let point = touchDelegate?.convert(point, from: self) else {
            return view
        }
        
        return touchDelegate?.hitTest(point, with: event)
    }
}

final class SlideUpMessageViewController: InAppMessageWebViewController {
    private let inApp: InApp
    
    init(inApp: InApp, inAppService: InAppService) {
        self.inApp = inApp
        super.init(with: inApp, inAppService: inAppService)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let webViewOffset: CGFloat = 15
    
    override func loadView() {
        self.view = PassthroughView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.view as? PassthroughView)?.touchDelegate = presentingViewController?.view
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.view.frame = CGRect(origin: .zero, size: size)
        }, completion: nil)
    }
    
    func setWebViewLayout(position: LayoutPosition, height: CGFloat) {
        webView.removeFromSuperview()
        webView.removeConstraints(webView.constraints)
        self.view.addSubview(webView)
        switch position {
        case .top:
            webView.layout {
                $0.top.equal(to: view.topAnchor, offsetBy: webViewOffset)
                $0.leading.equal(to: view.leadingAnchor)
                $0.trailing.equal(to: view.trailingAnchor)
                $0.height.equal(to: height)
            }
        case .bottom:
            webView.layout {
                $0.bottom.equal(to: view.safeAreaLayoutGuide.bottomAnchor, offsetBy: webViewOffset)
                $0.leading.equal(to: view.leadingAnchor)
                $0.trailing.equal(to: view.trailingAnchor)
                $0.height.equal(to: height)
            }
        }
        self.view.layoutIfNeeded()
    }
    
    func setupBottomBar(height: CGFloat) {
        webView.removeFromSuperview()
        webView.removeConstraints(webView.constraints)
        self.view.addSubview(webView)
        webView.layout {
            $0.bottom.equal(to: view.safeAreaLayoutGuide.bottomAnchor, offsetBy: webViewOffset)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.height.equal(to: height + webViewOffset)
        }
        self.view.layoutIfNeeded()
        
        let swipeRecognizer: UISwipeGestureRecognizer = .init(target: self, action: #selector(handleSwipeGesture))
        swipeRecognizer.direction = .down
        addGestureRecognizer(swipeRecognizer)
    }
    
    private func setupGestureRecognizers() {
        let leftSwipeRecognizer: UISwipeGestureRecognizer = .init(target: self, action: #selector(handleSwipeGesture))
        leftSwipeRecognizer.direction = .left
        addGestureRecognizer(leftSwipeRecognizer)
        
        let rightSwipeRecognizer: UISwipeGestureRecognizer = .init(target: self, action: #selector(handleSwipeGesture))
        rightSwipeRecognizer.direction = .right
        addGestureRecognizer(rightSwipeRecognizer)
        if inApp.layoutType == .slideUp {
            switch inApp.layoutParams?.position {
            case .top:
                let topSwipeRecognizer: UISwipeGestureRecognizer = .init(target: self, action: #selector(handleSwipeGesture))
                topSwipeRecognizer.direction = .up
                addGestureRecognizer(topSwipeRecognizer)
            case .bottom:
                let bottomSwipeRecognizer: UISwipeGestureRecognizer = .init(target: self, action: #selector(handleSwipeGesture))
                bottomSwipeRecognizer.direction = .down
                addGestureRecognizer(bottomSwipeRecognizer)
            default: break
            }
        } else {
            let bottomSwipeRecognizer: UISwipeGestureRecognizer = .init(target: self, action: #selector(handleSwipeGesture))
            bottomSwipeRecognizer.direction = .down
            addGestureRecognizer(bottomSwipeRecognizer)
        }
    }
    
    @objc
    private func handleSwipeGesture(_ gr: UISwipeGestureRecognizer) {
        delegate?.inAppMessageWebViewController(self, didReceive: InAppScriptMessage(type: .close, payload: DismissSlideUpPayload(swipeDirection: gr.direction)), in: inApp)
    }
}
