//
//  File.swift
//  
//
//  Created by HanQi on 2021/8/12.
//

import Foundation
import UIKit

public extension UIWindow {
    
    static var current: UIWindow? {
        var window: UIWindow?
        if #available(iOS 13, *) {
            window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({ $0.windows }).first
        } else {
            window = UIApplication.shared.windows.first
        }
        return window
    }
    
    /// rootViewController 切换 动画
    /// - Parameters:
    ///   - viewController: 目地VC
    ///   - animated: Bool
    ///   - duration: TimeInterval
    ///   - options: UIView.AnimationOptions
    ///   - completion: completion
    func switchRootViewController(to viewController: UIViewController,
                                  animated: Bool = true,
                                  duration: TimeInterval = 0.4,
                                  options: UIView.AnimationOptions = [.curveEaseInOut,
                                                                      .transitionCrossDissolve],
                                  completion: (() -> Void)? = nil) {
        guard animated else {
            rootViewController = viewController
            completion?()
            return
        }
        
        UIView.transition(with: self, duration: duration, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }, completion: { _ in
            completion?()
        })
    }
    
}
