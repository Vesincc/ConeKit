//
//  PagerScrollContentView.swift
//  PagerScroll
//
//  Created by HanQi on 2022/8/12.
//

import UIKit 

protocol PagerScrollContentViewDelegate : AnyObject {
    func contentView(_ contentView: PagerScrollContentView, scrollingFromIndex fromIndex: Int, toIndex: Int, progress: Float)
    func contentView(_ contentView: PagerScrollContentView, didScrollTo index: Int)
}
extension PagerScrollContentViewDelegate {
    func contentView(_ contentView: PagerScrollContentView, scrollingFromIndex fromIndex: Int, toIndex: Int, progress: Float) {}
    func contentView(_ contentView: PagerScrollContentView, didScrollTo index: Int) {}
}

public class PagerScrollContentView: UIView {
    
    weak var delegate: PagerScrollContentViewDelegate?
    
    private var currentIndex: Int = 0  
    
    private var upIndex: Int = 0
    private var lowIndex: Int = 0

    public var viewControllers: [UIViewController] = []
 
    weak var parent: UIViewController?
    
    lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        Setter(UICollectionViewFlowLayout())
            .minimumLineSpacing(0)
            .minimumInteritemSpacing(0)
            .sectionInset(.zero)
            .scrollDirection(.horizontal)
            .subject
    }()
    
    lazy var collectionView: UICollectionView = {
        Setter(UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout))
            .isPagingEnabled(true)
            .showsVerticalScrollIndicator(false)
            .showsHorizontalScrollIndicator(false)
            .bounces(false)
            .translatesAutoresizingMaskIntoConstraints(false)
            .dataSource(self)
            .delegate(self)
            .excute({ c in
                c.registerCellClass(PagerScrollContentCell.self)
            })
            .subject
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: self.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: self.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public extension PagerScrollContentView {
    func load(vcs: [UIViewController], parent: UIViewController) {
        viewControllers = vcs
        vcs.forEach { vc in
            parent.addChild(vc)
        }
        collectionView.reloadData()
        self.parent = parent
    } 
    
    func select(viewController: UIViewController) {
        if let index = viewControllers.firstIndex(of: viewController) {
            selectViewController(at: index)
        }
    }
    func selectViewController(at index: Int) {
        collectionView.contentOffset = CGPoint(x: bounds.width * CGFloat(index), y: 0)
    }
}

extension PagerScrollContentView: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewControllers.count
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(PagerScrollContentCell.self, indexPath)
        cell.load(vc: viewControllers[indexPath.row], parent: parent)
        return cell
    }
}

extension PagerScrollContentView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let width = collectionView.bounds.width
        let currentLowIndex = Int(offsetX / width)
        let currentUpIndex = Int(ceil(offsetX / width))
        if currentUpIndex == currentLowIndex || (currentIndex != currentLowIndex && currentIndex != currentUpIndex) {
            currentIndex = currentLowIndex
            delegate?.contentView(self, didScrollTo: currentIndex)
        } else {
            let upOffset = CGFloat(currentUpIndex) * width
            let lowOffset = CGFloat(currentLowIndex) * width
            let progress = (offsetX - lowOffset) / (upOffset - lowOffset)
            if currentIndex == currentLowIndex {
                delegate?.contentView(self, scrollingFromIndex: currentLowIndex, toIndex: currentUpIndex, progress: Float(progress))
            } else if currentIndex == currentUpIndex {
                delegate?.contentView(self, scrollingFromIndex: currentUpIndex, toIndex: currentLowIndex, progress: Float(1 - progress))
            }
        }
        lowIndex = currentLowIndex
        upIndex = currentUpIndex
    }
}


fileprivate class PagerScrollContentCell: UICollectionViewCell {
     
    var viewController: UIViewController?
    
    let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(stackView)
         
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.leftAnchor.constraint(equalTo: self.leftAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: self.rightAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(vc: UIViewController, parent: UIViewController?) {
        viewController = vc
        stackView.removeSubviews()
        stackView.addArrangedSubview(vc.view)
    }
}
