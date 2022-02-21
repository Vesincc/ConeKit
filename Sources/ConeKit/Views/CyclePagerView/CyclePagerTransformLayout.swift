//
//  CyclePagerTransformLayout.swift
//  CaptionsKit
//
//  Created by HanQi on 2021/6/2.
//

import Foundation
import UIKit

fileprivate struct DelegateFlags {
    
    var applyTransformToAttributes = false
    var initializeTransformAttributes = false
    
    mutating func loadFlags(_ delegate: CyclePagerTransformLayoutDelegate?) {
        if let delegate = delegate {
            applyTransformToAttributes = delegate.responds(to: #selector(CyclePagerTransformLayoutDelegate.pagerTransformLayout(_:applyTransformToAttributes:)))
            initializeTransformAttributes = delegate.responds(to: #selector(CyclePagerTransformLayoutDelegate.pagerTransformLayout(_:initializeTransformAttributes:)))
        }
    }
}

// MARK: - Layout
class CyclePagerTransformLayout: UICollectionViewFlowLayout {
    
    var layoutConfig: CyclePagerLayoutConfig! {
        didSet {
            layoutConfig.layout = self
            itemSize = layoutConfig.itemSize
            minimumLineSpacing = layoutConfig.itemSpacing
            minimumInteritemSpacing = layoutConfig.itemSpacing
            scrollDirection = layoutConfig.scrollDirection
        }
    }
    
    weak var delegate: CyclePagerTransformLayoutDelegate? {
        didSet {
            delegateFlags.loadFlags(delegate)
        }
    }
    
    private var delegateFlags = DelegateFlags.init()
    
    public init(with config: CyclePagerLayoutConfig) {
        super.init()
        layoutConfig = config
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var itemSize: CGSize {
        get { layoutConfig == nil ? super.itemSize : layoutConfig.itemSize }
        set { super.itemSize = newValue }
    }
    
    override var minimumLineSpacing: CGFloat {
        get { layoutConfig == nil ? super.minimumLineSpacing : layoutConfig.itemSpacing }
        set { super.minimumLineSpacing = newValue }
    }
    
    override var minimumInteritemSpacing: CGFloat {
        get { layoutConfig == nil ? super.minimumInteritemSpacing : layoutConfig.itemSpacing }
        set { super.minimumInteritemSpacing = newValue }
    }
    
}

extension CyclePagerTransformLayout {
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        layoutConfig.layoutStyle == .normal ? super.shouldInvalidateLayout(forBoundsChange: newBounds) : true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if delegateFlags.applyTransformToAttributes || layoutConfig.layoutStyle != .normal {
            let array = super.layoutAttributesForElements(in: rect) ?? []
            let attributesArray = NSArray.init(array: array, copyItems: true) as? [UICollectionViewLayoutAttributes] ?? []
            let visibleRect = CGRect.init(origin: collectionView?.contentOffset ?? .zero, size: collectionView?.bounds.size ?? .zero)
            for var attributes in attributesArray {
                if !visibleRect.intersects(attributes.frame) {
                    continue
                }
                if delegateFlags.applyTransformToAttributes {
                    delegate?.pagerTransformLayout?(self, applyTransformToAttributes: attributes)
                } else {
                    applyTransform(to: &attributes, with: layoutConfig.layoutStyle)
                }
            }
            return attributesArray
        }
        return super.layoutAttributesForElements(in: rect)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes ?? .init()
        if delegateFlags.initializeTransformAttributes {
            delegate?.pagerTransformLayout?(self, initializeTransformAttributes: attributes)
        } else if layoutConfig.layoutStyle != .normal {
            initializeTransform(to: &attributes, with: layoutConfig.layoutStyle)
        }
        return attributes
    }
    
}

extension CyclePagerTransformLayout {
    
    private func initializeTransform(to attributes: inout UICollectionViewLayoutAttributes, with style: CyclePagerLayoutConfig.LayoutStyle) {
        switch style {
        case .linear:
            applyLinearTransform(to: &attributes, scale: layoutConfig.minScale, alpha: layoutConfig.minAlpha)
        case .coverflow:
            applyCoverflowTransform(to: &attributes, angle: layoutConfig.maxAngle, alpha: layoutConfig.minAlpha)
        default:
            return
        }
    }
    
    private func applyTransform(to attributes: inout UICollectionViewLayoutAttributes, with style: CyclePagerLayoutConfig.LayoutStyle) {
        switch style {
        case .linear:
            applyLinearTransform(to: &attributes)
        case .coverflow:
            applyCoverflowTransform(to: &attributes)
        default:
            return
        }
    }
    
    fileprivate func direction(withCenterX centerX: CGFloat) -> CyclePagerLayoutConfig.LayoutItemDirection {
        var direction: CyclePagerLayoutConfig.LayoutItemDirection = .right
        if let collectionView = collectionView {
            let contentCenterX = collectionView.contentOffset.x + collectionView.frame.width / 2.0
            if abs(centerX - contentCenterX) < 0.5 {
                direction = .center
            } else if centerX - contentCenterX < 0 {
                direction = .left
            }
        }
        return direction
    }
    
    fileprivate func direction(withCenterY centerY: CGFloat) -> CyclePagerLayoutConfig.LayoutItemDirection {
        var direction: CyclePagerLayoutConfig.LayoutItemDirection = .bottom
        if let collectionView = collectionView {
            let contentCenterY = collectionView.contentOffset.y + collectionView.frame.height / 2.0
            if abs(centerY - contentCenterY) < 0.5 {
                direction = .center
            } else if centerY - contentCenterY < 0 {
                direction = .top
            }
        }
        return direction
    }
    
}


extension CyclePagerTransformLayout {
    
    private func applyLinearTransform(to attributes: inout UICollectionViewLayoutAttributes) {
        switch layoutConfig.scrollDirection {
        case .horizontal:
            let collectionWidth = collectionView?.frame.width ?? 0
            if collectionWidth <= 0 {
                return
            }
            let centerX = collectionView!.contentOffset.x + collectionWidth / 2.0
            let delta = abs(attributes.center.x - centerX)
            let scale = max(1 - delta / collectionWidth * layoutConfig.rateOfChange, layoutConfig.minScale)
            let alpha = max(1 - delta / collectionWidth, layoutConfig.minAlpha)
            applyLinearTransform(to: &attributes, scale: scale, alpha: alpha)
        case .vertical:
            let collectionHeight = collectionView?.frame.height ?? 0
            if collectionHeight <= 0 {
                return
            }
            let centerY = collectionView!.contentOffset.y + collectionHeight / 2.0
            let delta = abs(attributes.center.y - centerY)
            let scale = max(1 - delta / collectionHeight * layoutConfig.rateOfChange, layoutConfig.minScale)
            let alpha = max(1 - delta / collectionHeight, layoutConfig.minAlpha)
            applyLinearTransform(to: &attributes, scale: scale, alpha: alpha)
        @unknown default:
            break
        }
    }
    
    private func applyLinearTransform(to attributes: inout UICollectionViewLayoutAttributes, scale: CGFloat, alpha: CGFloat) {
        switch layoutConfig.scrollDirection {
        case .horizontal:
            var transform = CGAffineTransform.init(scaleX: scale, y: scale)
            var scale = scale
            var alpha = alpha
            if layoutConfig.adjustSpacingWhenScroling {
                let direction = self.direction(withCenterX: attributes.center.x)
                var translate: CGFloat = 0
                switch direction {
                case .left:
                    translate = 1.15 * attributes.size.width * (1 - scale) / 2.0
                case .right:
                    translate = -1.15 * attributes.size.width * (1 - scale) / 2.0
                default:
                    scale = 1
                    alpha = 1
                }
                transform = transform.translatedBy(x: translate, y: 0)
            }
            attributes.transform = transform
            attributes.alpha = alpha
        case .vertical:
            var transform = CGAffineTransform.init(scaleX: scale, y: scale)
            var scale = scale
            var alpha = alpha
            if layoutConfig.adjustSpacingWhenScroling {
                let direction = self.direction(withCenterY: attributes.center.y)
                var translate: CGFloat = 0
                switch direction {
                case .top:
                    translate = 1.15 * attributes.size.height * (1 - scale) / 2.0
                case .bottom:
                    translate = -1.15 * attributes.size.height * (1 - scale) / 2.0
                default:
                    scale = 1
                    alpha = 1
                }
                transform = transform.translatedBy(x: 0, y: translate)
            }
            attributes.transform = transform
            attributes.alpha = alpha
        @unknown default:
            break
        }
    }
}

extension CyclePagerTransformLayout {
    
    private func applyCoverflowTransform(to attributes: inout UICollectionViewLayoutAttributes) {
        switch layoutConfig.scrollDirection {
        case .horizontal:
            let collectionWidth = collectionView?.frame.width ?? 0
            if collectionWidth <= 0 {
                return
            }
            let centerX = collectionView!.contentOffset.x + collectionWidth / 2.0
            let delta = abs(attributes.center.x - centerX)
            let angle = min(delta / collectionWidth * (1 - layoutConfig.rateOfChange), layoutConfig.maxAngle)
            let alpha = max(1 - delta / collectionWidth, layoutConfig.minAlpha)
            applyCoverflowTransform(to: &attributes, angle: angle, alpha: alpha)
        case .vertical:
            let collectionHeight = collectionView?.frame.height ?? 0
            if collectionHeight <= 0 {
                return
            }
            let centerY = collectionView!.contentOffset.y + collectionHeight / 2.0
            let delta = abs(attributes.center.y - centerY)
            let angle = min(delta / collectionHeight * (1 - layoutConfig.rateOfChange), layoutConfig.maxAngle)
            let alpha = max(1 - delta / collectionHeight, layoutConfig.minAlpha)
            applyCoverflowTransform(to: &attributes, angle: angle, alpha: alpha)
        @unknown default:
            break
        }
    }
    
    private func applyCoverflowTransform(to attributes: inout UICollectionViewLayoutAttributes, angle: CGFloat, alpha: CGFloat) {
        var angle = angle
        var alpha = alpha
        switch layoutConfig.scrollDirection {
        case .horizontal:
            let direction = self.direction(withCenterX: attributes.center.x)
            var transform3D = CATransform3DIdentity
            transform3D.m34 = -0.002
            var translate: CGFloat = 0
            switch direction {
            case .left:
                translate = (1 - cos(angle * 1.2 * CGFloat(Double.pi))) * attributes.size.width
            case .right:
                translate = -(1 - cos(angle * 1.2 * CGFloat(Double.pi))) * attributes.size.width
                angle = -angle
            default:
                angle = 0
                alpha = 1
            }
            
            transform3D = CATransform3DRotate(transform3D, angle * CGFloat(Double.pi), 0, 1, 0)
            if layoutConfig.adjustSpacingWhenScroling {
                transform3D = CATransform3DTranslate(transform3D, translate, 0, 0)
            }
            attributes.transform3D = transform3D
            attributes.alpha = alpha
        case .vertical:
            let direction = self.direction(withCenterY: attributes.center.y)
            var transform3D = CATransform3DIdentity
            transform3D.m34 = 0.002
            var translate: CGFloat = 0
            switch direction {
            case .top:
                translate = (1 - cos(angle * 0.8 * CGFloat(Double.pi))) * attributes.size.height
            case .bottom:
                translate = -(1 - cos(angle * 0.8 * CGFloat(Double.pi))) * attributes.size.height
                angle = -angle
            default:
                angle = 0
                alpha = 1
            }
            transform3D = CATransform3DRotate(transform3D, angle * CGFloat(Double.pi), 1, 0, 0)
            if layoutConfig.adjustSpacingWhenScroling {
                transform3D = CATransform3DTranslate(transform3D, 0, translate, 0)
            }
            attributes.transform3D = transform3D
            attributes.alpha = alpha
        @unknown default:
            break
        }
    }
}
