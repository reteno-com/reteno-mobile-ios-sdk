//
//  SlideUpTransitioningDelegate.swift
//  Reteno
//
//  Created by George Farafonov on 10.02.2025.
//

import Foundation
import UIKit

final class SlideUpTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var swipeDirection: UISwipeGestureRecognizer.Direction = .down
    private let slidePosition: LayoutPosition
    private let duration: TimeInterval
    
    init(slidePosition: LayoutPosition,
         duration: TimeInterval = 0.3) {
        self.slidePosition = slidePosition
        self.duration = duration
        super.init()
    }
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideUpPresentationAnimator(slidePosition: slidePosition, duration: duration)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideUpDismissalAnimator(swipeDirection: swipeDirection, duration: duration)
    }
}
