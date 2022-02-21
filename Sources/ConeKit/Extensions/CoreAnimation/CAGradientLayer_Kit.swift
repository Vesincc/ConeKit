//
//  File.swift
//  
//
//  Created by HanQi on 2021/8/12.
//

import Foundation
import UIKit

public extension CAGradientLayer {
    
    enum GradientDirection {
        case horizontal
        case vertical
    }
    
    convenience init(colors: [UIColor],
                     locations: [CGFloat]? = nil,
                     startPoint: CGPoint = CGPoint(x: 0, y: 0.5),
                     endPoint: CGPoint = CGPoint(x: 1, y: 0.5)) {
        self.init()
        self.colors = colors.map(\.cgColor)
        self.locations = locations?.map { NSNumber(value: Double($0)) }
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    convenience init(colors: [UIColor],
                     direction: GradientDirection = .horizontal) {
        
        var start = CGPoint(x: 0, y: 0.5)
        var end = CGPoint(x: 1, y: 0.5)
        if direction == .vertical {
            start = CGPoint.init(x: 0.5, y: 0)
            end = CGPoint.init(x: 0.5, y: 1)
        }
        self.init(colors: colors,
                  startPoint: start,
                  endPoint: end)
    }
    
}
