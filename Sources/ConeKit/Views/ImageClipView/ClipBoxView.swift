//
//  ClipBoxView.swift
//  ImageClipViewDemo
//
//  Created by HanQi on 2021/7/9.
//

import UIKit

protocol ClipBoxViewDelegate: NSObjectProtocol {
    func box(_ box: ClipBoxView, didSelectedRect: CGRect)
}

class ClipBoxView: UIView {
    
    let lineWrapView = UIView.init()
    
    lazy var topLeftView: UIView = {
        UIView.init(frame: .init(origin: .zero, size: .init(width: 40, height: 40)))
    }()
    lazy var topRightView: UIView = {
        UIView.init(frame: .init(origin: .zero, size: .init(width: 40, height: 40)))
    }()
    lazy var bottomLeftView: UIView = {
        UIView.init(frame: .init(origin: .zero, size: .init(width: 40, height: 40)))
    }()
    lazy var bottomRightView: UIView = {
        UIView.init(frame: .init(origin: .zero, size: .init(width: 40, height: 40)))
    }()

    var cornerEnable: Bool = true {
        didSet {
            [topLeftView, topRightView, bottomLeftView, bottomRightView].forEach { view in
                view.isUserInteractionEnabled = cornerEnable
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var isDragingCorner = false
    
    weak var delegate: ClipBoxViewDelegate?
    
    var timer: CADisplayLink?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configerViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isDragingCorner {
            lineWrapView.frame = bounds
        }
        lineWrapView.layer.sublayers?.forEach({ layer in
            if layer is CAShapeLayer {
                layer.removeFromSuperlayer()
            }
        })
        
        addBoxLayer()
        if cornerEnable {
            addPositionLayer()

            topLeftView.center = .zero
            topRightView.center = .init(x: bounds.size.width, y: 0)
            bottomLeftView.center = .init(x: 0, y: bounds.size.height)
            bottomRightView.center = .init(x: bounds.size.width, y: bounds.size.height)
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard cornerEnable else {
            return nil
        }
        let rect = bounds.inset(by: UIEdgeInsets.init(top: -20, left: -20, bottom: -20, right: -20))
        let views = [topLeftView, topRightView, bottomLeftView, bottomRightView]
        if let view = super.hitTest(point, with: event) {
            if views.contains(view) {
                return view
            }
        }
        if rect.contains(point) {
            if let view = views.first(where: { view in
                if view.bounds.contains(convert(point, to: view)) {
                    return true
                }
                return false
            }) {
                return view
            }
        }
        return nil
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = bounds.inset(by: UIEdgeInsets.init(top: -20, left: -20, bottom: -20, right: -20))
        if rect.contains(point) {
            return true
        }
        return super.point(inside: point, with: event)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragingCorner = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let viewTag = ((touches as NSSet).anyObject() as AnyObject).view?.tag
        let current = ((touches as NSSet).anyObject() as AnyObject).location(in: self.superview)
        let previous = ((touches as NSSet).anyObject() as AnyObject).previousLocation(in: self.superview)
         
        let px: CGFloat = current.x - previous.x
        let py: CGFloat = current.y - previous.y
        
        switch viewTag {
        case 1000: // topLeft
            let moveFit = abs(px) >= abs(py) ? px : py
            let x = min(max(lineWrapView.frame.origin.x + moveFit, 0), bounds.size.width * 4 / 5.0)
            let y = (bounds.height / bounds.width) * x
            
            lineWrapView.frame = .init(x: x, y: y, width: bounds.size.width - x, height: bounds.size.height - y)
        case 1001: // topRight
            let moveFit = abs(-px) >= abs(py) ? -px : py
            let width = max(min(lineWrapView.frame.width - moveFit, bounds.size.width), bounds.size.width / 5.0)
            let height = (bounds.height / bounds.width) * width
            
            lineWrapView.frame = .init(x: 0, y: bounds.size.height - height, width: width, height: height)
        case 1002: // bottomLeft
            let moveFit = abs(px) >= abs(-py) ? px : -py
            let x = min(max(lineWrapView.frame.origin.x + moveFit, 0), bounds.size.width * 4 / 5.0)
            let height = (bounds.height / bounds.width) * (bounds.width - x)
            
            lineWrapView.frame = .init(x: x, y: 0, width: bounds.width - x, height: height)
        case 1003: // bottomRight
            let moveFit = abs(-px) >= abs(-py) ? -px : -py
            let width = max(min(lineWrapView.frame.width - moveFit, bounds.width), bounds.size.width / 5.0)
            let height = (bounds.size.height / bounds.size.width) * width
            
            lineWrapView.frame = .init(x: 0, y: 0, width: width, height: height)
        default:
            break
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        initTimer()
        delegate?.box(self, didSelectedRect: convert(lineWrapView.bounds, from: lineWrapView))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        initTimer()
        delegate?.box(self, didSelectedRect: convert(lineWrapView.bounds, from: lineWrapView))
    }
    
    func initTimer() {
        isUserInteractionEnabled = false
        timer = CADisplayLink.init(target: self, selector: #selector(boxToResetFrame))
        timer?.preferredFramesPerSecond = 50
        timer?.add(to: .main, forMode: .common)
    }
    
    func invalidateTimer() {
        isUserInteractionEnabled = true
        isDragingCorner = false
        timer?.invalidate()
        timer = nil
    }
    
    @objc func boxToResetFrame() {
        let sx: CGFloat = 13.5
        let sy = (bounds.height / bounds.width) * sx
        if lineWrapView.frame.minX > 0, lineWrapView.frame.minY > 0 { // topLeft
            let x = max(lineWrapView.frame.minX - sx, 0)
            let y = max(lineWrapView.frame.minY - sy, 0)
            lineWrapView.frame = .init(x: x, y: y, width: bounds.size.width - x, height: bounds.size.height - y)
        } else if lineWrapView.frame.maxX < bounds.width, lineWrapView.frame.minY > 0 { // topRight
            let width = min(lineWrapView.frame.width + sx, bounds.size.width)
            let y = max(bounds.size.height - (lineWrapView.frame.height + sy), 0)
            lineWrapView.frame = .init(x: 0, y: y, width: width, height: bounds.size.height - y)
        } else if lineWrapView.frame.minX > 0, lineWrapView.frame.maxY < bounds.height { // bottomLeft
            let x = max(lineWrapView.frame.minX - sx, 0)
            let height = min(lineWrapView.frame.height + sy, bounds.size.height)
            lineWrapView.frame = .init(x: x, y: 0, width: bounds.size.width - x, height: height)
        } else if lineWrapView.frame.maxX < bounds.width, lineWrapView.frame.maxY < bounds.height { // bottomRight
            let width = min(lineWrapView.frame.width + sx, bounds.width)
            let height = min(lineWrapView.frame.height + sy, bounds.height)
            lineWrapView.frame = .init(x: 0, y: 0, width: width, height: height)
        } else {
            invalidateTimer()
        }
    }
    
}

extension ClipBoxView {

    func configerViews() {
        
        addSubview(lineWrapView)
        
        for (index, item) in [topLeftView, topRightView, bottomLeftView, bottomRightView].enumerated() {
            lineWrapView.addSubview(item)
            item.tag = 1000 + index
        }
    }
    
    func addBoxLayer() {
        let boxLayer = CAShapeLayer.init()
        
        let path = UIBezierPath.init(rect: lineWrapView.bounds)
        
        path.move(to: .init(x: lineWrapView.bounds.width / 3.0, y: 0))
        path.addLine(to: .init(x: lineWrapView.bounds.width / 3.0, y: lineWrapView.bounds.height))
        
        path.move(to: .init(x: lineWrapView.bounds.width * 2 / 3.0, y: 0))
        path.addLine(to: .init(x: lineWrapView.bounds.width * 2 / 3.0, y: lineWrapView.bounds.height))
        
        path.move(to: .init(x: 0, y: lineWrapView.bounds.height / 3.0))
        path.addLine(to: .init(x: lineWrapView.bounds.width, y: lineWrapView.bounds.height / 3.0))
        
        path.move(to: .init(x: 0, y: lineWrapView.bounds.height * 2 / 3.0))
        path.addLine(to: .init(x: lineWrapView.bounds.width, y: lineWrapView.bounds.height * 2 / 3.0))
        
        boxLayer.lineWidth = 1
        boxLayer.path = path.cgPath
        boxLayer.strokeColor = UIColor.white.cgColor
        boxLayer.fillColor = UIColor.clear.cgColor
         
        boxLayer.shadowColor = UIColor.black.cgColor
        boxLayer.shadowOpacity = 0.3
        boxLayer.shadowRadius = 3
        boxLayer.shadowOffset = .zero
        
        lineWrapView.layer.addSublayer(boxLayer)
    }
    
    func addPositionLayer() {
        
        let positionLong: CGFloat = 20
        let positionOffset: CGFloat = 1.5
        
        let positionLayer = CAShapeLayer.init()
        
        let path = UIBezierPath.init()
        
        path.move(to: CGPoint.init(x: -(positionOffset * 2), y: -positionOffset))
        path.addLine(to: .init(x: positionLong, y: -positionOffset))
        
        path.move(to: CGPoint.init(x: -positionOffset, y: -(positionOffset * 2)))
        path.addLine(to: .init(x: -positionOffset, y: positionLong))
        
        path.move(to: .init(x: lineWrapView.bounds.width + (positionOffset * 2), y: -positionOffset))
        path.addLine(to: .init(x: lineWrapView.bounds.width - positionLong, y: -positionOffset))
        
        path.move(to: .init(x: lineWrapView.bounds.width + positionOffset, y: -(positionOffset * 2)))
        path.addLine(to: .init(x: lineWrapView.bounds.width + positionOffset, y: positionLong))
        
        path.move(to: .init(x: -(positionOffset * 2), y: lineWrapView.bounds.height + positionOffset))
        path.addLine(to: .init(x: positionLong, y: lineWrapView.bounds.height + positionOffset))
        
        path.move(to: .init(x: -positionOffset, y: lineWrapView.bounds.height + (positionOffset * 2)))
        path.addLine(to: .init(x: -positionOffset, y: lineWrapView.bounds.height - positionLong))
        
        path.move(to: .init(x: lineWrapView.bounds.size.width + positionOffset, y: lineWrapView.bounds.size.height + (positionOffset * 2)))
        path.addLine(to: .init(x: lineWrapView.bounds.size.width + positionOffset, y: lineWrapView.bounds.size.height - positionLong))
        
        path.move(to: .init(x: lineWrapView.bounds.size.width + (positionOffset * 2), y: lineWrapView.bounds.size.height + positionOffset))
        path.addLine(to: .init(x: lineWrapView.bounds.size.width - positionLong, y: lineWrapView.bounds.size.height + positionOffset))
        
        positionLayer.lineWidth = 3
        positionLayer.path = path.cgPath
        positionLayer.strokeColor = UIColor.white.cgColor
        
        positionLayer.shadowColor = UIColor.black.cgColor
        positionLayer.shadowOpacity = 0.2
        positionLayer.shadowRadius = 3
        positionLayer.shadowOffset = .zero
        
        lineWrapView.layer.addSublayer(positionLayer)
        
    }

}
