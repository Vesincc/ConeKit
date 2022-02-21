//
//  CyclePagerLayoutConfig.swift
//  CaptionsKit
//
//  Created by HanQi on 2021/6/2.
//

import Foundation
import UIKit

// MARK: - config
public class CyclePagerLayoutConfig: NSObject {
    
    public var itemSize: CGSize = .zero
    public var itemSpacing: CGFloat = 0
    public var sectionInset: UIEdgeInsets = .zero
    
    public var scrollDirection: UICollectionView.ScrollDirection = .horizontal
    
    public var layoutStyle: LayoutStyle = .normal
    
    public var minScale: CGFloat = 0.8
    public var minAlpha: CGFloat = 1
    public var maxAngle: CGFloat = 0.2
     
    public var rateOfChange: CGFloat = 0.4
    public var adjustSpacingWhenScroling = true
    
    // 在非无限滚动下设置剧中  pagerview.isInfiniteLoop = false 时有效
    // pagerview.isInfiniteLoop = true 时 通过设置 sectionInset 调整位置
    public var itemVerticalCenter = true
    public var itemHorizontalCenter = true
    
    var isInfiniteLoop = true
    
    weak var layout: UICollectionViewLayout?
    private var pagerView: UIView? {
        layout?.collectionView
    }
}

extension CyclePagerLayoutConfig {
    
    public enum LayoutStyle {
        case normal
        case linear
        case coverflow
    }
    
    enum ScrollDirection {
        case left
        case right
        
        case top
        case bottom
    }
    
    enum LayoutItemDirection {
        case left
        case center
        case right
        
        case top
        case bottom
    }
    
}

extension CyclePagerLayoutConfig {
    
    var onlyOneSectionInset: UIEdgeInsets {
        switch scrollDirection {
        case .horizontal:
            let leftSpace = pagerView != nil && !isInfiniteLoop && itemHorizontalCenter ? ((pagerView?.frame.width ?? 0) - itemSize.width) / 2.0 : sectionInset.left
            let rightSpace =  pagerView != nil && !isInfiniteLoop && itemHorizontalCenter ? ((pagerView?.frame.width ?? 0) - itemSize.width) / 2.0 : sectionInset.right
            if itemVerticalCenter {
                let verticalSpace = ((pagerView?.frame.height ?? 0) - itemSize.height) / 2.0
                return .init(top: verticalSpace, left: leftSpace, bottom: verticalSpace, right: rightSpace)
            }
            return .init(top: sectionInset.top, left: leftSpace, bottom: sectionInset.bottom, right: rightSpace)
        case .vertical:
            let topSpace = pagerView != nil && !isInfiniteLoop && itemVerticalCenter ? ((pagerView?.frame.height ?? 0) - itemSize.height) / 2.0 : sectionInset.top
            let bottomSpace = pagerView != nil && !isInfiniteLoop && itemVerticalCenter ? ((pagerView?.frame.height ?? 0) - itemSize.height) / 2.0 : sectionInset.bottom
            if itemHorizontalCenter {
                let horizontalSpace = ((pagerView?.frame.width ?? 0) - itemSize.width) / 2.0
                return .init(top: topSpace, left: horizontalSpace, bottom: bottomSpace, right: horizontalSpace)
            }
            return .init(top: topSpace, left: sectionInset.left, bottom: bottomSpace, right: sectionInset.right)
        @unknown default:
            return .zero
        }
    }
    var firstSectionInset: UIEdgeInsets {
        switch scrollDirection {
        case .horizontal:
            if itemVerticalCenter {
                let verticalSpace = ((pagerView?.frame.height ?? 0) - itemSize.height) / 2.0
                return .init(top: verticalSpace, left: sectionInset.left, bottom: verticalSpace, right: itemSpacing)
            }
            return .init(top: sectionInset.top, left: sectionInset.left, bottom: sectionInset.bottom, right: itemSpacing)
        case .vertical:
            if itemHorizontalCenter {
                let horizontalSpace = ((pagerView?.frame.width ?? 0) - itemSize.width) / 2.0
                return .init(top: sectionInset.top, left: horizontalSpace, bottom: itemSpacing, right: horizontalSpace)
            }
            return .init(top: sectionInset.top, left: sectionInset.left, bottom: itemSpacing, right: sectionInset.right)
        @unknown default:
            return .zero
        }
    }
    
    var middleSectionInset: UIEdgeInsets {
        switch scrollDirection {
        case .horizontal:
            if itemVerticalCenter {
                let verticalSpace = ((pagerView?.frame.height ?? 0) - itemSize.height) / 2.0
                return .init(top: verticalSpace, left: 0, bottom: verticalSpace, right: itemSpacing)
            }
            return sectionInset
        case .vertical:
            if itemHorizontalCenter {
                let horizontalSpace = ((pagerView?.frame.width ?? 0) - itemSize.width) / 2.0
                return .init(top: 0, left: horizontalSpace, bottom: itemSpacing, right: horizontalSpace)
            }
            return sectionInset
        @unknown default:
            return .zero
        }
    }
    
    var lastSectionInset: UIEdgeInsets {
        switch scrollDirection {
        case .horizontal:
            if itemVerticalCenter {
                let verticalSpace = ((pagerView?.frame.height ?? 0) - itemSize.height) / 2.0
                return .init(top: verticalSpace, left: 0, bottom: verticalSpace, right: sectionInset.right)
            }
            return .init(top: sectionInset.top, left: 0, bottom: sectionInset.bottom, right: sectionInset.right)
        case .vertical:
            if itemHorizontalCenter {
                let horizontalSpace = ((pagerView?.frame.width ?? 0) - itemSize.width) / 2.0
                return .init(top: 0, left: horizontalSpace, bottom: sectionInset.bottom, right: horizontalSpace)
            }
            return .init(top: 0, left: sectionInset.left, bottom: sectionInset.bottom, right: sectionInset.right)
        @unknown default:
            return .zero
        }
    }
    
}
