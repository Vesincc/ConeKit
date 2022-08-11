//
//  ConeTabBarController.swift
//  MyKit
//
//  Created by HanQi on 2021/4/6.
//

import UIKit

open class ConeTabBarController: UITabBarController {

    open override func viewDidLoad() {
        super.viewDidLoad()
         
        configerTabBar()
    }
 
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        selectedViewController?.preferredStatusBarStyle ?? .default
    }
      
}

public extension ConeTabBarController {
    
    var universalShadowImage: UIImage? {
        get {
            if #available(iOS 13.0, *) {
                return tabBar.standardAppearance.shadowImage
            } else {
                return tabBar.shadowImage
            }
        }
        set {
            if #available(iOS 13.0, *) {
                tabBar.standardAppearance.shadowImage = newValue
            } else {
                tabBar.backgroundImage = UIImage(color: .white, size: CGSize(width: kScreenWidth, height: 0))
                tabBar.shadowImage = newValue
            }
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = tabBar.standardAppearance
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    var universalNormalTitleTextAttributes: [NSAttributedString.Key : Any]? {
        get {
            if #available(iOS 13.0, *) {
                return tabBar.standardAppearance.stackedLayoutAppearance.normal.titleTextAttributes
            } else {
                return tabBar.items?.first?.titleTextAttributes(for: .normal)
            }
        }
        set {
            if #available(iOS 13.0, *) {
                tabBar.standardAppearance.stackedLayoutAppearance.normal.titleTextAttributes = newValue ?? [:]
                tabBar.standardAppearance.inlineLayoutAppearance.normal.titleTextAttributes = newValue ?? [:]
                tabBar.standardAppearance.compactInlineLayoutAppearance.normal.titleTextAttributes = newValue ?? [:]
            } else {
                tabBar.items?.forEach({ item in
                    item.setTitleTextAttributes(newValue, for: .normal)
                })
            }
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = tabBar.standardAppearance
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    var universalSelectedTitleTextAttributes: [NSAttributedString.Key : Any]? {
        get {
            if #available(iOS 13.0, *) {
                return tabBar.standardAppearance.stackedLayoutAppearance.selected.titleTextAttributes
            } else {
                return tabBar.items?.first?.titleTextAttributes(for: .selected)
            }
        }
        set {
            if #available(iOS 13.0, *) {
                tabBar.standardAppearance.stackedLayoutAppearance.selected.titleTextAttributes = newValue ?? [:]
                tabBar.standardAppearance.inlineLayoutAppearance.selected.titleTextAttributes = newValue ?? [:]
                tabBar.standardAppearance.compactInlineLayoutAppearance.selected.titleTextAttributes = newValue ?? [:]
            } else {
                tabBar.items?.forEach({ item in
                    item.setTitleTextAttributes(newValue, for: .selected)
                })
            }
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = tabBar.standardAppearance
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    var universalBarTintColor: UIColor? {
        get {
            if #available(iOS 13.0, *) {
                return tabBar.standardAppearance.backgroundColor
            } else {
                return tabBar.barTintColor
            }
        }
        set {
            if #available(iOS 13.0, *) {
                tabBar.standardAppearance.backgroundColor = newValue
            } else {
                tabBar.barTintColor = newValue
                tabBar.isTranslucent = false
            }
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = tabBar.standardAppearance
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
}

extension ConeTabBarController {
    
    
    fileprivate func configerTabBar() {
        if #available(iOS 13.0, *) {
            tabBar.standardAppearance = UITabBarAppearance()
            tabBar.standardAppearance.backgroundEffect = nil
        } else {
            // Fallback on earlier versions
        }
         
    }
     
    
}
 
