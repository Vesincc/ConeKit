//
//  ConeNavigationController.swift
//  MyKit
//
//  Created by HanQi on 2021/4/6.
//

import Foundation
import UIKit

public protocol ConeNavigationControllerCustomLeftActionProtocol: UIViewController {
    
    func leftItemImageEdgeInsets() -> UIEdgeInsets?
    
    func leftItemImage() -> UIImage?
    
    func leftItemAction()
    
}

extension ConeNavigationControllerCustomLeftActionProtocol {
    func leftItemImageEdgeInsets() -> UIEdgeInsets? {
        return nil
    }
    
    func leftItemImage() -> UIImage? {
        return nil
    }
}

open class ConeNavigationController: UINavigationController {
     
    /// 返回图片
    @IBInspectable public var backImage: UIImage?
    
    /// 导航了左边按钮的insets
    public var backItemEdgeInsets: UIEdgeInsets = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight ?
    UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10) :
    UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
    
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
            if let vc = viewController as? ConeNavigationControllerCustomLeftActionProtocol, let image = vc.leftItemImage() {
                viewController.navigationItem.leftBarButtonItem = defaultBackLeftItem(image: image, imageEdgeInsets: vc.leftItemImageEdgeInsets() ?? backItemEdgeInsets)
            } else if let image = backImage {
                viewController.navigationItem.leftBarButtonItem = defaultBackLeftItem(image: image, imageEdgeInsets: backItemEdgeInsets)
            }
            viewController.hidesBottomBarWhenPushed = true
        } else {
            // root
            if let vc = viewController as? ConeNavigationControllerCustomLeftActionProtocol, let image = vc.leftItemImage() {
                viewController.navigationItem.leftBarButtonItem = defaultBackLeftItem(image: image, imageEdgeInsets: vc.leftItemImageEdgeInsets() ?? backItemEdgeInsets)
            }
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        topViewController?.preferredStatusBarStyle ?? .default
    }
}

public extension ConeNavigationController {
    
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

extension ConeNavigationController {
     
    fileprivate func configerNavigationBar() {
        if #available(iOS 13.0, *) {
            navigationBar.standardAppearance.backgroundEffect = nil
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        } else {
            // Fallback on earlier versions
        }
        
        if isHideNavigationBarBackground {
            setNavigationBarBarBackgroundHide()
        }
        
    }
    
    fileprivate func setNavigationBarBarBackgroundHide() {
        universalBackgroundImage = UIImage(color: .clear, size: navigationBar.bounds.size)
        universalBarTintColor = .clear
        isHideShadowImage = true
    }
    
    fileprivate func defaultBackLeftItem(image: UIImage, imageEdgeInsets: UIEdgeInsets) -> UIBarButtonItem {
        let button = Setter(UIButton())
            .image(image, for: .normal)
            .imageEdgeInsets(imageEdgeInsets)
            .excute({ t in
                t.addTarget(self, action: #selector(popAction), for: .touchUpInside)
            })
            .isExclusiveTouch(true)
            .subject
         
        return UIBarButtonItem.init(customView: button)
    }
    
    @objc fileprivate func popAction() {
        if let vc = topViewController as? ConeNavigationControllerCustomLeftActionProtocol {
            vc.leftItemAction()
        } else {
            popViewController(animated: true)
        }
    }
    
}

extension ConeNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        children.count > 1
    }
}

extension ConeNavigationController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let navigationController = navigationController as? ConeNavigationController else {
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
            if let navigationController = navigationController as? ConeNavigationController {
                navigationController.didEnterRootViewController?()
            }
        }
         
    }
}
