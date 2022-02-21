//
//  File.swift
//  
//
//  Created by HanQi on 2021/8/23.
//

import Foundation
import UIKit

fileprivate enum NormalPopoverHelperStatic {
    static let helper = NormalPopoverHelper()
    
    class NormalPopoverHelper: NSObject, UIPopoverPresentationControllerDelegate {
        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            .none
        }
    }
}

public protocol NormalPopoverProtocol : UIViewController {
    
    func popover(present: UIViewController?, sourceView: UIView, contentSize: CGSize?, arrowDirections: UIPopoverArrowDirection, animated flag: Bool, completion: (() -> Void)?)
}
 
public extension NormalPopoverProtocol {
     
    func popover(present: UIViewController?, sourceView: UIView, contentSize: CGSize? = nil, arrowDirections: UIPopoverArrowDirection = .up, animated flag: Bool = true, completion: (() -> Void)? = nil) {
        
        modalPresentationStyle = .popover
        if let size = contentSize {
            preferredContentSize = size
        } else {
            let sizeFite = view.systemLayoutSizeFitting(CGSize(width: kScreenWidth, height: kScreenHeight))
            preferredContentSize = CGSize(width: max(44, sizeFite.width), height: max(44, sizeFite.height))
        }
        popoverPresentationController?.popoverBackgroundViewClass = PopoverBackgroundView.self
        popoverPresentationController?.delegate = NormalPopoverHelperStatic.helper
        popoverPresentationController?.permittedArrowDirections = arrowDirections
        popoverPresentationController?.canOverlapSourceViewRect = false
        
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = CGRect(origin: .zero, size: sourceView.bounds.size)
        present?.present(self, animated: flag, completion: completion)
    }
     
}
 
 
class PopoverBackgroundView: UIPopoverBackgroundView {
    
    override class func arrowHeight() -> CGFloat {
        0
    }
    
    override class func arrowBase() -> CGFloat {
        10
    }
    
    override class func contentViewInsets() -> UIEdgeInsets {
        UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
    
    class func borderWidth() -> CGFloat {
        0.5
    }
    
    class func borderColor() -> UIColor {
        .init(rgb: 0xDFDFDF)
    }
    
    class func backgroundColor() -> UIColor {
        .white
    }
    
    class func cornerRadius() -> CGFloat {
        8
    }
     
    override class var layerClass: AnyClass {
        CAShapeLayer.self
    }
    
    var arrowDirectionValue: UIPopoverArrowDirection = .any
    override var arrowDirection: UIPopoverArrowDirection {
        get {
            arrowDirectionValue
        }
        set {
            arrowDirectionValue = newValue
        }
    }
    
    var arrowOffsetValue: CGFloat = .zero
    override var arrowOffset: CGFloat {
        get {
            arrowOffsetValue
        }
        set {
            arrowOffsetValue = newValue
        }
    }
    
    override func layoutSubviews() {
        superview?.subviews.filter({ $0 != self }).forEach({ view in
            view.cornerRadius = PopoverBackgroundView.cornerRadius()
        })
        drawBackground()
    }
    
}

extension PopoverBackgroundView {
    
    func drawBackground() {
        guard let layer = layer as? CAShapeLayer else {
            return
        }
        
        let cornerRadius = PopoverBackgroundView.cornerRadius()
        
        layer.lineWidth = PopoverBackgroundView.borderWidth()
        layer.strokeColor = PopoverBackgroundView.borderColor().cgColor
        layer.fillColor = PopoverBackgroundView.backgroundColor().cgColor
         
        let arrowSize = CGSize(width: PopoverBackgroundView.arrowBase(), height: PopoverBackgroundView.arrowHeight())
        let hasArrow = min(arrowSize.width, arrowSize.height) > 0
        
        switch arrowDirection {
        case .up:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: cornerRadius, y: arrowSize.height))
            if hasArrow {
                path.addLine(to: CGPoint(x: bounds.width / 2 + arrowOffset - arrowSize.width / 2, y: arrowSize.height))
                path.addLine(to: CGPoint(x: bounds.width / 2 + arrowOffset, y: 0))
                path.addLine(to: CGPoint(x: bounds.width / 2 + arrowOffset + arrowSize.width / 2, y: arrowSize.height))
            }
            path.addLine(to: CGPoint(x: bounds.width - cornerRadius, y: arrowSize.height))
            path.addArc(withCenter: CGPoint(x: bounds.width - cornerRadius, y: arrowSize.height + cornerRadius), radius: cornerRadius, startAngle: .pi * 3 / 2, endAngle: 0, clockwise: true)
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - cornerRadius))
            path.addArc(withCenter: CGPoint(x: bounds.width - cornerRadius, y: bounds.maxY - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: .pi / 2, clockwise: true)
            path.addLine(to: CGPoint(x: cornerRadius, y: bounds.maxY))
            path.addArc(withCenter: CGPoint(x: cornerRadius, y: bounds.maxY - cornerRadius), radius: cornerRadius, startAngle: .pi / 2, endAngle: .pi, clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: arrowSize.height + cornerRadius))
            path.addArc(withCenter: CGPoint(x: cornerRadius, y: arrowSize.height + cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: .pi * 3 / 2, clockwise: true)
            path.close()
            layer.path = path.cgPath
        case .down:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: cornerRadius, y: 0))
            path.addLine(to: CGPoint(x: bounds.width - cornerRadius, y: 0))
            path.addArc(withCenter: CGPoint(x: bounds.width - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .pi * 3 / 2, endAngle: 0, clockwise: true)
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - cornerRadius - arrowSize.height))
            path.addArc(withCenter: CGPoint(x: bounds.width - cornerRadius, y: bounds.maxY - arrowSize.height - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: .pi / 2, clockwise: true)
            if hasArrow {
                path.addLine(to: CGPoint(x: bounds.width / 2 + arrowOffset + arrowSize.width / 2, y: bounds.maxY - arrowSize.height))
                path.addLine(to: CGPoint(x: bounds.width / 2 + arrowOffset, y: bounds.maxY))
                path.addLine(to: CGPoint(x: bounds.width / 2 + arrowOffset - arrowSize.width / 2, y: bounds.maxY - arrowSize.height))
            }
            path.addLine(to: CGPoint(x: cornerRadius, y: bounds.maxY - arrowSize.height))
            path.addArc(withCenter: CGPoint(x: cornerRadius, y: bounds.maxY - cornerRadius - arrowSize.height), radius: cornerRadius, startAngle: .pi / 2, endAngle: .pi, clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: cornerRadius))
            path.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: .pi * 3 / 2, clockwise: true)
            path.close()
            layer.path = path.cgPath
        case .left:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: arrowSize.height + cornerRadius, y: 0))
            path.addLine(to: CGPoint(x: bounds.maxX - cornerRadius, y: 0))
            path.addArc(withCenter: CGPoint(x: bounds.maxX - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .pi * 3 / 2, endAngle: 0, clockwise: true)
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - cornerRadius))
            path.addArc(withCenter: CGPoint(x: bounds.width - cornerRadius, y: bounds.maxY - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: .pi / 2, clockwise: true)
            path.addLine(to: CGPoint(x: arrowSize.height + cornerRadius, y: bounds.maxY))
            path.addArc(withCenter: CGPoint(x: arrowSize.height + cornerRadius, y: bounds.maxY - cornerRadius), radius: cornerRadius, startAngle: .pi / 2, endAngle: .pi, clockwise: true)
            if hasArrow {
                path.addLine(to: CGPoint(x: arrowSize.height, y: bounds.height / 2 + arrowOffset + arrowSize.width / 2))
                path.addLine(to: CGPoint(x: 0, y: bounds.height / 2 - arrowOffset))
                path.addLine(to: CGPoint(x: arrowSize.height, y: bounds.height / 2 + arrowOffset - arrowSize.width / 2))
            }
            path.addLine(to: CGPoint(x: arrowSize.height, y: cornerRadius))
            path.addArc(withCenter: CGPoint(x: arrowSize.height + cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: .pi * 3 / 2, clockwise: true)
            path.close()
            layer.path = path.cgPath
        case .right:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: cornerRadius, y: 0))
            path.addLine(to: CGPoint(x: bounds.maxX - cornerRadius - arrowSize.height, y: 0))
            path.addArc(withCenter: CGPoint(x: bounds.maxX - cornerRadius - arrowSize.height, y: cornerRadius), radius: cornerRadius, startAngle: .pi * 3 / 2, endAngle: 0, clockwise: true)
            if hasArrow {
                path.addLine(to: CGPoint(x: bounds.maxX - arrowSize.height, y: bounds.height / 2 + arrowOffset - arrowSize.width / 2))
                path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.height / 2 - arrowOffset))
                path.addLine(to: CGPoint(x: bounds.maxX - arrowSize.height, y: bounds.height / 2 + arrowOffset + arrowSize.width / 2))
            }
            path.addLine(to: CGPoint(x: bounds.maxX - arrowSize.height, y: bounds.maxY - cornerRadius))
            path.addArc(withCenter: CGPoint(x: bounds.width - cornerRadius - arrowSize.height, y: bounds.maxY - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: .pi / 2, clockwise: true)
            path.addLine(to: CGPoint(x: cornerRadius, y: bounds.maxY))
            path.addArc(withCenter: CGPoint(x: cornerRadius, y: bounds.maxY - cornerRadius), radius: cornerRadius, startAngle: .pi / 2, endAngle: .pi, clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: cornerRadius))
            path.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: .pi * 3 / 2, clockwise: true)
            path.close()
            layer.path = path.cgPath
        default:
            fatalError("必须设置箭头方向")
        }
    }
    
}
