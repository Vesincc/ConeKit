//
//  ImageClipView.swift
//  ImageClipViewDemo
//
//  Created by HanQi on 2021/7/9.
//

import UIKit

public class ImageClipView: UIView {
    
    public var clipScale: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    public var edgeInsets = UIEdgeInsets.init(top: 30, left: 30, bottom: 30, right: 30) {
        didSet {
            setNeedsLayout() 
        }
    }
    public var image: UIImage! {
        get {
            displayView.optionImage
        }
        set {
            displayView.optionImage = newValue
            setNeedsLayout()
        }
    }
    public var isCornerEnable: Bool {
        get {
            displayView.borderView.cornerEnable
        }
        set {
            displayView.borderView.cornerEnable = newValue
        }
    }
    
    let contentView = UIView.init()
    let displayView = ClipDisplayView.init()
    
    var canActionDate: TimeInterval = 0
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configerViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = bounds.inset(by: edgeInsets)
        updateDisplayViewPosition()
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event) {
            if displayView.borderView.point(inside: convert(point, to: displayView.borderView), with: event) {
                return displayView.borderView.hitTest(convert(point, to: displayView.borderView), with: event) ?? displayView.scrollView
            } else {
                return view == self ? displayView.scrollView : view
            } 
        }
        return nil
    }

}

private extension ImageClipView {
    
    func configerViews() {
        
        addSubview(contentView)
         
        contentView.addSubview(displayView)
        
    }
    
    func updateDisplayViewPosition() {
        
        if clipScale <= 0 {
            assertionFailure("比例设置错误")
        }
        
        var displayWidth: CGFloat = 0
        var displayHeight: CGFloat = 0
        
        let contentWidth = contentView.bounds.size.width
        let contentHeight = contentView.bounds.size.height
        
        let contentScale = contentWidth / contentHeight
        
        let max = max(contentWidth, contentHeight)
        let min = min(contentWidth, contentHeight)
        
        if contentScale <= 1 {
            if contentScale < clipScale {
                displayWidth = min
                displayHeight = displayWidth / clipScale
            } else {
                displayHeight = max
                displayWidth = displayHeight * clipScale
            }
        } else {
            if contentScale < clipScale {
                displayWidth = max
                displayHeight = displayWidth / clipScale
            } else {
                displayHeight = min
                displayWidth = displayHeight * clipScale
            }
        }
        
        displayView.frame = .init(origin: .init(x: contentWidth / 2.0 - displayWidth / 2.0, y: contentHeight / 2.0 - displayHeight / 2.0), size: .init(width: displayWidth, height: displayHeight))
    }
    
}

public extension ImageClipView {
    
    func imageRotate(_ type: RotateType) {
        guard Date.init().timeIntervalSince1970 - canActionDate >= 0, displayView.canResponseAction() else {
            return
        }
        if clipScale == 1 {
            canActionDate = Date.init().timeIntervalSince1970 + 0.5
        } else {
            canActionDate = Date.init().timeIntervalSince1970 + 1
        }
        displayView.displayRotate(type)
    }
    
    func imageReset() {
        guard Date.init().timeIntervalSince1970 - canActionDate >= 0, displayView.canResponseAction() else {
            return
        }
        canActionDate = Date.init().timeIntervalSince1970 + 1.5
        displayView.resetDisplay()
    }
    
    func clipOriginImage() -> UIImage? {
        guard Date.init().timeIntervalSince1970 - canActionDate >= 0, displayView.canResponseAction() else {
            return nil
        }
        return displayView.getClipOriginalImage()
    }
    
    func clipShotImage() -> UIImage? {
        guard Date.init().timeIntervalSince1970 - canActionDate >= 0, displayView.canResponseAction() else {
            return nil
        }
        return displayView.getCaptureImage()
    }
    
}
