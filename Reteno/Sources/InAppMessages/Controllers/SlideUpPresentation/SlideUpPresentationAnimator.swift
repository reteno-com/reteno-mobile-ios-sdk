//
//  SlideUpTransitionAnimator.swift
//  Reteno
//
//  Created by George Farafonov on 10.02.2025.
//

import Foundation
import UIKit

final class SlideUpPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let slidePosition: LayoutPosition
    private let duration: TimeInterval
    
    init(slidePosition: LayoutPosition, duration: TimeInterval = 0.3) {
        self.slidePosition = slidePosition
        self.duration = duration
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        let key: UITransitionContextViewControllerKey = .to
        guard let animatingVC = transitionContext.viewController(forKey: key) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let animatingView = animatingVC.view!
        containerView.addSubview(animatingView)
        
        
        let finalFrame = transitionContext.finalFrame(for: animatingVC)
        
        var offScreenFrame = finalFrame
        
        switch slidePosition {
        case .top:
            offScreenFrame.origin.y = -finalFrame.height
        case .bottom:
            offScreenFrame.origin.y = containerView.bounds.height
        }
        
        let initialFrame = offScreenFrame
        let targetFrame  = finalFrame
        animatingView.frame = initialFrame
        
        UIView.animate(withDuration: duration, animations: {
            animatingView.frame = targetFrame
        }) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
