//
//  TFBackwardAnimator.swift
//  TFTransparentNavigationBar
//
//  Created by Ales Kocur on 10/03/2015.
//  Copyright (c) 2015 Ales Kocur. All rights reserved.
//

import UIKit

class TFBackwardAnimator: TFNavigationBarAnimator, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using context: UIViewControllerContextTransitioning) {
        
        let containerView = context.containerView
        let toView = context.view(forKey: UITransitionContextViewKey.to)!
        let fromView = context.view(forKey: UITransitionContextViewKey.from)!
        let options: UIViewAnimationOptions = isInteractive ? [.curveLinear] : [.curveEaseOut]
        let duration = self.transitionDuration(using: context)
        
        // Insert toView below from view
        containerView.insertSubview(toView, belowSubview: fromView)
        
        switch navigationBarStyleTransition {
        case .toTransparent, .toSolid:
             animateTransition(containerView: containerView, fromView: fromView, toView: toView, duration: duration, options: options, context: context)
            
        case .toSame:
            animateToSame(containerView: containerView, fromView: fromView, toView: toView, duration: duration, options: options, context: context)
        }
    }
    
    func animateToSame(containerView: UIView, fromView: UIView, toView: UIView, duration: TimeInterval, options: UIViewAnimationOptions, context: UIViewControllerContextTransitioning) {
        
        let fromViewController = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let toViewFinalFrame = context.finalFrame(for: toViewController)
        
        // Shift to the left
        toView.frame = toViewFinalFrame.offsetBy(dx: -(toViewFinalFrame.width * 0.3), dy: 0)
        
        let fromViewFinalFrame: CGRect = {
            let initialFrame = context.initialFrame(for: fromViewController)
            return initialFrame.offsetBy(dx: initialFrame.width, dy: 0)
        }()
        
        addShadows(toViews: [fromView])
        
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: { () -> Void in
            
            toView.frame = toViewFinalFrame
            fromView.frame = fromViewFinalFrame
            
            }, completion: { (completed) -> Void in
                
                // Inform about transaction completion state
                context.completeTransition(!context.transitionWasCancelled)
        })
    }
    
    func animateTransition(containerView: UIView, fromView: UIView, toView: UIView, duration: TimeInterval, options: UIViewAnimationOptions, context: UIViewControllerContextTransitioning) {
        
        let containerView = context.containerView
        let fromViewController = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let toView = context.view(forKey: UITransitionContextViewKey.to)!
        let fromView = context.view(forKey: UITransitionContextViewKey.from)!
        let duration = self.transitionDuration(using: context)

        var fromFrame = context.initialFrame(for: fromViewController)
        
        var toViewControllerNavigationBarSnapshot: UIView?
        if let index = navigationController.viewControllers.index(of: toViewController), let navigationBarSnapshot = self.navigationController.navigationBarSnapshots[index] {
            toViewControllerNavigationBarSnapshot = navigationBarSnapshot
        }
        
        // Disable user interaction
        toView.isUserInteractionEnabled = false
        
        // Create snapshot from navigation controller content
        // It's because we want the animate the whole content including transparent navbar, not just the child VC's content
        guard let fromViewSnapshot = navigationController.view.snapshotView(afterScreenUpdates: false) else {
            fatalError("Can't create a snapshot of view=\(navigationController.view)")
        }
        
        navigationController.setupNavigationBarByStyle(self.navigationBarStyleTransition)
        
        fromView.isHidden = true

        // Insert toView below fromView
        containerView.insertSubview(toView, belowSubview: fromView)
        
        // Insert fromView snapshot
        containerView.insertSubview(fromViewSnapshot, aboveSubview: fromView)
        
        if let snapshot = toViewControllerNavigationBarSnapshot {
            containerView.insertSubview(snapshot, aboveSubview: toView)
        }
        
        let navigationControllerFrame = navigationController.view.frame
        var toViewFinalFrame: CGRect = fromFrame.offsetBy(dx: -(fromFrame.width * 0.3), dy: 0)
        var fromViewFinalFrame: CGRect = fromView.frame.offsetBy(dx: fromView.frame.width, dy: 0)
        var fromViewSnapshotFinalFrame: CGRect = fromViewSnapshot.frame.offsetBy(dx: fromViewSnapshot.frame.width, dy: 0)
        var toFrame: CGRect = fromFrame
        
        if fromViewController.hidesBottomBarWhenPushed && navigationController.viewControllers.filter({ $0.hidesBottomBarWhenPushed }).count == 0 {
            // We can assume that fromViewController has the bottom bar hidden
            // whereas toViewController has the bottom bar shown
            // thus we need to reduce the height of the toFrame by the height of the bottom bar
            
            toFrame.size.height -= (toViewController.tabBarController?.tabBar.frame.height ?? 0)
        }
        
        if self.navigationBarStyleTransition == .toSolid {
            // Set move toView to the left about 30% of its width
            var shiftedFrame = toFrame.offsetBy(dx: -(toFrame.width * 0.3), dy: 0)
            
            let shift: CGFloat = 64 // 0 or make sure automaticallyAdjustScrollViewInsets is off
            shiftedFrame.size.height -= shift
            shiftedFrame.origin.y += shift
            toView.frame = shiftedFrame
            
            toViewFinalFrame = toFrame
            toViewFinalFrame.size.height -= shift
            toViewFinalFrame.origin.y += shift
            
        } else if (self.navigationBarStyleTransition == .toTransparent) {
            // Set move toView to the left about 30% of its width
            toView.frame = navigationControllerFrame.offsetBy(dx: -(navigationControllerFrame.width * 0.3), dy: 0)
            toViewFinalFrame = navigationControllerFrame
            fromViewSnapshotFinalFrame = navigationControllerFrame.offsetBy(dx: navigationControllerFrame.width, dy: 0)
        }
        
        // Save origin navigation bar frame
        let navigationBarFrame = self.navigationController.navigationBar.frame
        
        
        if self.navigationBarStyleTransition != .toSame {
            // Shift bar
            self.navigationController.navigationBar.frame = navigationBarFrame.offsetBy(dx: -navigationBarFrame.width, dy: 0)
        }

        let snapshotframe = navigationBarFrame.additiveRect(20, direction: .top)
        
        toViewControllerNavigationBarSnapshot?.frame = snapshotframe.offsetBy(dx: -(snapshotframe.width * 0.3), dy: 0)

        
        // Add shadows
        addShadows(toViews: [fromView, fromViewSnapshot])
        
        let options: UIViewAnimationOptions = isInteractive ? [.curveLinear] : [.curveEaseOut]
        
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: { () -> Void in
            
            fromView.frame = fromViewFinalFrame
            fromViewSnapshot.frame = fromViewSnapshotFinalFrame
            toView.frame = toViewFinalFrame
            toViewControllerNavigationBarSnapshot?.frame = snapshotframe
            
            
            }, completion: { (completed) -> Void in
                // Re-enable user interaction
                toView.isUserInteractionEnabled = true
                
                // Remove snapshots
                fromViewSnapshot.removeFromSuperview()
                toViewControllerNavigationBarSnapshot?.removeFromSuperview()
                
                self.navigationController.navigationBar.alpha = 1.0
                self.navigationController.navigationBar.frame = navigationBarFrame
                
                if context.transitionWasCancelled {
                    self.navigationController.setupNavigationBarByStyle(self.navigationBarStyleTransition.reverse())
                    fromView.isHidden = false
                    
                    // fromView.frame needs to be reset to it's original value, otherwise it's size is .zero (iOS 10)
                    fromView.frame = fromFrame
                }
                
                context.completeTransition(!context.transitionWasCancelled)
        })
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        
        // Sometimes, when a first view controller is popped out of navigation controller,
        // the view controller has hidesBottomBarOnPush=true, and tab bar has a custom subview added,
        // a tab bar controller (parent of the navigation controler) shrinks its content view
        // after the transition is completed. Calling `setNeedsLayout` fixes it.
        navigationController.tabBarController?.view.setNeedsLayout()
    }
}
