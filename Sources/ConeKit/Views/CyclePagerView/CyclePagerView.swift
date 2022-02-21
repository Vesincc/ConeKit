//
//  CyclePagerView.swift
//  CaptionsKit
//
//  Created by HanQi on 2021/6/2.
//

import Foundation
import UIKit

fileprivate let kPagerViewMaxSectionCount = 300
fileprivate let kPagerViewMinSectionCount = 100

open class CyclePagerView: UIView {
    
    public var backgroundView: UIView? {
        get {
            collectionView.backgroundView
        }
        set {
            collectionView.backgroundView = newValue
        }
    }
    
    public weak var delegate: CyclePagerViewDelegate? {
        didSet {
            delegateFlags.loadFlags(delegate)
            if collectionView != nil, let layout = collectionView.collectionViewLayout as? CyclePagerTransformLayout {
                layout.delegate = nil
                if delegateFlags.applyTransformToAttributes || delegateFlags.initializeTransformAttributes {
                    layout.delegate = delegate as? CyclePagerTransformLayoutDelegate ?? nil
                }
            }
        }
    }
    public weak var dataSource: CyclePagerViewDataSource? {
        didSet {
            dataSourceFlags.loadFlags(dataSource)
            if dataSourceFlags.numberOfItems {
                numberOfItems = dataSource?.numberOfItems(in: self) ?? 0
            }
        }
    }
    
    public var collectionView: UICollectionView!
     
    public var layoutConfig: CyclePagerLayoutConfig? {
        get {
            if collectionView != nil, let layout = collectionView.collectionViewLayout as? CyclePagerTransformLayout {
                return layout.layoutConfig
            } else {
                return nil
            }
        }
    }
    
    /// 无限滚动
    public var isInfiniteLoop: Bool = true
    
    public var isScrollEnabled: Bool {
        get {
            collectionView.isScrollEnabled
        }
        set {
            collectionView.isScrollEnabled = newValue
        }
    }
    
    /// 自动滚动间隔  0 不自动滚动
    public var autoScrollInterval: TimeInterval = 0 {
        didSet {
            if autoScrollInterval > 0, superview != nil {
                resetTimer()
            }
        }
    }
    
    public var reloadDataNeedResetIndex = false
    
    public var currentIndex: Int {
        indexSection.index
    }
    
    public var indexSection: HQIndexSection = .init()
    
    public var contentOffset: CGPoint {
        collectionView.contentOffset
    }
    
    public var isTracking: Bool {
        collectionView.isTracking
    }
    
    public var isDragging: Bool {
        collectionView.isDragging
    }
    
    public var isDecelerating: Bool {
        collectionView.isDecelerating
    }
    
    /// 清除layout 并且调用 func layout(for pagerView: HQCyclePagerView) -> HQCyclePagerLayout
    public func reloadData() {
        didReloadData = true
        needResetIndex = true
        setNeedsClearLayout()
        clearLayout()
        updateData()
    }
    
    /// 更新数据 不会清除layout
    public func updateData() {
        updateLayout()
        numberOfItems = dataSource?.numberOfItems(in: self) ?? 0
        collectionView.reloadData()
        if !didLayout, !collectionView.frame.isEmpty, indexSection.index < 0 {
            didLayout = true
        }
        let needResetIndex = self.needResetIndex && reloadDataNeedResetIndex
        self.needResetIndex = false
        if needResetIndex {
            removeTimer()
        }
        resetPagerView(at: indexSection.index < 0 && !collectionView.frame.isEmpty || needResetIndex ? 0 : indexSection.index)
        if needResetIndex {
            resetTimer()
        }
    }
    
    /// 更新layout
    public func setNeedsUpdateLayout() {
        if layoutConfig == nil { return }
        clearLayout()
        updateLayout()
        collectionView.collectionViewLayout.invalidateLayout()
        resetPagerView(at: indexSection.index < 0 ? 0 : indexSection.index)
    }
    
    /// 清除layout -> layout for pagerview
    public func setNeedsClearLayout() {
        needClearLayout = true
    }
    
    public func currentIndexCell() -> UICollectionViewCell? {
        collectionView.cellForItem(at: .init(item: indexSection.index, section: indexSection.section))
    }
    
    public func visibleCells() -> [UICollectionViewCell] {
        collectionView.visibleCells
    }
    
    public func visibleIndexs() -> [Int] {
        var indexs: [Int] = []
        for indexPath in collectionView.indexPathsForVisibleItems {
            indexs.append(indexPath.item)
        }
        return indexs
    }
    
    public func scrollToItem(at index: Int, animate: Bool) {
        if !didLayout && didReloadData {
            firstScrollIndex = index
        } else {
            firstScrollIndex = -1
        }
        if !isInfiniteLoop {
            scrollToItem(at: .init(index, 0), animate: animate)
        } else {
            scrollToItem(at: .init(index, index >= currentIndex ? indexSection.section : indexSection.section + 1), animate: animate)
        }
    }
    
    public func scrollToItem(at indexSection: HQIndexSection, animate: Bool) {
        if numberOfItems <= 0 || !isValid(indexSection: indexSection) {
            return
        }
        if let layouConfig = layoutConfig {
            if animate, let delegate = delegate, delegate.responds(to: #selector(CyclePagerViewDelegate.pagerViewWillBeginScrollingAnimation(_:))) {
                delegate.pagerViewWillBeginScrollingAnimation?(self)
            }
            switch layouConfig.scrollDirection {
            case .horizontal:
                let offset = caculateOffsetX(at: indexSection)
                collectionView.setContentOffset(.init(x: offset, y: collectionView.contentOffset.y), animated: animate)
            case.vertical:
                let offset = caculateOffsetY(at: indexSection)
                collectionView.setContentOffset(.init(x: collectionView.contentOffset.x, y: offset), animated: animate)
            @unknown default:
                break
            }
        }
    }
    
    private func scrollToNearlyIndex(at direction: CyclePagerLayoutConfig.ScrollDirection, animate: Bool) {
        let indexSection = nearlyIndexPath(at: direction)
        scrollToItem(at: indexSection, animate: animate)
    }
    
    public func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: .init(item: index, section: dequeueSection))
    }
    
    private var timer: Timer?
    
    private var numberOfItems: Int = 0
    private var dequeueSection: Int = 0
    private var beginDragIndexSection: HQIndexSection = .init()
    private var firstScrollIndex: Int = -1
    
    private var needClearLayout = false
    private var didReloadData = false
    private var didLayout = false
    private var needResetIndex = false
    
    private var delegateFlags = DelegateInfo.init()
    private var dataSourceFlags = DataSourceInfo.init()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        beginDragIndexSection.index = 0
        beginDragIndexSection.section = 0
        
        loadCollectionView()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        collectionView.delegate = nil
        collectionView.dataSource = nil
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let needUpdateLayout = collectionView.frame != bounds
        collectionView.frame = bounds
        if (indexSection.section < 0 || needUpdateLayout), (numberOfItems > 0 || didReloadData) {
            didLayout = true
            setNeedsUpdateLayout()
        }
    }
    
}

extension CyclePagerView {
    
    public class HQIndexSection: NSObject {
        
        public var index: Int = -1
        public var section: Int = -1
        
        public override init() {
        }
        
        public init(_ index: Int, _ section: Int) {
            self.index = index
            self.section = section
        }
        
        public override func isEqual(_ object: Any?) -> Bool {
            if let object = object as? HQIndexSection {
                return object.index == index && object.section == section
            }
            return false
        }
    }
    
}

extension CyclePagerView {
    
    private func caculateIndexSection(withOffsetX offsetX: CGFloat) -> HQIndexSection {
        if numberOfItems <= 0 {
            return .init(0, 0)
        }
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, let layoutConfig = layoutConfig {
            let leftEdge = isInfiniteLoop ? layoutConfig.sectionInset.left : layoutConfig.onlyOneSectionInset.left
            let width = collectionView.frame.width
            let middleOffset = offsetX + width / 2.0
            let itemWidth = layout.itemSize.width + layout.minimumInteritemSpacing
            var currentIndex = 0
            var currentSection = 0
            if middleOffset - leftEdge >= 0 {
                var itemIndex = (middleOffset - leftEdge + layout.minimumInteritemSpacing / 2.0) / itemWidth
                if itemIndex < 0 {
                    itemIndex = 0
                } else if itemIndex >= CGFloat(numberOfItems * kPagerViewMaxSectionCount) {
                    itemIndex = CGFloat(numberOfItems * kPagerViewMaxSectionCount - 1)
                }
                currentIndex = Int(itemIndex) % numberOfItems
                currentSection = Int(itemIndex) / numberOfItems
            }
            return .init(currentIndex, currentSection)
        } else {
            return .init(0, 0)
        }
    }
    
    private func caculateOffsetX(at indexSection: HQIndexSection) -> CGFloat {
        if numberOfItems == 0 { return 0 }
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, let layoutConfig = layoutConfig {
            let edge = isInfiniteLoop ? layoutConfig.sectionInset : layoutConfig.onlyOneSectionInset
            let leftEdge: CGFloat = edge.left
            let rightEdge: CGFloat = edge.right
            let width: CGFloat = collectionView.frame.width
            let itemWidth: CGFloat = layout.itemSize.width + layout.minimumInteritemSpacing
            var offsetX: CGFloat = 0
            if !isInfiniteLoop, !layoutConfig.itemHorizontalCenter, indexSection.index == numberOfItems - 1 {
                offsetX = leftEdge + itemWidth * CGFloat(indexSection.index + indexSection.section * numberOfItems) - (width - itemWidth) - layout.minimumInteritemSpacing + rightEdge
            } else {
                offsetX = leftEdge + itemWidth * CGFloat(indexSection.index + indexSection.section * numberOfItems) - layout.minimumInteritemSpacing / 2.0 - (width - itemWidth) / 2.0
            }
            return max(offsetX, 0)
        } else {
            return 0
        }
    }
    
    private func caculateIndexSection(withOffsetY offsetY: CGFloat) -> HQIndexSection {
        if numberOfItems <= 0 {
            return .init(0, 0)
        }
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, let layoutConfig = layoutConfig {
            let topEdge = isInfiniteLoop ? layoutConfig.sectionInset.top : layoutConfig.onlyOneSectionInset.top
            let height = collectionView.frame.height
            let middleOffset = offsetY + height / 2.0
            let itemHeight = layout.itemSize.height + layout.minimumInteritemSpacing
            var currentIndex = 0
            var currentSection = 0
            if middleOffset - topEdge >= 0 {
                var itemIndex = (middleOffset - topEdge + layout.minimumLineSpacing / 2.0) / itemHeight
                if itemIndex < 0 {
                    itemIndex = 0
                } else if itemIndex >= CGFloat(numberOfItems * kPagerViewMaxSectionCount) {
                    itemIndex = CGFloat(numberOfItems * kPagerViewMaxSectionCount - 1)
                }
                currentIndex = Int(itemIndex) % numberOfItems
                currentSection = Int(itemIndex) / numberOfItems
            }
            return .init(currentIndex, currentSection)
        } else {
            return .init(0, 0)
        }
    }

    private func caculateOffsetY(at indexSection: HQIndexSection) -> CGFloat {
        if numberOfItems == 0 { return 0 }
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, let layoutConfig = layoutConfig {
            let edge = isInfiniteLoop ? layoutConfig.sectionInset : layoutConfig.onlyOneSectionInset
            let topEdge: CGFloat = edge.top
            let bottomEdge: CGFloat = edge.bottom
            let height: CGFloat = collectionView.frame.height
            let itemHeight: CGFloat = layout.itemSize.height + layout.minimumLineSpacing
            var offsetY: CGFloat = 0
            if !isInfiniteLoop, !layoutConfig.itemVerticalCenter, indexSection.index == numberOfItems - 1 {
                offsetY = topEdge + itemHeight * CGFloat(indexSection.index + indexSection.section * numberOfItems) - (height - itemHeight) - layout.minimumLineSpacing + bottomEdge
            } else {
                offsetY = topEdge + itemHeight * CGFloat(indexSection.index + indexSection.section * numberOfItems) - layout.minimumLineSpacing / 2.0 - (height - itemHeight) / 2.0
            }
            return max(offsetY, 0)
        } else {
            return 0
        }
    }
    
}

extension CyclePagerView {
    
    private func isValid(indexSection: HQIndexSection) -> Bool {
        indexSection.index >= 0 && indexSection.index < numberOfItems && indexSection.section >= 0 && indexSection.section < kPagerViewMaxSectionCount
    }
    
    private func nearlyIndexPath(at direction: CyclePagerLayoutConfig.ScrollDirection) -> HQIndexSection {
        nearlyIndexPath(for: indexSection, direction: direction)
    }
    
    private func nearlyIndexPath(for indexSection: HQIndexSection, direction: CyclePagerLayoutConfig.ScrollDirection) -> HQIndexSection {
        if indexSection.index < 0 || indexSection.index >= numberOfItems {
            return indexSection
        }
        if !isInfiniteLoop {
            if (direction == .right || direction == .bottom), indexSection.index == numberOfItems {
                return autoScrollInterval > 0 ? .init(0, 0) : indexSection
            } else if direction == .right || direction == .bottom {
                return .init(indexSection.index + 1, 0)
            }
            
            if indexSection.index == 0 {
                return autoScrollInterval > 0 ? .init(numberOfItems - 1, 0) : indexSection
            }
            return .init(indexSection.index - 1, 0)
        }
        if direction == .right || direction == .bottom {
            if indexSection.index < numberOfItems - 1 {
                return .init(indexSection.index + 1, indexSection.section)
            }
            if indexSection.section >= kPagerViewMaxSectionCount - 1 {
                return .init(indexSection.index, kPagerViewMaxSectionCount - 1)
            }
            return .init(0, indexSection.section + 1)
        } else if direction == .left || direction == .top {
            if indexSection.index > 0 {
                return .init(indexSection.index - 1, indexSection.section)
            }
            if indexSection.section <= 0 {
                return .init(indexSection.index, 0)
            }
            return .init(numberOfItems - 1, indexSection.section - 1)
        }
        return .init(0, 0)
    }
    
    private func loadCollectionView() {
        let layout = CyclePagerTransformLayout.init(with: .init())
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = false
        collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: UIScrollView.DecelerationRate.RawValue(1 - 0.0076))
        collectionView.isPrefetchingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.scrollsToTop = false
        
        addSubview(collectionView)
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        removeTimer()
        if newSuperview != nil, autoScrollInterval > 0 {
            resetTimer()
        }
    }
    
    private func clearLayout() {
        if needClearLayout {
            resetLayoutConfigIfNeed()
            needClearLayout = false
        }
    }
    
    private func updateLayout() {
        guard layoutConfig != nil else { return }
        resetLayoutConfigIfNeed()
        if let config = layoutConfig {
            config.isInfiniteLoop = isInfiniteLoop
            if let clayout = collectionView.collectionViewLayout as? CyclePagerTransformLayout {
                clayout.layoutConfig = config
            }
        }
    }
    
    private func resetLayoutConfigIfNeed() {
        if let dataSource = dataSource, dataSource.responds(to: #selector(CyclePagerViewDataSource.layoutConfig(for:))) {
            let layoutConfig = dataSource.layoutConfig!(for: self)
            if collectionView != nil, let layout = collectionView.collectionViewLayout as? CyclePagerTransformLayout {
                layout.layoutConfig = layoutConfig
            }
        }
    }
    
    private func resetPagerView(at index: Int) {
        var index = index
        if didLayout, firstScrollIndex >= 0 {
            index = firstScrollIndex
            firstScrollIndex = -1
        }
        guard index >= 0 else { return }
        if index >= numberOfItems {
            index = 0
        }
        scrollToItem(at: .init(index, isInfiniteLoop ? kPagerViewMaxSectionCount / 3 : 0), animate: false)
        if !isInfiniteLoop, indexSection.index < 0 {
            scrollViewDidScroll(collectionView)
        }
        
    }
    
}

// MARK: - timer
extension CyclePagerView {
    
    private func resetTimer() {
        guard timer == nil, autoScrollInterval > 0 else { return }
        timer = Timer.init(timeInterval: autoScrollInterval, target: self, selector: #selector(timerFired(timer:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func removeTimer() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func timerFired(timer: Timer) {
        guard superview != nil, window != nil, numberOfItems > 0, !isTracking else { return}
        scrollToNearlyIndex(at: .right, animate: true)
    }
    
}

extension CyclePagerView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard didLayout else {
            return
        }
        if let layoutConfig = layoutConfig {
            let newIndexSection = layoutConfig.scrollDirection == .horizontal ? caculateIndexSection(withOffsetX: scrollView.contentOffset.x) : caculateIndexSection(withOffsetY: scrollView.contentOffset.y)
            if numberOfItems <= 0 || !isValid(indexSection: newIndexSection) {
                print("inVlaidIndexSection:\(newIndexSection.index) \(newIndexSection.section)")
                return
            }
            let indexSection = self.indexSection
            self.indexSection = newIndexSection
            if delegateFlags.pagerViewDidScroll {
                delegate?.pagerViewDidScroll?(self)
            }
            if delegateFlags.pagerViewDidScrollFromIndexToIndex, !indexSection.isEqual(self.indexSection) {
                delegate?.pagerView?(self, didScrollFrom: max(indexSection.index, 0), toIndex: self.indexSection.index)
            }
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if autoScrollInterval > 0 {
            removeTimer()
        }
        if let layoutConfig = layoutConfig {
            beginDragIndexSection = layoutConfig.scrollDirection == .horizontal ? caculateIndexSection(withOffsetX: scrollView.contentOffset.x) : caculateIndexSection(withOffsetY: scrollView.contentOffset.y)
            if delegateFlags.pagerViewWillBeginDragging {
                delegate?.pagerViewWillBeginDragging?(self)
            }
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var point = targetContentOffset.pointee
        if let layoutConfig = layoutConfig {
            switch layoutConfig.scrollDirection {
            case .horizontal:
                if abs(velocity.x) < 0.35 || !beginDragIndexSection.isEqual(indexSection) {
                    point.x = caculateOffsetX(at: indexSection)
                    targetContentOffset.pointee = point
                    return
                }
                var direction: CyclePagerLayoutConfig.ScrollDirection = .right
                if (scrollView.contentOffset.x < 0 && point.x <= 0) || (point.x < scrollView.contentOffset.x && scrollView.contentOffset.x < scrollView.contentSize.width - scrollView.frame.width) {
                    direction = .left
                }
                let indexSection = nearlyIndexPath(for: self.indexSection, direction: direction)
                point.x = caculateOffsetX(at: indexSection)
                targetContentOffset.pointee = point
            case .vertical:
                if abs(velocity.y) < 0.35 || !beginDragIndexSection.isEqual(indexSection) {
                    point.y = caculateOffsetY(at: indexSection)
                    targetContentOffset.pointee = point
                    return
                }
                var direction: CyclePagerLayoutConfig.ScrollDirection = .bottom
                if (scrollView.contentOffset.y < 0 && point.y <= 0) || (point.y < scrollView.contentOffset.y && scrollView.contentOffset.y < scrollView.contentSize.height - scrollView.frame.height) {
                    direction = .top
                }
                let indexSection = nearlyIndexPath(for: self.indexSection, direction: direction)
                point.y = caculateOffsetY(at: indexSection)
                targetContentOffset.pointee = point
            @unknown default:
                break
            }
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if autoScrollInterval > 0 {
            resetTimer()
        }
        if delegateFlags.pagerViewDidEndDragging {
            delegate?.pagerViewDidEndDragging?(self, willDecelerate: decelerate)
        }
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if delegateFlags.pagerViewWillBeginDecelerating {
            delegate?.pagerViewWillBeginDecelerating?(self)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        recyclePagerViewIfNeed()
        if delegateFlags.pagerViewDidEndDecelerating {
            delegate?.pagerViewDidEndDecelerating?(self)
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        recyclePagerViewIfNeed()
        if delegateFlags.pagerViewDidEndScrollingAnimation {
            delegate?.pagerViewDidEndScrollingAnimation?(self)
        }
    }
    
    private func recyclePagerViewIfNeed() {
        if isInfiniteLoop, (indexSection.section >= kPagerViewMaxSectionCount - kPagerViewMinSectionCount || indexSection.section < kPagerViewMinSectionCount) {
            resetPagerView(at: indexSection.index)
        }
    }
}

extension CyclePagerView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        isInfiniteLoop ? kPagerViewMaxSectionCount : 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource?.numberOfItems(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        dequeueSection = dataSource?.numberOfItems(in: self) ?? 0
        if dataSourceFlags.cellForItemAtIndex {
            return dataSource!.pagerView(self, cellForItemAt: indexPath.row)
        }
        assert(false, "pagerView cellForItemAtIndex: is nil!")
        return .init()
    }
    
}

extension CyclePagerView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if !isInfiniteLoop {
            return layoutConfig?.onlyOneSectionInset ?? .zero
        }
        if section == 0 {
            return layoutConfig?.firstSectionInset ?? .zero
        } else if section == kPagerViewMaxSectionCount - 1 {
            return layoutConfig?.lastSectionInset ?? .zero
        }
        return layoutConfig?.middleSectionInset ?? .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            if delegateFlags.pagerViewDidSelectItemAtIndex {
                delegate?.pagerView?(self, didSelectItem: cell, atIndex: indexPath.item)
            }
            if delegateFlags.pagerViewDidSelectItemAtIndexSection {
                delegate?.pagerView?(self, didSelectItem: cell, atIndexSection: .init(indexPath.item, indexPath.section))
            }
        }
    }
    
}

fileprivate struct DataSourceInfo {
    var numberOfItems = false
    var cellForItemAtIndex = false
    var layoutForPagerView = false
    
    mutating func loadFlags(_ dataSource: CyclePagerViewDataSource?) {
        numberOfItems = false
        cellForItemAtIndex = false
        layoutForPagerView = false
        if let dataSource = dataSource {
            numberOfItems = dataSource.responds(to: #selector(CyclePagerViewDataSource.numberOfItems(in:)))
            cellForItemAtIndex = dataSource.responds(to: #selector(CyclePagerViewDataSource.pagerView(_:cellForItemAt:)))
            layoutForPagerView = dataSource.responds(to: #selector(CyclePagerViewDataSource.layoutConfig(for:)))
        }
    }
}

fileprivate struct DelegateInfo {
    
    var pagerViewDidScrollFromIndexToIndex = false
    var pagerViewDidSelectItemAtIndex = false
    var pagerViewDidSelectItemAtIndexSection = false
    
    var pagerViewDidScroll = false
    
    var pagerViewWillBeginDragging = false
    var pagerViewDidEndDragging = false
    
    var pagerViewWillBeginDecelerating = false
    var pagerViewDidEndDecelerating = false
    
    var pagerViewWillBeginScrollingAnimation = false
    var pagerViewDidEndScrollingAnimation = false
    
    var initializeTransformAttributes = false
    var applyTransformToAttributes = false
    
    mutating func loadFlags(_ delegate: CyclePagerViewDelegate?) {
        
        pagerViewDidScrollFromIndexToIndex = false
        pagerViewDidSelectItemAtIndex = false
        pagerViewDidSelectItemAtIndexSection = false
        
        pagerViewDidScroll = false
        
        pagerViewWillBeginDragging = false
        pagerViewDidEndDragging = false
        
        pagerViewWillBeginDecelerating = false
        pagerViewDidEndDecelerating = false
        
        pagerViewWillBeginScrollingAnimation = false
        pagerViewDidEndScrollingAnimation = false
        
        initializeTransformAttributes = false
        applyTransformToAttributes = false
        
        if let delegate = delegate {
            
            pagerViewDidScrollFromIndexToIndex = delegate.responds(to: #selector(CyclePagerViewDelegate.pagerView(_:didScrollFrom:toIndex:)))
            pagerViewDidSelectItemAtIndex = delegate.responds(to: #selector(CyclePagerViewDelegate.pagerView(_:didSelectItem:atIndex:)))
            pagerViewDidSelectItemAtIndexSection = delegate.responds(to: #selector(CyclePagerViewDelegate.pagerView(_:didSelectItem:atIndexSection:)))
            
            pagerViewDidScroll = delegate.responds(to: #selector(CyclePagerViewDelegate.pagerViewDidScroll(_:)))
            
            pagerViewWillBeginDragging = delegate.responds(to: #selector(CyclePagerViewDelegate.pagerViewWillBeginDragging(_:)))
            pagerViewDidEndDragging = delegate.responds(to: #selector(CyclePagerViewDelegate.pagerViewDidEndDragging(_:willDecelerate:)))
            
            pagerViewWillBeginDecelerating = delegate.responds(to: #selector(CyclePagerViewDelegate.pagerViewWillBeginDecelerating(_:)))
            pagerViewDidEndDecelerating = delegate.responds(to: #selector(CyclePagerViewDelegate.pagerViewDidEndDecelerating(_:)))
            
            pagerViewWillBeginScrollingAnimation = delegate.responds(to: #selector(CyclePagerViewDelegate.pagerViewWillBeginScrollingAnimation(_:)))
            pagerViewDidEndScrollingAnimation = delegate.responds(to: #selector(CyclePagerViewDelegate.pagerViewDidEndScrollingAnimation(_:)))
            
            initializeTransformAttributes = delegate.responds(to: #selector(CyclePagerTransformLayoutDelegate.pagerTransformLayout(_:initializeTransformAttributes:)))
            applyTransformToAttributes = delegate.responds(to: #selector(CyclePagerTransformLayoutDelegate.pagerTransformLayout(_:applyTransformToAttributes:)))
            
        }
        
    }
}
