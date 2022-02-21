//
//  GradientView.swift
//  
//
//  Created by HanQi on 2021/8/19.
//

import Foundation
import UIKit

public class GradientView: UIView {
    
    public override class var layerClass: AnyClass {
        CAGradientLayer.classForCoder()
    }
    
    @IBInspectable public var startColor: UIColor?
    @IBInspectable public var endColor: UIColor?
    @IBInspectable var isHorizontalColor: Bool = true
    
    public var startPoint: CGPoint?
    public var endPoint: CGPoint?
    
    public var locations: [NSNumber]?
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let gl = layer as? CAGradientLayer,
              let start = startColor, let end = endColor else {
            return
        }
        gl.colors = [start, end].map({ $0.cgColor })
        gl.locations = locations ?? [0, 1]
        
        if let startPoint = startPoint, let endPoint = endPoint {
            gl.startPoint = startPoint
            gl.endPoint = endPoint
        } else {
            if isHorizontalColor {
                gl.startPoint = CGPoint(x: 0, y: 0.5)
                gl.endPoint = CGPoint(x: 1, y: 0.5)
            } else {
                gl.startPoint = CGPoint.init(x: 0.5, y: 0)
                gl.endPoint = CGPoint.init(x: 0.5, y: 1)
            }
        }

    }
    
}
