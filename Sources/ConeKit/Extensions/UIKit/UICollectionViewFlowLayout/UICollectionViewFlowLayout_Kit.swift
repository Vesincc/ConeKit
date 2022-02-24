//
//  File.swift
//  
//
//  Created by HanQi on 2022/2/24.
//

import Foundation
import UIKit

public extension UICollectionViewFlowLayout {
    
    /// 私有方法设置对齐方式
    /// - Parameters:
    ///   - commonRowHorizontal: 水平对齐方式
    ///   - lastRowHorizontal: 当前行最后一个cell的对齐方式
    ///   - rowVertical: 垂直对齐方式
    func alignment(commonRowHorizontal: NSTextAlignment = .left, lastRowHorizontal: NSTextAlignment = .left, rowVertical: NSTextAlignment = .center) {
        let sel = Selector(("_setRowAlignmentsOptions:"))
        if responds(to: sel) {
            perform(sel, with: NSDictionary(dictionary: [
                "UIFlowLayoutCommonRowHorizontalAlignmentKey" : NSNumber(value: commonRowHorizontal.rawValue),
                "UIFlowLayoutLastRowHorizontalAlignmentKey" : NSNumber(value: lastRowHorizontal.rawValue),
                "UIFlowLayoutRowVerticalAlignmentKey" : NSNumber(value: rowVertical.rawValue)
            ]))
        }
    }
    
}
