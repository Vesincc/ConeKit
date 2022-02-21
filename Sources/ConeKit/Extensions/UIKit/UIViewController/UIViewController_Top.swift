//
//  File.swift
//  
//
//  Created by HanQi on 2021/8/12.
//

import Foundation
import UIKit

public struct FetchTop<Base> {
    fileprivate let base: Base
    
    fileprivate init(_ base: Base) {
        self.base = base
    }
}

public protocol FetchTopCompatible: NSObjectProtocol {
    
    associatedtype CompatibleType
    
    static var top: FetchTop<CompatibleType>.Type { get }
    
}

public extension FetchTopCompatible {
    
    static var top: FetchTop<Self>.Type {
        FetchTop<Self>.self
    }
     
}

extension UIViewController: FetchTopCompatible {}

public protocol ContainerViewControllerDelegate {
    
    var currentViewController: UIViewController? { get }
    
}

public extension FetchTop where Base: UIViewController {
    
    private static var currentWindow: UIWindow? {
        var window: UIWindow?
        if #available(iOS 13, *) {
            window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({ $0.windows }).first
        } else {
            window = UIApplication.shared.windows.first
        }
        return window
    }
    
    static var viewController: UIViewController? {
        top(type: UIViewController.self, stack: currentWindow?.rootViewController, isMember: false)
    }
    
    static var navigationController: UINavigationController? {
        top(type: UINavigationController.self, stack: currentWindow?.rootViewController, isMember: false) as? UINavigationController
    }
    
    static var tabBarController: UITabBarController? {
        top(type: UITabBarController.self, stack: currentWindow?.rootViewController, isMember: false) as? UITabBarController
    }
    
    static func viewController<T: UIViewController>(_ aController: T.Type) -> T? {
        top(type: aController, stack: currentWindow?.rootViewController, isMember: true) as? T
    }
}

public extension FetchTop where Base: UIViewController {
    
    var isTopDisplay: Bool {
        UIViewController.top.viewController == self.base
    }
    
}

fileprivate extension FetchTop where Base: UIViewController {
    
    static func top(type: UIViewController.Type, stack: UIViewController?, isMember: Bool) -> UIViewController? {
        guard let stack = stack else {
            return nil
        }
        var target: UIViewController?
        if isMember {
            if stack.isMember(of: type) {
                target = stack
            }
        } else {
            if stack.isKind(of: type) {
                target = stack
            }
        }
        if let temp = top(type: type, stack: stack.presentedViewController, isMember: isMember) {
            target = temp
        } else if let temp = stack as? UITabBarController {
            if let top = top(type: type, stack: temp.selectedViewController, isMember: isMember) {
                target = top
            }
        } else if let temp = stack as? UINavigationController {
            if let top = top(type: type, stack: temp.topViewController, isMember: isMember) {
                target = top
            } else {
                if isMember {
                    if let exist = temp.viewControllers.last(where: { $0.isMember(of: type) }) {
                        target = exist
                    }
                } else {
                    if let exist = temp.viewControllers.last(where: { $0.isKind(of: type) }) {
                        target = exist
                    }
                }
            }
        } else if let temp = stack as? ContainerViewControllerDelegate {
            if let top = top(type: type, stack: temp.currentViewController, isMember: isMember) {
                target = top
            }
        }
        return target
    }
    
}

