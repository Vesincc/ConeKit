//
//  File.swift
//  
//
//  Created by HanQi on 2021/9/27.
//

import Foundation
import UIKit

public extension UIFont {
    
    enum PingFangWeight: String {
        case light = "PingFangSC-Light"
        case regular = "PingFangSC-Regular"
        case medium = "PingFangSC-Medium"
        case semibold = "PingFangSC-Semibold"
    }
    
    convenience init(pingFang size: CGFloat, weight: PingFangWeight) {
        self.init(name: weight.rawValue, size: size)!
    }
    
}
