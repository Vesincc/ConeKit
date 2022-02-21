//
//  ClipDisplayView.swift
//  ImageClipViewDemo
//
//  Created by HanQi on 2021/7/9.
//

import UIKit

public enum RotateType {
    case clockwise90
    case counterclockwise90
}

class ClipDisplayView: UIView {
    
    var angle: Double = 0
    var isRotating = false
    
    var optionImage: UIImage! {
        didSet {
            imageView.image = optionImage
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    let scrollView = UIScrollView.init()
    let imageView = UIImageView.init()
    
    let borderView = ClipBoxView.init()
    
    var aniNumber: NSNumber = NSNumber(floatLiteral: 0.5)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configerViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
          
        resetImage(animation: true)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event) {
            return view
        } 
        return scrollView
    }
    
}

extension ClipDisplayView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.scrollView.setZoomScale(scale, animated: false)
    }
    
}

extension ClipDisplayView: ClipBoxViewDelegate {
    func box(_ box: ClipBoxView, didSelectedRect: CGRect) {
        let rect = borderView.convert(didSelectedRect, to: imageView)
        scrollView.zoom(to: rect, animated: true)
    }
}

extension ClipDisplayView {
    
    func configerViews() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 10
        scrollView.zoomScale = 1
        scrollView.decelerationRate = .fast
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.layer.masksToBounds = false
        
        addSubview(scrollView)
        
        borderView.delegate = self
        addSubview(borderView)
        
        scrollView.addSubview(imageView)
        
        imageView.image = optionImage
    }
    
    func resetImage(animation: Bool) {
        if !isRotating {
            isUserInteractionEnabled = false
            borderView.isUserInteractionEnabled = false
            scrollView.setZoomScale(1, animated: false)
            scrollView.contentOffset = .zero
            scrollView.frame = bounds
            borderView.frame = bounds
            imageView.frame = imageFitFrame()
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(animationWithLargeImage(duration:)), object: aniNumber)
            if animation {
                self.perform(#selector(animationWithLargeImage(duration:)), with: aniNumber, afterDelay: 0.5)
            } else {
                animationWithLargeImage(duration: 0)
            }
        }
    }
    
    @objc func animationWithLargeImage(duration: NSNumber) {
        UIView.animate(withDuration: duration.doubleValue) {
            self.imageView.frame = self.imageFillFrame()
        } completion: { isFinish in
            if isFinish {
                self.scrollView.contentSize = self.imageFillFrame().size
                self.imageView.frame = .init(origin: .zero, size: self.imageFillFrame().size)
                self.scrollView.contentOffset = .init(x: (self.imageFillFrame().size.width - self.scrollView.bounds.width) / 2.0, y: (self.imageFillFrame().size.height - self.scrollView.bounds.size.height) / 2.0)
                self.isUserInteractionEnabled = true
                self.borderView.isUserInteractionEnabled = true
            }
        }
    }
    
    func imageFitFrame() -> CGRect {
        
        let imageScale = optionImage.size.width / optionImage.size.height
        
        if imageScale <= 0 {
            assertionFailure("图片设置错误")
        }
        
        var contentWidth = bounds.size.width
        var contentHeight = bounds.size.height
        if Int(angle / (Double.pi / 2.0)) % 2 != 0 {
            contentWidth = bounds.size.height
            contentHeight = bounds.size.width
        }
        
        let contentScale = contentWidth / contentHeight
        
        var displayWidth: CGFloat = 0
        var displayHeight: CGFloat = 0
        
        let min = min(contentWidth, contentHeight)
        let max = max(contentWidth, contentHeight)
        
        if contentScale <= 1 {
            if contentScale < imageScale {
                displayWidth = min
                displayHeight = displayWidth / imageScale
            } else {
                displayHeight = max
                displayWidth = displayHeight * imageScale
            }
        } else {
            if contentScale < imageScale {
                displayWidth = max
                displayHeight = displayWidth / imageScale
            } else {
                displayHeight = min
                displayWidth = displayHeight * imageScale
            }
        }
        
        return .init(origin: .init(x: contentWidth / 2.0 - displayWidth / 2.0, y: contentHeight / 2.0 - displayHeight / 2.0), size: .init(width: displayWidth, height: displayHeight))
         
    }
    
    func imageFillFrame() -> CGRect {
        let imageScale = optionImage.size.width / optionImage.size.height
        
        if imageScale <= 0 {
            assertionFailure("图片设置错误")
        }
        
        var contentWidth = bounds.size.width
        var contentHeight = bounds.size.height
        if Int(angle / (Double.pi / 2.0)) % 2 != 0 {
            contentWidth = bounds.size.height
            contentHeight = bounds.size.width
        }
        
        let contentScale = contentWidth / contentHeight
        
        var displayWidth: CGFloat = 0
        var displayHeight: CGFloat = 0
        
        let min = min(contentWidth, contentHeight)
        let max = max(contentWidth, contentHeight)
        
        if contentScale <= 1 {
            if contentScale < imageScale {
                displayHeight = max
                displayWidth = displayHeight * imageScale
            } else {
                displayWidth = min
                displayHeight = displayWidth / imageScale
            }
        } else {
            if contentScale < imageScale {
                displayHeight = min
                displayWidth = displayHeight * imageScale
            } else {
                displayWidth = max
                displayHeight = displayWidth / imageScale
            }
        }
        
        return .init(origin: .init(x: contentWidth / 2.0 - displayWidth / 2.0, y: contentHeight / 2.0 - displayHeight / 2.0), size: .init(width: displayWidth, height: displayHeight))
    }
    
}


extension ClipDisplayView {
    
    func displayRotate(_ type: RotateType) {
        angle += type == .clockwise90 ? (Double.pi / 2.0) : (-Double.pi / 2.0)
        if bounds.width == bounds.height {
            isRotating = true
        }
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.scrollView.transform = CGAffineTransform.init(rotationAngle: CGFloat(self.angle))
        } completion: { isFinish in
            if isFinish {
                self.isRotating = false
                self.isUserInteractionEnabled = true
            }
        }

    }
    
    func resetDisplay() {
        scrollView.transform = .identity
        angle = 0
        resetImage(animation: true)
    }
    
    func canResponseAction() -> Bool {
        if scrollView.isDragging || scrollView.isDecelerating || scrollView.isZoomBouncing || scrollView.isTracking || borderView.isDragingCorner || isRotating {
            return false
        } else {
            return true
        }
    }
    
    func getClipOriginalImage() -> UIImage {
        let width = (scrollView.frame.width / imageView.frame.width) * optionImage.size.width
        let height = (scrollView.frame.size.height / scrollView.frame.size.width) * width
        
        var x = (scrollView.contentOffset.x / imageView.frame.size.width) * optionImage.size.width
        var y = (scrollView.contentOffset.y / imageView.frame.size.height) * optionImage.size.height

        var clipRect = CGRect.zero
        let times = Int(angle / (.pi/2.0))
        if times % 2 == 0 {
            if x + width >= optionImage.size.width {
                x = optionImage.size.width - width
            }
            if y + height >= optionImage.size.height {
                y = optionImage.size.height - height
            }
            clipRect = .init(x: x, y: y, width: width, height: height)
        } else {
            if x + height >= optionImage.size.width {
                x = optionImage.size.width - height
            }
            if y + width >= optionImage.size.height {
                y = optionImage.size.height - width
            }
            clipRect = .init(x: x, y: y, width: height, height: width)
        }
        
        if let temp = optionImage.cgImage?.cropping(to: clipRect) {
            let result = UIImage.init(cgImage: temp)
            return rotateImage(result, angle: angle)
        } else {
            return .init()
        }
    }
    
    func getCaptureImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return .init()
        }
        let borderViewIsHidden = borderView.isHidden
        if !borderViewIsHidden {
            borderView.isHidden = true
        }
        layer.render(in: context)
        borderView.isHidden = borderViewIsHidden
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return viewImage ?? .init()
    }
    
    func rotateImage(_ image: UIImage, angle: Double) -> UIImage {
        let times = Int(angle / (.pi/2.0))
        guard let cgImage = image.cgImage else {
            return image
        }
        switch times % 4 {
        case 0:
            return image
        case 3, -1:
            return UIImage.init(cgImage: cgImage, scale: image.scale, orientation: .left)
        case 2, -2:
            return UIImage.init(cgImage: cgImage, scale: image.scale, orientation: .down)
        case 1, -3:
            return UIImage.init(cgImage: cgImage, scale: image.scale, orientation: .right)
        default:
            return image
        }
    }
}
