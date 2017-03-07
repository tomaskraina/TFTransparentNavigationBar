//
//  UIViewController+NavigationBarBackground.swift
//  TFTransparentNavigationBar
//
//  Created by Tom Kraina on 02/08/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addNavigationBarBackground() -> UIView? {
        
        if let navBarFrame = navigationController?.navigationBar.frame {
            
            let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: navBarFrame.width, height: navBarFrame.maxY))
            
            backgroundView.backgroundColor = navigationController?.navigationBar.barTintColor ?? UIColor.white
            backgroundView.alpha = 0.0
            backgroundView.clipsToBounds = false
            
            if let shadowImage = navigationController?.navigationBar.shadowImage {
                print("shadowImage: \(shadowImage)")
                let imageView = UIImageView(image: shadowImage)
                imageView.frame.origin = CGPoint(x: 0, y: backgroundView.bounds.height)
                imageView.frame.size = CGSize(width: backgroundView.bounds.width, height: 0.5)
                imageView.backgroundColor = UIColor(white: 0, alpha: 0.3) // default iOS
                print("Adding imageView: \(imageView)")
                backgroundView.addSubview(imageView)
            }
            
            // a) nav bar
            //            navigationController?.navigationBar.insertSubview(view, atIndex: 0)
            
            // b) nav bar superview
            //            if let navBar = navigationController?.navigationBar {
            //                navBar.superview?.insertSubview(view, belowSubview: navBar)
            //            }
            
            // c) view
            view.addSubview(backgroundView)
            return backgroundView
        }
        
        return nil
    }
    
    func setUpFading(_ viewFadingBehaviour: ViewFadingBehaviour, forTableView tableView: UITableView?) {
        if let viewToFade = addNavigationBarBackground() {
            viewFadingBehaviour.viewToFadeIn = viewToFade
            viewFadingBehaviour.scrollViewToObserve = tableView
            
            if let header = tableView?.tableHeaderView {
                viewFadingBehaviour.beginY = viewToFade.frame.maxY
                viewFadingBehaviour.endY = header.frame.height - viewToFade.frame.maxY
            }
        }
    }
}
