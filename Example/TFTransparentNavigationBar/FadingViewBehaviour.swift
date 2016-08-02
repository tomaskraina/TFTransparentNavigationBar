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
                stopObserving(view)
            }
            if let view = scrollViewToObserve {
                startObserving(view)
            }
        }
    }
    
    @IBOutlet weak var viewToFadeIn: UIView?
    
    var beginY: CGFloat = 0
    var endY: CGFloat = 64
    
    
    deinit {
        if let view = scrollViewToObserve {
            stopObserving(view)
        }
    }
    
    // MARK: - KVO
    
    let keyPath = Selector("contentOffset")
    
    func startObserving(view: UIView) {
        view.addObserver(self, forKeyPath: String(keyPath), options: .New, context: &myContext)
    }
    
    func stopObserving(view: UIView) {
        view.removeObserver(self, forKeyPath: String(keyPath))
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if context == &myContext && keyPath == String(self.keyPath) && object === scrollViewToObserve {
            
            guard let contentOffset = change?[NSKeyValueChangeNewKey]?.CGPointValue() else {
                return
            }
            
            guard let viewToFadeIn = viewToFadeIn else {
                return
            }
            
            fadeView(viewToFadeIn, contentOffset: contentOffset, minY: beginY, maxY: endY)
        }
        
    }
    
    // MARK: - Helper methods
    
    private func fadeView(view: UIView, contentOffset: CGPoint, minY: CGFloat, maxY: CGFloat) {
        
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
