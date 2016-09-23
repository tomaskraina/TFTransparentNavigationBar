//
//  TFForwardAnimator.swift
//  TFTransparentNavigationBar
//
//  Created by Ales Kocur on 10/03/2015.
//  Copyright (c) 2015 Ales Kocur. All rights reserved.
//

import UIKit

class TFForwardAnimator: TFNavigationBarAnimator, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.35
    }
    
    func animateTransition(context: UIViewControllerContextTransitioning) {
        
        let containerView = context.containerView()
        let toView = context.viewForKey(UITransitionContextToViewKey)!
        let fromView = context.viewForKey(UITransitionContextFromViewKey)!
        let options: UIViewAnimationOptions = isInteractive ? [.CurveLinear] : [.CurveEaseOut]
        let duration = self.transitionDuration(context)
        
        // Insert toView above from view
        containerView.insertSubview(toView, aboveSubview: fromView)
        
        switch navigationBarStyleTransition {
        case .toTransparent:
            animateToTransparent(containerView, fromView: fromView, toView: toView, duration: duration, options: options, context: context)
        case .toSolid:
            animateToSolid(containerView, fromView: fromView, toView: toView, duration: duration, options: options, context: context)
        case .toSame: 
            animateToSame(containerView, fromView: fromView, toView: toView, duration: duration, options: options, context: context)
        }
    }
    
    
    func animateToSolid(containerView: UIView, fromView: UIView, toView: UIView, duration: NSTimeInterval, options: UIViewAnimationOptions, context: UIViewControllerContextTransitioning) {
        
        let fromViewController = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = context.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        // Create snapshot from navigation controller content
        let fromViewSnapshot = fromViewController.navigationController!.view.snapshotViewAfterScreenUpdates(false)!
        
        // Create snapshot of navigation bar
        navigationController.createNavigationBarSnapshot(fromViewController)
        
        // Insert fromView snapshot above fromView
        containerView.insertSubview(fromViewSnapshot, belowSubview: toView)
        
        // hide fromView and use snapshot instead
        fromView.hidden = true
        
        self.navigationController.setupNavigationBarByStyle(self.navigationBarStyleTransition)
        
        let navigationControllerFrame = navigationController.view.frame
        
        var toViewFinalFrame = context.finalFrameForViewController(toViewController)
        toViewFinalFrame = toViewFinalFrame.additiveRect(-64, direction: .Top)
        
        // Move toView to the right
        toView.frame = CGRectOffset(toViewFinalFrame, toViewFinalFrame.width, 0)
        
        // Calculate final frame for fromView and fromViewSnapshot
        let fromViewFinalFrame = CGRectOffset(navigationControllerFrame, -(navigationControllerFrame.width * 0.3), 0)
        
        // Save origin navigation bar frame
        let navigationBarFinalFrame = self.navigationController.navigationBar.frame
        
        // Shift bar
        self.navigationController.navigationBar.frame = CGRectOffset(navigationBarFinalFrame, navigationBarFinalFrame.width, 0)
        
        addShadows([toView])
        
        
        UIView.animateWithDuration(duration, delay: 0.0, options: options, animations: { () -> Void in
            
            toView.frame = toViewFinalFrame
            fromViewSnapshot.frame = fromViewFinalFrame
            
            // Shift navigation bar
            self.navigationController.navigationBar.frame = navigationBarFinalFrame
            
            }, completion: { (completed) -> Void in
                // Show fromView
                fromView.frame = fromViewFinalFrame
                fromView.hidden = false
                // Remove snapshot
                fromViewSnapshot.removeFromSuperview()
                // Inform about transaction completion state
                context.completeTransition(!context.transitionWasCancelled())
        })
        
    }
    
    
    func animateToTransparent(containerView: UIView, fromView: UIView, toView: UIView, duration: NSTimeInterval, options: UIViewAnimationOptions, context: UIViewControllerContextTransitioning) {
        
        let fromViewController = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = context.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        // Create snapshot from navigation controller content
        let fromViewSnapshot = fromViewController.navigationController!.view.snapshotViewAfterScreenUpdates(false)!
        
        // Create snapshot of navigation bar
        navigationController.createNavigationBarSnapshot(fromViewController)
        
        // Insert fromView snapshot above fromView
        containerView.insertSubview(fromViewSnapshot, belowSubview: toView)
        
        // hide fromView and use snapshot instead
        fromView.hidden = true
        
        self.navigationController.setupNavigationBarByStyle(self.navigationBarStyleTransition)
        
        let navigationControllerFrame = navigationController.view.frame
        
        let toViewFinalFrame: CGRect = context.finalFrameForViewController(toViewController)
        
        // Move toView to the right
        toView.frame = CGRectOffset(toViewFinalFrame, toViewFinalFrame.width, 0)
        
        // Calculate final frame for fromView and fromViewSnapshot
        let fromViewFinalFrame = CGRectOffset(navigationControllerFrame, -(navigationControllerFrame.width * 0.3), 0)
        
        // Save origin navigation bar frame
        let navigationBarFrame = self.navigationController.navigationBar.frame
        
        // Shift bar
        self.navigationController.navigationBar.frame = CGRectOffset(navigationBarFrame, navigationBarFrame.width, 0)
        
        addShadows([toView])
        
        
        
        UIView.animateWithDuration(duration, delay: 0.0, options: options, animations: { () -> Void in
            
            toView.frame = toViewFinalFrame
            fromViewSnapshot.frame = fromViewFinalFrame
            
            // Shift navigation bar
            self.navigationController.navigationBar.frame = navigationBarFrame
            
            }, completion: { (completed) -> Void in
                // Show fromView
                fromView.frame = fromViewFinalFrame
                fromView.hidden = false
                // Remove snapshot
                fromViewSnapshot.removeFromSuperview()
                // Inform about transaction completion state
                context.completeTransition(!context.transitionWasCancelled())
        })
    }
    
    func animateToSame(containerView: UIView, fromView: UIView, toView: UIView, duration: NSTimeInterval, options: UIViewAnimationOptions, context: UIViewControllerContextTransitioning) {
        
        let fromViewController = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = context.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toViewFinalFrame = context.finalFrameForViewController(toViewController)
        
        // Shift to the right
        toView.frame = CGRectOffset(toViewFinalFrame, toViewFinalFrame.width, 0)
        
        let fromViewFinalFrame: CGRect = {
            let initialFrame = context.initialFrameForViewController(fromViewController)
            return CGRectOffset(initialFrame, -(initialFrame.width * 0.3), 0)
        }()
        
        addShadows([toView])
        
        
        UIView.animateWithDuration(duration, delay: 0.0, options: options, animations: { () -> Void in
            
            toView.frame = toViewFinalFrame
            fromView.frame = fromViewFinalFrame
            
            }, completion: { (completed) -> Void in

                // Inform about transaction completion state
                context.completeTransition(!context.transitionWasCancelled())
        })
    }
}
