//
//  SlideUpDismissalAnimator.swift
//  Reteno
//
//  Created by George Farafonov on 28.02.2025.
//

import UIKit

final class SlideUpDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval
    private let swipeDirection: UISwipeGestureRecognizer.Direction
    
    init(swipeDirection: UISwipeGestureRecognizer.Direction, duration: TimeInterval = 0.3) {
        self.duration = duration
        self.swipeDirection = swipeDirection
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from) else { return }
        let container = transitionContext.containerView
        
        container.addSubview(fromVC.view)
        
        let finalFrame: CGRect
        switch swipeDirection {
        case .left:
            finalFrame = fromVC.view.frame.offsetBy(dx: -fromVC.view.frame.width, dy: 0)
        case .right:
            finalFrame = fromVC.view.frame.offsetBy(dx: fromVC.view.frame.width, dy: 0)
        case .down:
            finalFrame = fromVC.view.frame.offsetBy(dx: 0, dy: fromVC.view.frame.height)
        default:
            transitionContext.completeTransition(true)
            return
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromVC.view.frame = finalFrame
        }) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

