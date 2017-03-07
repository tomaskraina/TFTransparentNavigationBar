//
//  TFNavigationController.swift
//  TFTransparentNavigationBar
//
//  Created by Ales Kocur on 10/03/2015.
//  Copyright (c) 2015 Ales Kocur. All rights reserved.
//

import UIKit

@objc public enum TFNavigationBarStyle: Int {
    case transparent, solid
}

@objc public protocol TFTransparentNavigationBarProtocol {
    func navigationControllerBarPushStyle() -> TFNavigationBarStyle
}

open class TFNavigationController: UINavigationController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, UINavigationBarDelegate {
    
    /// Use this property to disable swipe to pop
    open fileprivate(set) weak var edgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    
    fileprivate var interactionController: UIPercentDrivenInteractiveTransition?
    fileprivate var temporaryBackgroundImage: UIImage?
    var navigationBarSnapshots: Dictionary<Int, UIView> = Dictionary()
    
    
    func createNavigationBarSnapshot(fromViewController: UIViewController) {
        
        let navbarSnapshot = self.navigationBar.resizableSnapshotView(from: self.navigationBar.bounds.additiveRect(20, direction: .top), afterScreenUpdates: false, withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0))
        
        // Save snapshot of navigation bar for pop animation
        if let index = self.viewControllers.index(of: fromViewController) {
            self.navigationBarSnapshots[index] = navbarSnapshot
        }
    }
    
    open override var viewControllers: [UIViewController] {
        didSet {
            // Because delegate is not being called when navigation stack changes
            viewControllers.last.flatMap {
                delegate?.navigationController?(self, willShow: $0, animated: false)
            }
        }
    }
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.shadowImage = UIImage()

        transitioningDelegate = self   // for presenting the original navigation controller
        delegate = self                // for navigation controller custom transitions
        //interactivePopGestureRecognizer?.delegate = nil
        
        let recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(TFNavigationController.handleSwipeFromLeft(_:)))
        recognizer.edges = .left
        self.view.addGestureRecognizer(recognizer)
        edgePanGestureRecognizer = recognizer
        
    }
    
    func handleSwipeFromLeft(_ gesture: UIScreenEdgePanGestureRecognizer) {
        
        let location = gesture.translation(in: gesture.view!)
        let width = gesture.view!.bounds.size.width
        
        let ratio = location.x / width
        
        if gesture.state == .began {
            interactionController = UIPercentDrivenInteractiveTransition()
            
            if viewControllers.count > 1 {
                popViewController(animated: true)
            }
            
        } else if gesture.state == .changed {
            interactionController?.update(ratio)
        } else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            
            if ratio > 0.5 {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
        }
    }
    
    
    // MARK: - UIViewControllerTransitioningDelegate

    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard self != presented else {
            return nil
        }
        
        return self.forwardAnimator(source, toViewController: presented)
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard self != dismissed && viewControllers.count > 1 else {
            return nil
        }
        
        // Last but one controller in stack
        let previousController = self.viewControllers[self.viewControllers.count - 2]
        
        return self.backwardAnimator(dismissed, toViewController: previousController)
    }
    
    open func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    open func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    // MARK: - UINavigationControllerDelegate
    
    open func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        // Make sure all view controllers that are presented by this navigation controller
        // have this set to false to prevent layout issues and blinking causes by wrong scroll insets
        viewController.automaticallyAdjustsScrollViewInsets = false
        
        // Support transparent navigation bar for the root view controller
        if let topViewController = topViewController as? TFTransparentNavigationBarProtocol, topViewController.navigationControllerBarPushStyle() == .transparent {
            setupNavigationBarByStyle(.toTransparent)
        }
    }
    
    open func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .push {
            return self.forwardAnimator(fromVC, toViewController: toVC)
        } else if operation == .pop {
            return self.backwardAnimator(fromVC, toViewController: toVC)
        }
        return nil
    }
    
    open func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    // MARK: - Helpers
    
    func forwardAnimator(_ fromViewController: UIViewController, toViewController: UIViewController) -> TFForwardAnimator? {
    
        var fromStyle: TFNavigationBarStyle = TFNavigationBarStyle.solid
        
        if let source = fromViewController as? TFTransparentNavigationBarProtocol {
            fromStyle = source.navigationControllerBarPushStyle()
        }
        
        var toStyle: TFNavigationBarStyle = TFNavigationBarStyle.solid
        
        if let presented = toViewController as? TFTransparentNavigationBarProtocol {
            toStyle = presented.navigationControllerBarPushStyle()
        }
        
        var styleTransition: TFNavigationBarStyleTransition!
        
        if fromStyle == toStyle {
            styleTransition = .toSame
        } else if fromStyle == .transparent && toStyle == .solid {
            styleTransition = .toSolid
        } else if fromStyle == .solid && toStyle == .transparent {
            styleTransition = .toTransparent
        }
        
        return TFForwardAnimator(navigationController: self, navigationBarStyleTransition: styleTransition, isInteractive: interactionController != nil)
    }
    
    func backwardAnimator(_ fromViewController: UIViewController, toViewController: UIViewController) -> TFBackwardAnimator? {
        
        var fromStyle: TFNavigationBarStyle = TFNavigationBarStyle.solid
        
        if let fromViewController = fromViewController as? TFTransparentNavigationBarProtocol {
            fromStyle = fromViewController.navigationControllerBarPushStyle()
        }
        
        var toStyle: TFNavigationBarStyle = TFNavigationBarStyle.solid
        
        if let toViewController = toViewController as? TFTransparentNavigationBarProtocol {
            toStyle = toViewController.navigationControllerBarPushStyle()
        }
        var styleTransition: TFNavigationBarStyleTransition!
        
        if fromStyle == toStyle {
            styleTransition = .toSame
        } else if fromStyle == .solid && toStyle == .transparent {
            styleTransition = .toTransparent
        } else if fromStyle == .transparent && toStyle == .solid {
            styleTransition = .toSolid
        }
        
        return TFBackwardAnimator(navigationController: self, navigationBarStyleTransition: styleTransition, isInteractive: interactionController != nil)
    }
    
    
    func setupNavigationBarByStyle(_ transitionStyle: TFNavigationBarStyleTransition) {
        
        if (transitionStyle == .toTransparent) {
            // set navbar to translucent
            self.navigationBar.isTranslucent = true
            // and make it transparent
            self.temporaryBackgroundImage = self.navigationBar.backgroundImage(for: .default)
            self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            
        } else if (transitionStyle == .toSolid) {
            
            self.navigationBar.isTranslucent = false
            self.navigationBar.setBackgroundImage(temporaryBackgroundImage, for: UIBarMetrics.default)
        }
    }
    
}

