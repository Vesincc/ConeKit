//
//  Constants.swift
//  CloudBrickKit
//
//  Created by HanQi on 2021/2/2.
//

import Foundation
import UIKit

public let kScreenWidth = UIScreen.main.bounds.width

public let kScreenHeight = UIScreen.main.bounds.height

public let kScreenScale = kScreenWidth / 375.0

public let kScreenHeightScale = kScreenHeight / 667.0

public let kNavigationBarHeight: CGFloat = 44.0

public let kTabBarHeight: CGFloat = 49.0

public let kCurrentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

public let kCurrentBuildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

public let kCurrentBundleIdentifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""

public func kSafeAreaInset() -> UIEdgeInsets {
    if #available(iOS 11.0, *) {
        if let window = UIWindow.current {
            if window.safeAreaInsets.bottom == 0 {
                return .init(top: 20, left: 0, bottom: 0, right: 0)
            } else {
                if window.safeAreaInsets.top == 0 {
                    return .init(top: 20, left: 0, bottom: 0, right: 0)
                } else {
                    return window.safeAreaInsets
                }
            }
        }
        assertionFailure("Window is nil")
    }
    return .init(top: 20, left: 0, bottom: 0, right: 0)
}

public func kHasSafeArea() -> Bool {
    if #available(iOS 11.0, *) {
        return kSafeAreaInset().bottom > 0
    } else {
        return false
    }
}

public func kSafeAreaTop() -> CGFloat {
    return kSafeAreaInset().top
}

public func kSafeAreaBottom() -> CGFloat {
    return kSafeAreaInset().bottom
}
 
