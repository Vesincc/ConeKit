//
//  String_Kit.swift
//  MyKit
//
//  Created by HanQi on 2021/3/23.
//

import Foundation
import UIKit

public extension String {
    
    subscript(offset: Int) -> Character {
        get {
            return self[index(startIndex, offsetBy: offset)]
        }
        set {
            replaceSubrange(index(startIndex, offsetBy: offset)..<index(startIndex, offsetBy: offset + 1), with: [newValue])
        }
    }
    
    subscript(range: CountableRange<Int>) -> String {
        get {
            return String(self[index(startIndex, offsetBy: range.lowerBound)..<index(startIndex, offsetBy: range.upperBound)])
        }
        set {
            replaceSubrange(index(startIndex, offsetBy: range.lowerBound)..<index(startIndex, offsetBy: range.upperBound), with: newValue)
        }
    }
    
    subscript(location: Int, length: Int) -> String {
        get {
            return String(self[index(startIndex, offsetBy: location)..<index(startIndex, offsetBy: location + length)])
        }
        set {
            replaceSubrange(index(startIndex, offsetBy: location)..<index(startIndex, offsetBy: location + length), with: newValue)
        }
    }
    
}

public extension String {
    
    /// 创建随机字符串
    /// - Parameter length: 长度
    /// - Returns: 字符串
    static func random(with length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var ranStr = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(characters.count)))
            ranStr.append(characters[index])
        }
        return ranStr
    }
    
    static func randomNumberString(with length: Int) -> String {
        let characters = "0123456789"
        var ranStr = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(characters.count)))
            if ranStr.isEmpty {
                if characters[index] != "0" {
                    ranStr.append(characters[index])
                }
            } else {
                ranStr.append(characters[index])
            }
        }
        if ranStr.isEmpty {
            return randomNumberString(with: length)
        }
        return ranStr
    }
    
    /// range转换为NSRange
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
    /// 验证正则表达式
    /// - Parameter regular: 规则
    /// - Returns: 结果 true 正确
    func verification(with regular: String) -> Bool {
        let regularExpression = try? NSRegularExpression(pattern: regular, options: .caseInsensitive)
        let matchs = regularExpression?.matches(in: self, options: .reportProgress, range: NSRange(location: 0, length: count))
        if let count = matchs?.count, count != 0 {
            return true
        }
        return false
    }
    
    /// 是否有Emoji true 有
    var containEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F,
                 0x1F300...0x1F5FF,
                 0x1F680...0x1F6FF,
                 0x1F1E6...0x1F1FF,
                 0x2600...0x26FF,
                 0x2700...0x27BF,
                 0xE0020...0xE007F,
                 0xFE00...0xFE0F,
                 0x1F900...0x1F9FF,
                 127_000...127_600,
                 65024...65039,
                 9100...9300,
                 8400...8447:
                return true
            default:
                continue
            }
        }
        return false
    }
    
}

public extension String {
    
    /// 不换行 获取文本宽度
    /// - Parameter font: font
    /// - Returns: width
    func width(with font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font : font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect: CGRect = NSString.init(string: self).boundingRect(with: .init(width: CGFloat.init(MAXFLOAT), height: CGFloat.init(MAXFLOAT)), options: option, attributes: attributes, context: nil)
        return ceil(rect.width)
    }
    
    /// 获取文本高度
    /// - Parameters:
    ///   - font: font
    ///   - maxWidth: 最大宽度
    /// - Returns: height
    func height(with font: UIFont, and maxWidth: CGFloat) -> CGFloat {
        let attributes = [NSAttributedString.Key.font : font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect: CGRect = NSString.init(string: self).boundingRect(with: .init(width: maxWidth, height: CGFloat.init(MAXFLOAT)), options: option, attributes: attributes, context: nil)
        return ceil(rect.height)
    }
    
    /// 计算文字所占用size
    /// - Parameters:
    ///   - constrainedSize: 目标大小
    ///   - font: 字体
    ///   - lineSpacing: 行间距
    /// - Returns: 计算所得大小
    func boundingRect(with constrainedSize: CGSize, font: UIFont, lineSpacing: CGFloat? = nil) -> CGSize {
        let attritube = NSMutableAttributedString(string: self)
        let range = NSRange(location: 0, length: attritube.length)
        attritube.addAttributes([NSAttributedString.Key.font: font], range: range)
        if lineSpacing != nil {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing!
            attritube.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        }
        
        let rect = attritube.boundingRect(with: constrainedSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        var size = rect.size
        if let currentLineSpacing = lineSpacing {
            let spacing = size.height - font.lineHeight
            if spacing <= currentLineSpacing && spacing > 0 {
                size = CGSize(width: size.width, height: font.lineHeight)
            }
        }
        return size
    }
}

public extension String {
    var isEmail: Bool {
        let regex = "^[A-Z0-9a-z._-]+(@{1})[A-Za-z0-9.-_]+\\.[A-Za-z0-9]+$"
        let pre = NSPredicate(format: "SELF MATCHES %@", regex)
        return pre.evaluate(with: self)
    }
}


public extension String {
    
    func localize() -> String {
        NSLocalizedString(self, comment: "")
    }
    
    func localize(_ value: String) -> String {
        String(format: localize(), value)
    }
    
    func localize(_ value: Int) -> String {
        String(format: localize(), value)
    }
    
    func localize(_ value1: String,_ value2: String) -> String {
        String(format: localize(), value1, value2)
    }
}

public extension Array where Element == String {
    
    func merge(with str: String) -> String {
        var res = ""
        forEach { s in
            if !s.isEmpty {
                if res.isEmpty {
                    res = s
                } else {
                    res.append(contentsOf: "\(str)\(s)")
                }
            }
        }
        return res
    }
    
    var firstNotEmpty: String? {
        first(where: { !$0.isEmpty })
    }
    
}
