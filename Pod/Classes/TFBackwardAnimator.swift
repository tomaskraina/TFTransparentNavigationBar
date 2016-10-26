//
//  TFBackwardAnimator.swift
//  TFTransparentNavigationBar
//
//  Created by Ales Kocur on 10/03/2015.
//  Copyright (c) 2015 Ales Kocur. All rights reserved.
//

import UIKit

class TFBackwardAnimator: TFNavigationBarAnimator, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.35
    }
    
    func animateTransition(context: UIViewControllerContextTransitioning) {
        
        let containerView = context.containerView()
        let toView = context.viewForKey(UITransitionContextToViewKey)!
        let fromView = context.viewForKey(UITransitionContextFromViewKey)!
        let options: UIViewAnimationOptions = isInteractive ? [.CurveLinear] : [.CurveEaseOut]
        let duration = self.transitionDuration(context)
        
        // Insert toView below from view
        containerView.insertSubview(toView, belowSubview: fromView)
        
        switch navigationBarStyleTransition {
        case .toTransparent, .toSolid:
             animateTransition(containerView, fromView: fromView, toView: toView, duration: duration, options: options, context: context)
            
        case .toSame:
            animateToSame(containerView, fromView: fromView, toView: toView, duration: duration, options: options, context: context)
        }
    }
    
    func animateToSame(containerView: UIView, fromView: UIView, toView: UIView, duration: NSTimeInterval, options: UIViewAnimationOptions, context: UIViewControllerContextTransitioning) {
        
        let fromViewController = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = context.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toViewFinalFrame = context.finalFrameForViewController(toViewController)
        
        // Shift to the left
        toView.frame = CGRectOffset(toViewFinalFrame, -(toViewFinalFrame.width * 0.3), 0)
        
        let fromViewFinalFrame: CGRect = {
            let initialFrame = context.initialFrameForViewController(fromViewController)
            return CGRectOffset(initialFrame, initialFrame.width, 0)
        }()
        
        addShadows([fromView])
        
        UIView.animateWithDuration(duration, delay: 0.0, options: options, animations: { () -> Void in
            
            toView.frame = toViewFinalFrame
            fromView.frame = fromViewFinalFrame
            
            }, completion: { (completed) -> Void in
                
                // Inform about transaction completion state
                context.completeTransition(!context.transitionWasCancelled())
        })
    }
    
    func animateTransition(containerView: UIView, fromView: UIView, toView: UIView, duration: NSTimeInterval, options: UIViewAnimationOptions, context: UIViewControllerContextTransitioning) {
        
        let containerView = context.containerView()
        let fromViewController = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = context.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let toView = context.viewForKey(UITransitionContextToViewKey)!
        let fromView = context.viewForKey(UITransitionContextFromViewKey)!
        let duration = self.transitionDuration(context)

        var fromFrame = context.initialFrameForViewController(fromViewController)
        
        var toViewControllerNavigationBarSnapshot: UIView?
        if let index = navigationController.viewControllers.indexOf(toViewController), let navigationBarSnapshot = self.navigationController.navigationBarSnapshots[index] {
            toViewControllerNavigationBarSnapshot = navigationBarSnapshot
        }
        
        // Disable user interaction
        toView.userInteractionEnabled = false
        
        // Create snapshot from navigation controller content
        let fromViewSnapshot = fromViewController.navigationController!.view.snapshotViewAfterScreenUpdates(false)!
        
        self.navigationController.setupNavigationBarByStyle(self.navigationBarStyleTransition)
        
        fromView.hidden = true

        // Insert toView below fromView
        containerView.insertSubview(toView, belowSubview: fromView)
        
        // Insert fromView snapshot
        containerView.insertSubview(fromViewSnapshot, aboveSubview: fromView)
        
        if let snapshot = toViewControllerNavigationBarSnapshot {
            containerView.insertSubview(snapshot, aboveSubview: toView)
        }
        
        let navigationControllerFrame = navigationController.view.frame
        var toViewFinalFrame: CGRect = CGRectOffset(fromFrame, -(fromFrame.width * 0.3), 0)
        var fromViewFinalFrame: CGRect = CGRectOffset(fromView.frame, fromView.frame.width, 0)
        var toFrame: CGRect = fromFrame
        
        if fromViewController.hidesBottomBarWhenPushed && navigationController.viewControllers.filter({ $0.hidesBottomBarWhenPushed }).count == 0 {
            // We can assume that fromViewController has the bottom bar hidden
            // whereas toViewController has the bottom bar shown
            // thus we need to reduce the height of the toFrame by the height of the bottom bar
            
            toFrame.size.height -= (toViewController.tabBarController?.tabBar.frame.height ?? 0)
        }
        
        if self.navigationBarStyleTransition == .toSolid {
            // Set move toView to the left about 30% of its width
            var shiftedFrame = CGRectOffset(toFrame, -(toFrame.width * 0.3), 0)
            
            let shift: CGFloat = 64 // 0 or make sure automaticallyAdjustScrollViewInsets is off
            shiftedFrame.size.height -= shift
            shiftedFrame.origin.y += shift
            toView.frame = shiftedFrame
            
            toViewFinalFrame = toFrame
            toViewFinalFrame.size.height -= shift
            toViewFinalFrame.origin.y += shift
            // Final frame for fromView and fromViewSnapshot
            fromViewFinalFrame = CGRectOffset(fromView.frame, fromView.frame.width, 0)
            
        } else if (self.navigationBarStyleTransition == .toTransparent) {
            // Set move toView to the left about 30% of its width
            toView.frame = CGRectOffset(navigationControllerFrame, -(navigationControllerFrame.width * 0.3), 0)
            toViewFinalFrame = navigationControllerFrame
            // Final frame for fromView and fromViewSnapshot
            fromViewFinalFrame = CGRectOffset(navigationControllerFrame, navigationControllerFrame.width, 0)
        }
        
        // Save origin navigation bar frame
        let navigationBarFrame = self.navigationController.navigationBar.frame
        
        
        if self.navigationBarStyleTransition != .toSame {
            // Shift bar
            self.navigationController.navigationBar.frame = CGRectOffset(navigationBarFrame, -navigationBarFrame.width, 0)
        }

        let snapshotframe = navigationBarFrame.additiveRect(20, direction: .Top)
        
        toViewControllerNavigationBarSnapshot?.frame = CGRectOffset(snapshotframe, -(snapshotframe.width * 0.3), 0)

        
        // Add shadows
        addShadows([fromView, fromViewSnapshot])
        
        let options: UIViewAnimationOptions = isInteractive ? [.CurveLinear] : [.CurveEaseOut]
        
        UIView.animateWithDuration(duration, delay: 0.0, options: options, animations: { () -> Void in
            
            fromView.frame = fromViewFinalFrame
            fromViewSnapshot.frame = fromViewFinalFrame
            toView.frame = toViewFinalFrame
            toViewControllerNavigationBarSnapshot?.frame = snapshotframe
            
            
            }, completion: { (completed) -> Void in
                // Re-enable user interaction
                toView.userInteractionEnabled = true
                
                // Remove snapshots
                fromViewSnapshot.removeFromSuperview()
                toViewControllerNavigationBarSnapshot?.removeFromSuperview()
                
                self.navigationController.navigationBar.alpha = 1.0
                self.navigationController.navigationBar.frame = navigationBarFrame
                
                if context.transitionWasCancelled() {
                    self.navigationController.setupNavigationBarByStyle(self.navigationBarStyleTransition.reverse())
                    fromView.hidden = false
                    
                    // fromView.frame needs to be reset to it's original value, otherwise it's size is .zero (iOS 10)
                    fromView.frame = fromFrame
                }
                
                context.completeTransition(!context.transitionWasCancelled())
        })
    }
    
    func animationEnded(transitionCompleted: Bool) {
        
        // Sometimes, when a first view controller is popped out of navigation controller,
        // the view controller has hidesBottomBarOnPush=true, and tab bar has a custom subview added,
        // a tab bar controller (parent of the navigation controler) shrinks its content view
        // after the transition is completed. Calling `setNeedsLayout` fixes it.
        navigationController.tabBarController?.view.setNeedsLayout()
    }
}
