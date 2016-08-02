//
//  TFNavigationBarAnimator.swift
//  TFTransparentNavigationBar
//
//  Created by Ales Kocur on 10/03/2015.
//  Copyright (c) 2015 Ales Kocur. All rights reserved.
//

import UIKit

enum TFNavigationBarStyleTransition {
    case toTransparent, toSolid, toSame
    
    func reverse() -> TFNavigationBarStyleTransition {
        switch self {
        case .toSolid:
            return .toTransparent
        case .toTransparent:
            return .toSolid
        case .toSame:
            return .toSame
        }
    }
}

class TFNavigationBarAnimator: NSObject {
    let navigationController: TFNavigationController
    
    let navigationBarStyleTransition: TFNavigationBarStyleTransition
    let isInteractive: Bool
    
    init(navigationController: TFNavigationController, navigationBarStyleTransition: TFNavigationBarStyleTransition, isInteractive: Bool = false) {
        self.navigationController = navigationController
        self.navigationBarStyleTransition = navigationBarStyleTransition
        self.isInteractive = isInteractive
    }
    
    func addShadows(views: [UIView]) {
        views.forEach {
            $0.layer.shadowOffset = CGSizeMake(0.0, 0.0)
            $0.layer.shadowColor = UIColor.blackColor().CGColor
            $0.layer.shadowRadius = 5.0
            $0.layer.shadowOpacity = 0.5
            $0.layer.shadowPath = UIBezierPath(rect: $0.bounds).CGPath
        }
    }
}
