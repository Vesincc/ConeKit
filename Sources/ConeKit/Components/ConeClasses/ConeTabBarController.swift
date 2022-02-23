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
        
        cinfigerTabbarItem()
        configerTabBar()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        createBadgeView()
        updateBadgePosition() 
  
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateBadgePosition()
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] (context) in
            self?.updateBadgePosition()
        }
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
            }
            tabBar.items?.forEach({ item in
                item.setTitleTextAttributes(newValue, for: .normal)
            })
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
            }
            tabBar.items?.forEach({ item in
                item.setTitleTextAttributes(newValue, for: .selected)
            })
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
        }
    }
    
}

extension ConeTabBarController {
    
    
    fileprivate func configerTabBar() {
        if #available(iOS 13.0, *) {
            tabBar.standardAppearance = UITabBarAppearance()
        } else {
            // Fallback on earlier versions
        }
         
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        } else {
            // Fallback on earlier versions
        }
    }
    
    fileprivate func createBadgeView() {
        tabBar.items?.forEach({ (item) in
            if item.isEnabled && item.badgeView == nil {
                let size = item.badgeSize
                item.badgeView = UIView.init(frame: .init(origin: .zero, size: size))
                
                item.badgeView?.backgroundColor = item.badgeColor
                item.badgeView?.layer.cornerRadius = min(size.width, size.height) / 2.0
            }
        })
    }
    
    fileprivate func updateBadgePosition() {
        for item in tabBar.items ?? [] {
            if item.isEnabledBadge {
                item.tabBarButton?.subviews.forEach({ (tempView) in
                    if tempView.classForCoder == NSClassFromString("_UIBadgeView") {
                        tempView.isHidden = true
                        if let badgeView = item.badgeView {
                            badgeView.isHidden = item.isHideBadge
                            if badgeView.superview == nil {
                                item.tabBarButton?.addSubview(badgeView)
                            }
                            let defaultSize = tempView.frame.size
                            let leftBottom = CGPoint.init(x: tempView.frame.origin.x, y: tempView.frame.origin.y + defaultSize.height)
                            
                            let offset = item.badgeOffset
                            let badgeSize = item.badgeSize
                            badgeView.frame.origin = .init(x: leftBottom.x + offset.x, y: leftBottom.y - badgeSize.height + offset.y)
                        }
                    }
                })
            }
        }
    }
    
    fileprivate func cinfigerTabbarItem() {
        
        var index = 1000
        tabBar.subviews.forEach { (view) in
            if view.classForCoder == NSClassFromString("UITabBarButton") {
                view.tag = index
                index += 1
            }
        }
        
        for (index, item) in (tabBar.items ?? []).enumerated() {
            item.tabBarButton = tabBar.viewWithTag(index + 1000)
        }
    }
    
}

public extension UITabBarItem {
    
    fileprivate enum AssociatedKeysByHQ {
        static var kBadgeView = "UITabBarItem.kBadgeView"
        static var kBadgeSize = "UITabBarItem.kBadgeSize"
        static var kBadgeColor = "UITabBarItem.kBadgeColor"
        static var kIsHideBadge = "UITabBarItem.kIsHideBadge"
        static var kBadgeOffset = "UITabBarItem.kBadgeOffset"
        static var kTabBarButton = "UITabBarItem.kTabBarButton"
    } 
    
    @IBInspectable var isEnabledBadge: Bool {
        get {
            badgeValue == " "
        }
        set {
            badgeValue = newValue ? " " : ""
        }
    }
    
    @IBInspectable var badgeView: UIView? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeysByHQ.kBadgeView) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysByHQ.kBadgeView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @IBInspectable var badgeSize: CGSize {
        get {
            objc_getAssociatedObject(self, &AssociatedKeysByHQ.kBadgeSize) as? CGSize ?? .init(width: 4, height: 4)
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysByHQ.kBadgeSize, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @IBInspectable var badgeColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeysByHQ.kBadgeColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysByHQ.kBadgeColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @IBInspectable var badgeOffset: CGPoint {
        get {
            objc_getAssociatedObject(self, &AssociatedKeysByHQ.kBadgeOffset) as? CGPoint ?? .zero
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysByHQ.kBadgeOffset, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @IBInspectable var isHideBadge: Bool {
        get {
            objc_getAssociatedObject(self, &AssociatedKeysByHQ.kIsHideBadge) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysByHQ.kIsHideBadge, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            badgeView?.isHidden = newValue
        }
    }
    
    private class ViewWrap: NSObject {
        internal init(view: UIView? = nil) {
            self.view = view
        }
        weak var view: UIView?
    }
    
    fileprivate var tabBarButton: UIView? {
        get {
            (objc_getAssociatedObject(self, &AssociatedKeysByHQ.kTabBarButton) as? ViewWrap)?.view
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysByHQ.kTabBarButton, ViewWrap(view: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
