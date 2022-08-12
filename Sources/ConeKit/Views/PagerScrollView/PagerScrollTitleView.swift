//
//  PagerScrollTitleView.swift
//  PagerScroll
//
//  Created by HanQi on 2022/8/12.
//

import UIKit

public protocol PagerScrollTitleViewDelegate: AnyObject {
    func titleView(_ titleView: PagerScrollTitleView, didSelected title: String, at index: Int)
}

public class PagerScrollTitleView: UIView {
    
    public weak var delegate: PagerScrollTitleViewDelegate?
    
    private var currentIndex = 0  
    
    public var titles: [String] = []
    var numbers: [Int] = []
    
    // MARK: - 整体设置
    
    /// item是否充满一行
    public var isFullItems: Bool = true
    
    /// 是否均分整行
    public var isAverage: Bool = true
    
    public var contentEdgeInset: UIEdgeInsets {
        get {
            collectionViewLayout.sectionInset
        }
        set {
            collectionViewLayout.sectionInset = newValue
        }
    }
    
    public var titleSpacing: CGFloat = 10
    
    // MARK: - item设置
    
    public var titleColor: UIColor = .gray
    
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 16)
    
    public var titleSelectedColor: UIColor = .black
    
    public var titleSelectedFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
    
    public var itemEdgeInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    

    // MARK: - 滑杆设置

    /// 滑杆颜色
    public var indicatorColor: UIColor = .red
    
    public var indicatorCornerRadius: CGFloat = 1.5
    
    /// 滑杆高度
    public var indicatorHeight: CGFloat = 3
    
    /// 滑杆宽度
    public var indicatorWidth: CGFloat?
    
    public var indicatorOffset: CGFloat = 4
    
    
    // MARK: - 数字设置
    public var configerNumber: ((UIButton) -> ())?
    
    public var itemNumberHeight: CGFloat? = 15
    
    public var numberOffset: CGPoint = CGPoint(x: 5, y: -2)
    
    // MARK: - views
    
    lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        Setter(UICollectionViewFlowLayout())
            .scrollDirection(.horizontal)
            .estimatedItemSize(CGSize(width: 100, height: 100))
            .subject
    }()
    
    lazy var collectionView: UICollectionView = {
        Setter(UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout))
            .excute({ c in
                c.registerCellClass(PagerScrollTitleCell.self)
            })
            .dataSource(self)
            .delegate(self)
            .showsHorizontalScrollIndicator(false)
            .showsVerticalScrollIndicator(false)
            .bounces(false)
            .backgroundColor(.clear)
            .subject
    }()

    lazy var lineView: UIView = {
        Setter(UIView())
            .backgroundColor(.red)
            .excute({ v in
                v.layer.zPosition = 0
            })
            .cornerRadius(indicatorCornerRadius)
            .subject
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: self.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: self.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        collectionView.addSubview(lineView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        reloadData()
    }
}

public extension PagerScrollTitleView {
    
    func loadTitles(titles: [String]) {
        if isFullItems {
            collectionViewLayout.scrollDirection = .vertical
            collectionViewLayout.horizontalAlignment(.center)
            if isAverage {
                collectionViewLayout.estimatedItemSize = .zero
            } else {
                collectionViewLayout.estimatedItemSize = CGSize(width: 100, height: collectionView.bounds.height)
            }
        } else {
            collectionViewLayout.scrollDirection = .horizontal
            collectionViewLayout.horizontalAlignment(.left)
            collectionViewLayout.estimatedItemSize = CGSize(width: 100, height: collectionView.bounds.height)
        }
        
        self.titles = titles
        lineView.backgroundColor = indicatorColor
        collectionViewLayout.minimumLineSpacing = titleSpacing
        collectionViewLayout.minimumInteritemSpacing = titleSpacing
        reloadData()
    }
    
    func loadNumbers(numbers: [Int]) {
        self.numbers = numbers
        self.collectionView.reloadData()
    }
    
    func indicator(fromIndex: Int, toIndex: Int, progress: Float) {
        let progress: CGFloat = CGFloat(progress)
        guard let fromCell = collectionView.cellForItem(at: IndexPath(item: fromIndex, section: 0)) as? PagerScrollTitleCell,
              let toCell = collectionView.cellForItem(at: IndexPath(item: toIndex, section: 0)) as? PagerScrollTitleCell else {
            return
        }
        let fromRect = lineRect(at: fromCell)
        let toRect = lineRect(at: toCell)
        lineView.frame = CGRect(
            x: fromRect.origin.x + (toRect.origin.x - fromRect.origin.x) * progress,
            y: fromRect.origin.y + (toRect.origin.y - fromRect.origin.y) * progress,
            width: fromRect.size.width + (toRect.size.width - fromRect.size.width) * progress,
            height: fromRect.size.height + (toRect.size.height - fromRect.size.height) * progress)
        
        fromCell.titleLabel.font = titleFont
        fromCell.titleLabel.textColor = UIColor.fromColor(fromColor: titleSelectedColor, toColor: titleColor, progress: progress)
        toCell.titleLabel.font = titleFont
        toCell.titleLabel.textColor = UIColor.fromColor(fromColor: titleColor, toColor: titleSelectedColor, progress: progress)
    }
    
    func indicatorSelectedTitle(at index: Int) {
        currentIndex = index
        UIView.animate(withDuration: 0) {
            self.collectionView.reloadData()
        } completion: { _ in
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }

    fileprivate func lineRect(at cell: PagerScrollTitleCell) -> CGRect {
        var lineWidth: CGFloat! = indicatorWidth
        if lineWidth == nil {
            lineWidth = cell.titleLabel.bounds.width
        }
        return CGRect(origin: CGPoint(x: cell.frame.origin.x + (cell.bounds.width - lineWidth) / 2.0, y: collectionView.bounds.height - indicatorHeight - indicatorOffset), size: CGSize(width: lineWidth, height: indicatorHeight))
    }
    
    fileprivate func reloadData() {
        UIView.animate(withDuration: 0) {
            self.collectionView.reloadData()
        } completion: { _ in
            self.configerLine()
        }
    }

    
    fileprivate func configerLine() {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? PagerScrollTitleCell else {
            lineView.frame = .zero
            return
        }
        lineView.frame = lineRect(at: cell)
    }
}
 
extension PagerScrollTitleView: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        titles.count
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(PagerScrollTitleCell.self, indexPath)
        cell.titleLabel.text = titles[indexPath.item]
        cell.titleLabel.textColor = currentIndex == indexPath.row ? titleSelectedColor : titleColor
        cell.titleLabel.font = currentIndex == indexPath.row ? titleSelectedFont : titleFont
        
        if isFullItems, isAverage {
            cell.stackView.axis = .vertical
        } else {
            cell.stackView.axis = .horizontal
        }
        
        cell.left.constant = itemEdgeInset.left
        cell.right.constant = -itemEdgeInset.right
        
        if itemEdgeInset.top != 0 || itemEdgeInset.bottom != 0 {
            cell.height.isActive = false
            cell.top.constant = itemEdgeInset.top
            cell.bottom.constant = -itemEdgeInset.bottom
        } else {
            cell.top.constant = 0
            cell.bottom.constant = 0
            cell.height.constant = collectionView.bounds.height
            cell.height.isActive = true
        } 
        cell.layer.zPosition = CGFloat(indexPath.item + 1)
        
        cell.configerNumber(number: numbers[safe: indexPath.item], height: itemNumberHeight, offset: numberOffset)
        configerNumber?(cell.numberButton)
        return cell
    }
}

extension PagerScrollTitleView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = self.collectionViewLayout.minimumLineSpacing
        let number: CGFloat = CGFloat(collectionView.numberOfItems(inSection: 0))
        if number == 0 {
            return .zero
        }
        let width = floor((collectionView.bounds.width - contentEdgeInset.left - contentEdgeInset.right - (spacing * (number - 1))) / number)
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentIndex = indexPath.item
        UIView.animate(withDuration: 0.3) {
            self.configerLine()
        } completion: { _ in
            self.delegate?.titleView(self, didSelected: self.titles[indexPath.item], at: indexPath.item)
        }
    }
}



fileprivate class PagerScrollTitleCell: UICollectionViewCell {
    
    lazy var stackView: UIStackView = {
        Setter(UIStackView())
            .axis(.vertical)
            .alignment(.center)
            .excute({ s in
                s.addArrangedSubview(titleLabel)
            })
            .subject
    }()
    
    lazy var titleLabel: UILabel = UILabel()
    
    lazy var numberButton: UIButton = {
        Setter(UIButton())
            .isUserInteractionEnabled(false)
            .backgroundColor(.red)
            .titleFont(.systemFont(ofSize: 12))
            .titleColor(.white, for: .normal)
            .borderColor(.white)
            .borderWidth(1)
            .clipsToBounds(true)
            .cornerRadius(7)
            .excute({ b in
                b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
            })
            .subject
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configerViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var top = stackView.topAnchor.constraint(equalTo: contentView.topAnchor)
    lazy var left = stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
    lazy var bottom = stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    lazy var right = stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
    lazy var height = stackView.heightAnchor.constraint(equalToConstant: 100)
    
    lazy var numberWidth = numberButton.widthAnchor.constraint(greaterThanOrEqualTo: numberButton.heightAnchor)
    lazy var numberHeight = numberButton.heightAnchor.constraint(equalToConstant: 10)
    lazy var numberCenterX = numberButton.centerXAnchor.constraint(equalTo: titleLabel.rightAnchor)
    lazy var numberTop = numberButton.topAnchor.constraint(equalTo: stackView.topAnchor)
    
    func configerViews() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        numberButton.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textAlignment = .center
        contentView.addSubview(stackView)
        contentView.addSubview(numberButton)
        
        
        NSLayoutConstraint.activate([top, left, bottom, right, height])
        NSLayoutConstraint.activate([
            numberTop,
            numberCenterX,
            numberHeight,
            numberWidth
        ])
        
        
        height.isActive = false
    }
    
    func configerNumber(number: Int?, height: CGFloat?, offset: CGPoint) {
        if let number = number, number != 0 {
            numberButton.isHidden = false
            numberButton.setTitle("\(number)", for: .normal)
        } else {
            numberButton.isHidden = true
        }
        numberHeight.constant = height ?? 0
        numberHeight.isActive = height != nil
        numberTop.constant = offset.y
        numberCenterX.constant = offset.x
        if let height = height {
            numberButton.cornerRadius = height / 2.0
        }
    }
}
