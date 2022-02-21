//
//  File.swift
//  
//
//  Created by HanQi on 2021/8/12.
//

import Foundation
import UIKit

public extension UIView {
    
    /// 移除所有子视图
    func removeSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 设置部分圆角（绝对布局）
    ///
    /// - Parameters:
    ///   - corners: 需要设置的角
    ///   - radii: 圆角大小
    func addRoundedCorners(_ corners: UIRectCorner, withRadii radii: CGSize) -> Void {
        let path = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: radii)
        let shap = CAShapeLayer.init()
        shap.path = path.cgPath
        self.layer.mask = shap
    }
    
    /// 设置部分圆角（相对布局）
    ///
    /// - Parameters:
    ///   - corners: 需要设置的角
    ///   - radii: 圆角大小
    func addRoundedCorners(_ corners: UIRectCorner, withRadii radii: CGSize, viewRect rect: CGRect) -> Void {
        let path = UIBezierPath.init(roundedRect: rect, byRoundingCorners: corners, cornerRadii: radii)
        let shap = CAShapeLayer.init()
        shap.path = path.cgPath
        self.layer.mask = shap
    }
    
}
