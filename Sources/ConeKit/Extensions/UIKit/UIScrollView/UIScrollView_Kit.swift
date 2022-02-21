//
//  File.swift
//  
//
//  Created by HanQi on 2021/8/12.
//

import Foundation
import UIKit

extension UIScrollView {
    
    private var currentWindow: UIWindow? {
        var window: UIWindow?
        if #available(iOS 13, *) {
            window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({ $0.windows }).first
        } else {
            window = UIApplication.shared.windows.first
        }
        return window
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if panBack(gestureRecognizer) {
            return false
        }
        return true
    }
    
    public func panBack(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        //是滑动返回距左边的有效长度
        let locationX = 0.2 * UIScreen.main.bounds.width
        
        if (gestureRecognizer == panGestureRecognizer) {
            let pan = gestureRecognizer as? UIPanGestureRecognizer
            let point = pan?.translation(in: self)
            let state = gestureRecognizer.state
            if .began == state || .possible == state {
                let location = gestureRecognizer.location(in: self)
                let screenPoint = convert(location, to: currentWindow)
                if point?.x ?? 0 > 0 && screenPoint.x < locationX {
                    return true
                }
            }
        }
        return false
    }
    
}
