//
//  FlowArrangedView.swift
//  TagDemo
//
//  Created by HanQi on 2021/9/18.
//

import UIKit
  
open class FlowArrangedView<T: UIView>: UIView {
    
    open var dataArray: [String] = [] {
        didSet {
            contentView.dataArray = dataArray
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    open var contentEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            contentViewTopConstraint?.constant = contentEdgeInsets.top
            contentViewLeftConstraint?.constant = contentEdgeInsets.left
            contentViewBottomConstraint?.constant = -contentEdgeInsets.bottom
            contentViewRightConstraint?.constant = -contentEdgeInsets.right
        }
    }
    
    private let contentView = ContainerContentView<T>()
    
    private var contentViewTopConstraint: NSLayoutConstraint?
    private var contentViewLeftConstraint: NSLayoutConstraint?
    private var contentViewRightConstraint: NSLayoutConstraint?
    private var contentViewBottomConstraint: NSLayoutConstraint?
    
    private var contentHeightConstraint: NSLayoutConstraint?
    private var contentWidthConstraint: NSLayoutConstraint?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configerViews()
    }
     
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configerViews()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
//        contentHeightConstraint?.constant = contentView.reloadSubviews()
 
    }
    
}

public extension FlowArrangedView {
    
    var initSubviewBlock: (() -> T)? {
        get {
            contentView.initSubviewBlock
        }
        set {
            contentView.initSubviewBlock = newValue
        }
    }
    
    var horizontalSpacing: CGFloat {
        get {
            contentView.horizontalSpacing
        }
        set {
            contentView.horizontalSpacing = newValue
        }
    }
    
    var verticalSpacing: CGFloat {
        get {
            contentView.verticalSpacing
        }
        set {
            contentView.verticalSpacing = newValue
        }
    }
    
    var flowAlignment: ContainerAlignment {
        get {
            contentView.flowAlignment
        }
        set {
            contentView.flowAlignment = newValue
        }
    }
    
    var itemAlignment: ContainerAlignment {
        get {
            contentView.itemAlignment
        }
        set {
            contentView.itemAlignment = newValue
        }
    }
    
    var numberOfLines: Int {
        get {
            contentView.numberOfLines
        }
        set {
            contentView.numberOfLines = newValue
        }
    }
    
    var viewWillDisplayTitleAtIndex: ((T, String, Int) -> ())? {
        get {
            contentView.viewWillDisplayTitleAtIndex
        }
        set {
            contentView.viewWillDisplayTitleAtIndex = newValue
        }
    }
    
    var didSelectedViewTitleAtIndex: ((T, String, Int) -> ())? {
        get {
            contentView.didSelectedViewTitleAtIndex
        }
        
        set {
            contentView.didSelectedViewTitleAtIndex = newValue
        }
    }
    
    var minSize: CGSize {
        get {
            contentView.minSize
        }
        set {
            contentView.minSize = newValue
        }
    }
    
    var maxSize: CGSize {
        get {
            contentView.maxSize
        }
        set {
            contentView.maxSize = newValue
        }
    }
    
    func reloadArrangedSubview() {
        setNeedsLayout()
        layoutIfNeeded()
    }
}

private extension FlowArrangedView {
    
    func configerViews() {
        clipsToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView) 
        
        contentViewTopConstraint = NSLayoutConstraint.init(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: contentEdgeInsets.top)
        contentViewTopConstraint?.priority = .init(751)
        contentViewLeftConstraint = NSLayoutConstraint.init(item: contentView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: contentEdgeInsets.left)
        contentViewLeftConstraint?.priority = .init(1000)
        contentViewRightConstraint = NSLayoutConstraint.init(item: contentView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -contentEdgeInsets.right)
        contentViewRightConstraint?.priority = .init(1000)
        contentViewBottomConstraint = NSLayoutConstraint.init(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -contentEdgeInsets.bottom)
        contentViewBottomConstraint?.priority = .init(750)
        
        contentWidthConstraint = NSLayoutConstraint.init(item: contentView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
        contentWidthConstraint?.priority = .init(1000)
        
        contentHeightConstraint = NSLayoutConstraint.init(item: contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
        
        addConstraints([contentViewTopConstraint!, contentViewLeftConstraint!, contentViewBottomConstraint!, contentViewRightConstraint!, contentHeightConstraint!, contentWidthConstraint!])
        
        
        contentView.subviewsHeightChanged = { [weak self] contentHeight in
            self?.contentHeightConstraint?.constant = contentHeight
            self?.setNeedsLayout()
            self?.layoutIfNeeded() 
        }
    }
    
}
