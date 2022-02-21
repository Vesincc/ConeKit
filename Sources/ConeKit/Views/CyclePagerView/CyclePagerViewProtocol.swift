//
//  CyclePagerViewProtocol.swift
//  CaptionsKit
//
//  Created by HanQi on 2021/6/2.
//

import Foundation 
import UIKit

@objc public protocol CyclePagerViewDataSource: NSObjectProtocol {
    
    func numberOfItems(in pagerView: CyclePagerView) -> Int
    
    func pagerView(_ pagerView: CyclePagerView, cellForItemAt index: Int) -> UICollectionViewCell
    
    @objc optional func layoutConfig(for pagerView: CyclePagerView) -> CyclePagerLayoutConfig
    
}

@objc public protocol CyclePagerViewDelegate: NSObjectProtocol {
    
    // scroll
    @objc optional func pagerView(_ pagerView: CyclePagerView, didScrollFrom fromIndex: Int, toIndex: Int)
    
    // selected
    @objc optional func pagerView(_ pagerView: CyclePagerView, didSelectItem cell: UICollectionViewCell, atIndex index: Int)
    @objc optional func pagerView(_ pagerView: CyclePagerView, didSelectItem cell: UICollectionViewCell, atIndexSection indexSection: CyclePagerView.HQIndexSection)
    
    // UIScrollViewDelegate
    @objc optional func pagerViewDidScroll(_ pagerView: CyclePagerView)
    
    @objc optional func pagerViewWillBeginDragging(_ pagerView: CyclePagerView)
    @objc optional func pagerViewDidEndDragging(_ pagerView: CyclePagerView, willDecelerate decelerate: Bool)
    
    @objc optional func pagerViewWillBeginDecelerating(_ pagerView: CyclePagerView)
    @objc optional func pagerViewDidEndDecelerating(_ pagerView: CyclePagerView)
    
    @objc optional func pagerViewWillBeginScrollingAnimation(_ pagerView: CyclePagerView)
    @objc optional func pagerViewDidEndScrollingAnimation(_ pagerView: CyclePagerView)
}
 
@objc public protocol CyclePagerTransformLayoutDelegate: NSObjectProtocol {
    
    @objc optional func pagerTransformLayout(_ layout: UICollectionViewFlowLayout, initializeTransformAttributes attributes: UICollectionViewLayoutAttributes)
    
    @objc optional func pagerTransformLayout(_ layout: UICollectionViewFlowLayout, applyTransformToAttributes attributes: UICollectionViewLayoutAttributes)
    
}
