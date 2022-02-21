//
//  File.swift
//  
//
//  Created by HanQi on 2021/8/12.
//

import Foundation
import UIKit

public extension UIImageView {
    
    enum LineDirection {
        case vertical
        case horizontal
    }
    
    /// imageView设置虚线图片
    /// - Parameters:
    ///   - color: 颜色
    ///   - offset: 头部偏移
    ///   - lineLength: 虚线长度
    ///   - spacing: 虚线间隔长度
    ///   - direction: 方向
    func dashLineImage(_ color: UIColor, offset: CGFloat = 0, lineLength: CGFloat = 3, spacing: CGFloat = 3, direction: LineDirection) {
        
        UIGraphicsBeginImageContext(bounds.size)
        let line = UIGraphicsGetCurrentContext()
        let lenghts = [lineLength, spacing]
        
        line?.setStrokeColor(color.cgColor)
        line?.setLineDash(phase: 0, lengths: lenghts)
        
        var startPoint: CGPoint = .zero
        var endPoint: CGPoint = .zero
        
        switch direction {
        case .vertical:
            line?.setLineWidth(bounds.width)
            startPoint = .init(x: bounds.width / 2.0, y: offset)
            endPoint = .init(x: bounds.width / 2.0, y: bounds.height)
        case .horizontal:
            line?.setLineWidth(bounds.height)
            startPoint = .init(x: offset, y: bounds.height / 2.0)
            endPoint = .init(x: bounds.width, y: bounds.height / 2.0)
        }
        
        line?.move(to: startPoint)
        line?.addLine(to: endPoint)
        line?.strokePath()
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
}
