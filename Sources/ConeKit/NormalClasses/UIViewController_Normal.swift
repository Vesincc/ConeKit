//
//  UIViewController.swift
//  MyKit
//
//  Created by HanQi on 2021/4/6.
//

import Foundation
import UIKit

public extension UIViewController {
    
    fileprivate enum AssociatedKeysByHQ {
        static var kNavigationBarHide = "UIViewController.kNavigationBarHide"
        static var kNavigationBarColor = "UIViewController.kNavigationBarColor"
    }
     
    
    @IBInspectable var kNavigationBarHide: Bool {
        get {
            objc_getAssociatedObject(self, &AssociatedKeysByHQ.kNavigationBarHide) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysByHQ.kNavigationBarHide, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
     
    @IBInspectable var kNavigationBarColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeysByHQ.kNavigationBarColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysByHQ.kNavigationBarColor, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    func setNavigationBarLeftItem(image: UIImage?, action: Selector) -> UIButton {
        let button = UIButton.init()
        button.setImage(image, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.imageEdgeInsets = .init(top: 9, left: 0, bottom: 9, right: 16)
        
        navigationItem.leftBarButtonItem = .init(customView: button)
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            button.layer.setAffineTransform(.init(rotationAngle: .pi))
        }
        return button
    }
    
    func setNavigationBarRightItem(image: UIImage?, action: Selector) -> UIButton {
        let button = UIButton.init()
        button.setImage(image, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        button.addTarget(self, action: action, for: .touchUpInside)
        navigationItem.rightBarButtonItem = .init(customView: button)
        return button
    }
    
}
