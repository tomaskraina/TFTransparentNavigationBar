//
//  FadingViewBehaviour.swift
//  TFTransparentNavigationBar
//
//  Created by Tom Kraina on 02/08/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

private var myContext = 0

class ViewFadingBehaviour: NSObject {
    
    @IBOutlet weak var scrollViewToObserve: UIScrollView! {
        didSet {
            if let view = oldValue {
                stopObserving(view: view)
            }
            if let view = scrollViewToObserve {
                startObserving(view: view)
            }
        }
    }
    
    @IBOutlet weak var viewToFadeIn: UIView?
    
    var beginY: CGFloat = 0
    var endY: CGFloat = 64
    
    
    deinit {
        if let view = scrollViewToObserve {
            stopObserving(view: view)
        }
    }
    
    // MARK: - KVO
    
    let keyPath = #selector(getter: UIScrollView.contentOffset)
    
    func startObserving(view: UIView) {
        view.addObserver(self, forKeyPath: String(describing: keyPath), options: .new, context: &myContext)
    }
    
    func stopObserving(view: UIView) {
        view.removeObserver(self, forKeyPath: String(describing: keyPath))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &myContext && keyPath == String(describing: self.keyPath) && object as AnyObject === scrollViewToObserve {
            
            guard let contentOffset = (change?[NSKeyValueChangeKey.newKey] as AnyObject).cgPointValue else {
                return
            }
            
            guard let viewToFadeIn = viewToFadeIn else {
                return
            }
            
            fadeView(viewToFadeIn, contentOffset: contentOffset, minY: beginY, maxY: endY)
        }
        
    }
    
    // MARK: - Helper methods
    
    fileprivate func fadeView(_ view: UIView, contentOffset: CGPoint, minY: CGFloat, maxY: CGFloat) {
        
        let y = contentOffset.y
        let range = max(minY, maxY) - min(minY, maxY)
        
        if y <= minY {
            view.alpha = 0.0
        } else if y < maxY && y > minY {
            let positionAlpha = (y - minY) / range
            view.alpha = positionAlpha
        } else {
            view.alpha = 1.0
        }
    }
    
}
