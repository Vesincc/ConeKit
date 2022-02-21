//
//  PageControl.swift
//  CaptionsKit
//
//  Created by HanQi on 2021/6/2.
//

import Foundation
import UIKit

fileprivate let defaultPageIndicatorTintColor: UIColor = .gray
fileprivate let defaultCurrentPageIndicatorTintColor: UIColor = .white
fileprivate let defaultPageIndicatorSize: CGSize = .init(width: 6, height: 6)

open class PageControl: UIControl {
    
    // default is 0
    open var numberOfPages: Int = 0 {
        didSet {
            setNeedsUpdateIndicator()
            updateIndicatorIfNeeded()
        }
    }
    
    // default is 0. value pinned to 0..numberOfPages-1
    open var currentPage: Int = 0 {
        didSet {
            if currentPage >= numberOfPages {
                currentPage = numberOfPages - 1
                setCurrentPage(currentPage)
            } else {
                setCurrentPage(currentPage)
            }
        }
    }
    
    // hide the the indicator if there is only one page. default is false
    open var hidesForSinglePage: Bool = false
    
    // default is 10
    open var pageIndicatorSpacing: CGFloat = 10
    
    open var axis: NSLayoutConstraint.Axis = .horizontal {
        didSet {
            stackView.axis = axis
        }
    }
    
    open var alignment: UIStackView.Alignment = .center {
        didSet {
            stackView.alignment = alignment
        }
    }
    
    var stackViewTopConstraint: NSLayoutConstraint?
    var stackViewLeftConstraint: NSLayoutConstraint?
    var stackViewRightConstraint: NSLayoutConstraint?
    var stackViewBottomConstraint: NSLayoutConstraint?
    var stackViewCenterXConstraint: NSLayoutConstraint?
    var stackViewCenterYConstraint: NSLayoutConstraint?
    
    open var contentEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            setStackViewConstraints()
        }
    }
    
    open var pageIndicatorImageContentMode: UIView.ContentMode = .scaleToFill {
        didSet {
            indicatorImageViews.forEach { (m) in
                m.contentMode = pageIndicatorImageContentMode
            }
        }
    }
    
    // normal indicator
    open var pageIndicatorTintColor: UIColor?
    open var pageIndicatorImage: UIImage?
    // default is size(6, 6)
    open var pageIndicatorSize: CGSize?
    open var pageIndicatorCornerRadius: CGFloat?
    
    // current indicator
    open var currentPageIndicatorTintColor: UIColor?
    open var currentPageIndicatorImage: UIImage?
    open var currentPageIndicatorSize: CGSize?
    open var currentPageIndicatorCornerRadius: CGFloat?
    
    open var animateDuring: CGFloat = 0.3
    
    private func setCurrentPage(_ page: Int) {
        updateIndicatorStyle()
    }
    
    private var indicatorImageViews: [UIImageView] = []
    private let stackView = UIStackView.init()
    // 需要全部更新
    private var needUpdateIndicator = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
         
        setStackViewConstraints()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStackViewConstraints() {
        if let top = stackViewTopConstraint,
           let left = stackViewLeftConstraint,
           let bottom = stackViewBottomConstraint,
           let right = stackViewRightConstraint,
           let x = stackViewCenterXConstraint,
           let y = stackViewCenterYConstraint {
            stackView.removeConstraints([top, left, right, bottom, x, y])
        }
        stackViewTopConstraint = NSLayoutConstraint.init(item: stackView, attribute: .top, relatedBy: .equal, toItem: stackView.superview, attribute: .top, multiplier: 1, constant: contentEdgeInsets.top)
        stackViewTopConstraint?.priority = .defaultLow
        stackViewLeftConstraint = NSLayoutConstraint.init(item: stackView, attribute: .left, relatedBy: .equal, toItem: stackView.superview, attribute: .left, multiplier: 1, constant: contentEdgeInsets.left)
        stackViewLeftConstraint?.priority = .defaultLow
        stackViewRightConstraint = NSLayoutConstraint.init(item: stackView, attribute: .right, relatedBy: .equal, toItem: stackView.superview, attribute: .right, multiplier: 1, constant: contentEdgeInsets.right)
        stackViewRightConstraint?.priority = .defaultLow
        stackViewBottomConstraint = NSLayoutConstraint.init(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: stackView.superview, attribute: .bottom, multiplier: 1, constant: contentEdgeInsets.bottom)
        stackViewBottomConstraint?.priority = .defaultLow
        stackViewCenterXConstraint = .init(item: stackView, attribute: .centerX, relatedBy: .equal, toItem: stackView.superview, attribute: .centerX, multiplier: 1, constant: 0)
        stackViewCenterYConstraint = .init(item: stackView, attribute: .centerY, relatedBy: .equal, toItem: stackView.superview, attribute: .centerY, multiplier: 1, constant: 0)
        
        stackView.superview?.addConstraints([stackViewTopConstraint!, stackViewLeftConstraint!, stackViewBottomConstraint!, stackViewRightConstraint!, stackViewCenterXConstraint!, stackViewCenterYConstraint!])
    }
    
}

extension PageControl {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsUpdateIndicator()
        updateIndicatorIfNeeded()
    }
     
}

extension PageControl {
    
    private func setNeedsUpdateIndicator() {
        needUpdateIndicator = true
    }
    
    private func updateIndicatorIfNeeded() {
        guard needUpdateIndicator else { return }
        
        stackView.isHidden = numberOfPages == 1 && hidesForSinglePage
        stackView.spacing = pageIndicatorSpacing
        stackView.axis = axis
        stackView.alignment = alignment
        
        if stackView.arrangedSubviews.count != numberOfPages {
            if numberOfPages > indicatorImageViews.count {
                for _ in indicatorImageViews.count ..< numberOfPages {
                    indicatorImageViews.append(.init())
                }
            }
            
            stackView.removeSubviews()
            for i in 0 ..< numberOfPages {
                let indicator = indicatorImageViews[i]
                indicator.translatesAutoresizingMaskIntoConstraints = false
                stackView.addArrangedSubview(indicator)
                
                indicator.removeConstraints(indicator.constraints)
                let width = pageIndicatorSize?.width ?? pageIndicatorImage?.size.width ?? defaultPageIndicatorSize.width
                let height = pageIndicatorSize?.height ?? pageIndicatorImage?.size.height ?? defaultPageIndicatorSize.height
                indicator.addConstraints([
                    .init(item: indicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width),
                    .init(item: indicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
                ])
            }
        }
        updateIndicatorStyle()
        needUpdateIndicator = false
    }
    
    private func updateIndicatorStyle() {
        for (index, indicator) in stackView.arrangedSubviews.enumerated() {
            if let indicator = indicator as? UIImageView {
                indicator.backgroundColor = .clear
                if index == currentPage {
                    if let currentPageIndicatorImage = currentPageIndicatorImage {
                        let width = currentPageIndicatorSize?.width ?? currentPageIndicatorImage.size.width
                        let height = currentPageIndicatorSize?.height ?? currentPageIndicatorImage.size.height
                        indicator.image = currentPageIndicatorImage
                        indicator.contentMode = pageIndicatorImageContentMode
                        
                        
                        indicator.constraints.first(where: { $0.firstAttribute == .width })?.constant = width
                        indicator.constraints.first(where: { $0.firstAttribute == .height })?.constant = height
                        
                        indicator.addRoundedCorners(.allCorners, withRadii: .init(width: currentPageIndicatorCornerRadius ?? pageIndicatorCornerRadius ?? 0, height: currentPageIndicatorCornerRadius ?? pageIndicatorCornerRadius ?? 0), viewRect: .init(x: 0, y: 0, width: width, height: height))
                    } else {
                        let width = currentPageIndicatorSize?.width ?? pageIndicatorSize?.width ?? defaultPageIndicatorSize.width
                        let height = currentPageIndicatorSize?.height ?? pageIndicatorSize?.height ?? defaultPageIndicatorSize.height
                        indicator.backgroundColor = currentPageIndicatorTintColor ?? defaultCurrentPageIndicatorTintColor
                         
                        indicator.constraints.first(where: { $0.firstAttribute == .width })?.constant = width
                        indicator.constraints.first(where: { $0.firstAttribute == .height })?.constant = height
                        
                        let r = currentPageIndicatorCornerRadius ?? pageIndicatorCornerRadius ?? min(width, height) / 2.0
                        indicator.addRoundedCorners(.allCorners, withRadii: .init(width: r, height: r), viewRect: .init(x: 0, y: 0, width: width, height: height))
                         
                    }
                } else {
                    if let pageIndicatorImage = pageIndicatorImage {
                        let width = pageIndicatorSize?.width ?? pageIndicatorImage.size.width
                        let height = pageIndicatorSize?.height ?? pageIndicatorImage.size.height
                        indicator.image = pageIndicatorImage
                        indicator.contentMode = pageIndicatorImageContentMode
                         
                        indicator.constraints.first(where: { $0.firstAttribute == .width })?.constant = width
                        indicator.constraints.first(where: { $0.firstAttribute == .height })?.constant = height
                        
                        indicator.addRoundedCorners(.allCorners, withRadii: .init(width: pageIndicatorCornerRadius ?? 0, height: pageIndicatorCornerRadius ?? 0), viewRect: .init(x: 0, y: 0, width: width, height: height))
                    } else {
                        let width = pageIndicatorSize?.width ?? defaultPageIndicatorSize.width
                        let height = pageIndicatorSize?.height ?? defaultPageIndicatorSize.height
                        indicator.backgroundColor = pageIndicatorTintColor ?? defaultPageIndicatorTintColor
                         
                        indicator.constraints.first(where: { $0.firstAttribute == .width })?.constant = width
                        indicator.constraints.first(where: { $0.firstAttribute == .height })?.constant = height
                        
                        let r = pageIndicatorCornerRadius ?? min(width, height) / 2.0
                        indicator.addRoundedCorners(.allCorners, withRadii: .init(width: r, height: r), viewRect: .init(x: 0, y: 0, width: width, height: height))
                    }
                }
            }
        }
    }
    
}

