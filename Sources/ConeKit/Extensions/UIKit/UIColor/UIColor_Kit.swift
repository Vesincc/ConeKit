//
//  File.swift
//  
//
//  Created by HanQi on 2021/8/12.
//

import Foundation
import UIKit

public extension UIColor {
    
    /// 随机颜色
    static var random: UIColor {
        let red = arc4random() % 255
        let green = arc4random() % 255
        let blue = arc4random() % 255
        
        return UIColor.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1)
    }
    
    /// 初始化颜色
    /// - Parameter hex: argb
    convenience init(argb hex: UInt32) {
        self.init(red:  CGFloat((hex & 0x00ff0000) >> 16) / 255,
                  green: CGFloat((hex & 0x0000ff00) >> 8) / 255,
                  blue: CGFloat((hex & 0x000000ff) >> 0) / 255,
                  alpha: CGFloat((hex & 0xff000000) >> 24) / 255)
    }
    
    /// 初始化颜色
    /// - Parameters:
    ///   - hex: rgb
    ///   - alpha: alpha
    convenience init(rgb hex: UInt32, alpha: CGFloat = 1) {
        self.init(red:  CGFloat((hex & 0xff0000) >> 16) / 255,
                  green: CGFloat((hex & 0x00ff00) >> 8) / 255,
                  blue: CGFloat((hex & 0x0000ff) >> 0) / 255,
                  alpha: alpha)
    }
    
    /// 初始化颜色
    /// - Parameter hex: argb || rgb
    convenience init(argb hexString: String) {
        let temp = hexString.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "0x", with: "")
        var hexValue: UInt32 = 0
        let scanner = Scanner(string: temp)
        if scanner.scanHexInt32(&hexValue) {
            self.init(argb: hexValue)
        }else{
            self.init(argb: 0xFFFFFF)
        }
    }
    
    /// 初始化颜色
    /// - Parameters:
    ///   - hex: rgb
    ///   - alpha: alpha
    convenience init(rgb hexString: String, alpha: CGFloat = 1) {
        let temp = hexString.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "0x", with: "")
        var hexValue: UInt32 = 0
        let scanner = Scanner(string: temp)
        if scanner.scanHexInt32(&hexValue) {
            self.init(rgb: hexValue, alpha: alpha)
        }else{
            self.init(rgb: 0xFFFFFF)
        }
    }
     
    
    /// 暗黑模式颜色
    /// - Parameters:
    ///   - light: light
    ///   - dark: dark
    /// - Returns: color
    class func `for`(light: UIColor, dark: UIColor? = nil) -> UIColor {
        if #available(iOS 13.0, *) {
            if dark == nil {
                var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
                light.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                return UIColor(dynamicProvider: { $0.userInterfaceStyle == .light ? light : UIColor(red: 1 - red, green: 1 - green, blue: 1 - blue, alpha: alpha) })
            } else {
                return UIColor(dynamicProvider: { $0.userInterfaceStyle == .light ? light : dark! })
            }
        } else {
            return light
        }
    }
    
}

public extension UIColor {
    
    private var redValue: CGFloat {
        var r: CGFloat = 0
        getRed(&r, green: nil, blue: nil, alpha: nil)
        return r
    }
    private var greenValue: CGFloat {
        var g: CGFloat = 0
        getRed(nil, green: &g, blue: nil, alpha: nil)
        return g
    }
    private var blueValue: CGFloat {
        var b: CGFloat = 0
        getRed(nil, green: nil, blue: &b, alpha: nil)
        return b
    }
    private var alphaValue: CGFloat {
        return cgColor.alpha
    }
    
    /// 过渡颜色 颜色A变化到颜色B
    /// - Parameters:
    ///   - fromColor: 起始
    ///   - toColor: 目标
    ///   - progress: 0.0 - 1.0
    /// - Returns: 过渡色
    class func fromColor(fromColor: UIColor, toColor: UIColor, progress: CGFloat) -> UIColor {
        let pgs = min(progress, 1)
        let fromRed = fromColor.redValue
        let fromGreen = fromColor.greenValue
        let fromBlue = fromColor.blueValue
        let fromAlpha = fromColor.alphaValue
        
        let toRed = toColor.redValue
        let toGreen = toColor.greenValue
        let toBlue = toColor.blueValue
        let toAlpha = toColor.alphaValue
        
        let finalRed = fromRed + (toRed - fromRed) * pgs
        let finalGreen = fromGreen + (toGreen - fromGreen) * pgs
        let finalBlue = fromBlue + (toBlue - fromBlue) * pgs
        let finalAlpha = fromAlpha + (toAlpha - fromAlpha) * pgs
        return UIColor(red: finalRed, green: finalGreen, blue: finalBlue, alpha: finalAlpha)
    }

    
}
