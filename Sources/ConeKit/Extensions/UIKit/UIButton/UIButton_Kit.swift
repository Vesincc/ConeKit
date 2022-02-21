//
//  File.swift
//  
//
//  Created by HanQi on 2021/8/12.
//

import Foundation
import UIKit

public extension UIButton {
    
    /// 文字添加下划线
    /// - Parameter text: text
    func withUnderLine(_ text: String? = nil) {
        if let text = text ?? titleLabel?.text, let font = titleLabel?.font {
            let attributedString = NSMutableAttributedString.init(string: text, attributes: [
                NSAttributedString.Key.foregroundColor : currentTitleColor,
                NSAttributedString.Key.font : font,
                NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue
            ])
            titleLabel?.attributedText = attributedString
        } else if let text = titleLabel?.attributedText {
            let attributedString = NSMutableAttributedString.init(attributedString: text)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
            titleLabel?.attributedText = attributedString
        }
    }
    
    /// 去除下划线
    /// - Parameter text: text
    func clearUnderLine(_ text: String? = nil) {
        titleLabel?.attributedText = nil
        if let text = text ?? titleLabel?.text {
            titleLabel?.text = text
        }
    }
    
}
