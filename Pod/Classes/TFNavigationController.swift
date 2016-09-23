//
//  TFNavigationController.swift
//  TFTransparentNavigationBar
//
//  Created by Ales Kocur on 10/03/2015.
//  Copyright (c) 2015 Ales Kocur. All rights reserved.
//

import UIKit

@objc public enum TFNavigationBarStyle: Int {
    case Transparent, Solid
}

@objc public protocol TFTransparentNavigationBarProtocol {
    func navigationControllerBarPushStyle() -> TFNavigationBarStyle
}

public class TFNavigationController: UINavigationController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, UINavigationBarDelegate {
    
    private var interactionController: UIPercentDrivenInteractiveTransition?
    private var temporaryBackgroundImage: UIImage?
    var navigationBarSnapshots: Dictionary<Int, UIView> = Dictionary()
    
    
    func createNavigationBarSnapshot(fromViewController: UIViewController) {
        
        let navbarSnapshot = self.navigationBar.resizableSnapshotViewFromRect(self.navigationBar.bounds.additiveRect(20, direction: .Top), afterScreenUpdates: false, withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0))
        
        // Save snapshot of navigation bar for pop animation
        if let index = self.viewControllers.indexOf(fromViewController) {
            self.navigationBarSnapshots[index] = navbarSnapshot
        }
    }
    
    public override var viewControllers: [UIViewController] {
        didSet {
            // Because delegate is not being called when navigation stack changes
            viewControllers.last.flatMap {
                delegate?.navigationController?(self, willShowViewController: $0, animated: false)
            }
        }
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.translucent = false
        self.navigationBar.shadowImage = UIImage()

        transitioningDelegate = self   // for presenting the original navigation controller
        delegate = self                // for navigation controller custom transitions
        //interactivePopGestureRecognizer?.delegate = nil
        
        let left = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(TFNavigationController.handleSwipeFromLeft(_:)))
        left.edges = .Left
        self.view.addGestureRecognizer(left);
        
        
    }
    
    func handleSwipeFromLeft(gesture: UIScreenEdgePanGestureRecognizer) {
        
        let location = gesture.translationInView(gesture.view!)
        let width = gesture.view!.bounds.size.width
        
        let ratio = location.x / width
        
        if gesture.state == .Began {
            interactionController = UIPercentDrivenInteractiveTransition()
            
            if viewControllers.count > 1 {
                popViewControllerAnimated(true)
            } else {
                dismissViewControllerAnimated(true, completion: nil)
            }
        } else if gesture.state == .Changed {
            interactionController?.updateInteractiveTransition(ratio)
        } else if gesture.state == .Ended || gesture.state == .Cancelled || gesture.state == .Failed {
            
            if ratio > 0.5 {
                interactionController?.finishInteractiveTransition()
            } else {
                interactionController?.cancelInteractiveTransition()
            }
            interactionController = nil
        }
    }
    
    
    // MARK: - UIViewControllerTransitioningDelegate

    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard self != presented else {
            return nil
        }
        
        return self.forwardAnimator(source, toViewController: presented)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard self != dismissed && viewControllers.count > 1 else {
            return nil
        }
        
        // Last but one controller in stack
        let previousController = self.viewControllers[self.viewControllers.count - 2]
        
        return self.backwardAnimator(dismissed, toViewController: previousController)
    }
    
    public func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    // MARK: - UINavigationControllerDelegate
    
    public func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        
        // Make sure all view controllers that are presented by this navigation controller
        // have this set to false to prevent layout issues and blinking causes by wrong scroll insets
        viewController.automaticallyAdjustsScrollViewInsets = false
        
        // Support transparent navigation bar for the root view controller
        if let topViewController = topViewController as? TFTransparentNavigationBarProtocol
            where topViewController.navigationControllerBarPushStyle() == .Transparent {
            setupNavigationBarByStyle(.toTransparent)
        }
    }
    
    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .Push {
            return self.forwardAnimator(fromVC, toViewController: toVC)
        } else if operation == .Pop {
            return self.backwardAnimator(fromVC, toViewController: toVC)
        }
        return nil
    }
    
    public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    // MARK: - Helpers
    
    func forwardAnimator(fromViewController: UIViewController, toViewController: UIViewController) -> TFForwardAnimator? {
    
        var fromStyle: TFNavigationBarStyle = TFNavigationBarStyle.Solid
        
        if let source = fromViewController as? TFTransparentNavigationBarProtocol {
            fromStyle = source.navigationControllerBarPushStyle()
        }
        
        var toStyle: TFNavigationBarStyle = TFNavigationBarStyle.Solid
        
        if let presented = toViewController as? TFTransparentNavigationBarProtocol {
            toStyle = presented.navigationControllerBarPushStyle()
        }
        
        var styleTransition: TFNavigationBarStyleTransition!
        
        if fromStyle == toStyle {
            styleTransition = .toSame
        } else if fromStyle == .Transparent && toStyle == .Solid {
            styleTransition = .toSolid
        } else if fromStyle == .Solid && toStyle == .Transparent {
            styleTransition = .toTransparent
        }
        
        return TFForwardAnimator(navigationController: self, navigationBarStyleTransition: styleTransition, isInteractive: interactionController != nil)
    }
    
    func backwardAnimator(fromViewController: UIViewController, toViewController: UIViewController) -> TFBackwardAnimator? {
        
        var fromStyle: TFNavigationBarStyle = TFNavigationBarStyle.Solid
        
        if let fromViewController = fromViewController as? TFTransparentNavigationBarProtocol {
            fromStyle = fromViewController.navigationControllerBarPushStyle()
        }
        
        var toStyle: TFNavigationBarStyle = TFNavigationBarStyle.Solid
        
        if let toViewController = toViewController as? TFTransparentNavigationBarProtocol {
            toStyle = toViewController.navigationControllerBarPushStyle()
        }
        var styleTransition: TFNavigationBarStyleTransition!
        
        if fromStyle == toStyle {
            styleTransition = .toSame
        } else if fromStyle == .Solid && toStyle == .Transparent {
            styleTransition = .toTransparent
        } else if fromStyle == .Transparent && toStyle == .Solid {
            styleTransition = .toSolid
        }
        
        return TFBackwardAnimator(navigationController: self, navigationBarStyleTransition: styleTransition, isInteractive: interactionController != nil)
    }
    
    
    func setupNavigationBarByStyle(transitionStyle: TFNavigationBarStyleTransition) {
        
        if (transitionStyle == .toTransparent) {
            // set navbar to translucent
            self.navigationBar.translucent = true
            // and make it transparent
            self.temporaryBackgroundImage = self.navigationBar.backgroundImageForBarMetrics(.Default)
            self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            
        } else if (transitionStyle == .toSolid) {
            
            self.navigationBar.translucent = false
            self.navigationBar.setBackgroundImage(temporaryBackgroundImage, forBarMetrics: UIBarMetrics.Default)
        }
    }
    
}

