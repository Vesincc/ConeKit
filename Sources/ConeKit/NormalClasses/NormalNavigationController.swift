//
//  NormalNavigationController.swift
//  MyKit
//
//  Created by HanQi on 2021/4/6.
//

import Foundation
import UIKit

public class NormalNavigationController: UINavigationController {
     
    /// 返回图片
    @IBInspectable public var backImage: UIImage?
    
    /// 隐藏shadowImage
    @IBInspectable public var isHideShadowImage: Bool = false {
        didSet {
            if isHideShadowImage {
                universalShadowImage = UIImage(color: .clear, size: CGSize(width: kScreenWidth, height: 1))
            }
        }
    }
    
    /// 隐藏navigationbar背景色
    @IBInspectable public var isHideNavigationBarBackground: Bool = false {
        didSet {
            if isHideNavigationBarBackground {
                setNavigationBarBarBackgroundHide()
            }
        }
    }
    
    public var isEnableColorAndHide = true
    
    /// 将要离开root
    public var willLeaveRootViewController: (() -> ())?
    /// 进入root
    public var didEnterRootViewController: (() -> ())?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.delegate = self 
        
        configerNavigationBar()
    }
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0 {
            willLeaveRootViewController?()
            if let _ = backImage {
                viewController.navigationItem.leftBarButtonItem = defaultBackLeftItem
            }
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        topViewController?.preferredStatusBarStyle ?? .default
    }
}

public extension NormalNavigationController {
    
    var universalShadowImage: UIImage? {
        get {
            if #available(iOS 13.0, *) {
                return navigationBar.standardAppearance.shadowImage
            } else {
                return navigationBar.shadowImage
            }
        }
        set {
            if #available(iOS 13.0, *) {
                navigationBar.standardAppearance.shadowImage = newValue
                navigationBar.scrollEdgeAppearance?.shadowImage = newValue
            } else {
                navigationBar.setBackgroundImage(UIImage(color: .clear, size: CGSize(width: kScreenWidth, height: 0)), for: .default)
                navigationBar.shadowImage = newValue
            }
        }
    }
    
    var universalBackgroundImage: UIImage? {
        get {
            if #available(iOS 13.0, *) {
                return navigationBar.standardAppearance.backgroundImage
            } else {
                return navigationBar.backgroundImage(for: .default)
            }
        }
        set {
            if #available(iOS 13.0, *) {
                navigationBar.standardAppearance.backgroundImage = newValue
                navigationBar.scrollEdgeAppearance?.backgroundImage = newValue
            } else {
                navigationBar.setBackgroundImage(newValue, for: .default)
            }
        }
    }
    
    var universalBarTintColor: UIColor? {
        get {
            if #available(iOS 13.0, *) {
                return navigationBar.standardAppearance.backgroundColor
            } else {
                return navigationBar.barTintColor
            }
        }
        set {
            if #available(iOS 13.0, *) {
                navigationBar.standardAppearance.backgroundColor = newValue
                navigationBar.scrollEdgeAppearance?.backgroundColor = newValue
            } else {
                navigationBar.barTintColor = newValue
                navigationBar.isTranslucent = false
            }
        }
    }
    
    var universalTitleTextAttributes: [NSAttributedString.Key : Any]? {
        get {
            if #available(iOS 13.0, *) {
                return navigationBar.standardAppearance.titleTextAttributes
            } else {
                return navigationBar.titleTextAttributes
            }
        }
        set {
            if #available(iOS 13.0, *) {
                navigationBar.standardAppearance.titleTextAttributes = newValue ?? [:]
                navigationBar.scrollEdgeAppearance?.titleTextAttributes = newValue ?? [:]
            } else {
                navigationBar.titleTextAttributes = newValue
            }
        }
    }
    
}

extension NormalNavigationController {
    
    public func configerWhiteContent() {
        universalTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(pingFang: 18, weight: .medium)
        ]
    }
    
    fileprivate func configerNavigationBar() {
        if #available(iOS 13.0, *) {
            navigationBar.standardAppearance.backgroundEffect = nil
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        } else {
            // Fallback on earlier versions
        }
        
        universalTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.init(rgb: 0x333333),
            NSAttributedString.Key.font : UIFont(pingFang: 18, weight: .medium)
        ]
        
        if isHideNavigationBarBackground {
            setNavigationBarBarBackgroundHide()
        }
    }
    
    fileprivate func setNavigationBarBarBackgroundHide() {
        universalBackgroundImage = UIImage(color: .clear, size: navigationBar.bounds.size)
        universalBarTintColor = .clear
        isHideShadowImage = true
    }
    
    fileprivate var defaultBackLeftItem: UIBarButtonItem {
        get {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            button.setImage(backImage, for: .normal)
            button.setImage(backImage, for: .highlighted)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
            button.addTarget(self, action: #selector(popAction), for: .touchUpInside)
            button.isExclusiveTouch = true
            let custom = UIBarButtonItem.init(customView: button)
            if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
                button.layer.setAffineTransform(.init(rotationAngle: .pi))
            }
            return custom
        }
    }
    
    @objc fileprivate func popAction() {
        popViewController(animated: true)
    }
    
}

extension NormalNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        children.count > 1
    }
}

extension NormalNavigationController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let navigationController = navigationController as? NormalNavigationController else {
            return
        }
        
        guard isEnableColorAndHide else {
            return
        }
        
        // hide
        navigationController.setNavigationBarHidden(viewController.kNavigationBarHide, animated: animated)
        
        if !navigationController.isHideNavigationBarBackground, let color = viewController.kNavigationBarColor ?? self.kNavigationBarColor, !viewController.kNavigationBarHide {
            // color
            navigationController.universalBarTintColor = color
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if navigationController.children.count > 1 {
            
        } else {
            if let navigationController = navigationController as? NormalNavigationController {
                navigationController.didEnterRootViewController?()
            }
        }
         
    }
} 
