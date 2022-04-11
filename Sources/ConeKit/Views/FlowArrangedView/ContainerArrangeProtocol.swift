//
//  ContainerArrangeProtocol.swift
//  TagDemo
//
//  Created by HanQi on 2021/9/18.
//

import Foundation
import UIKit

class ContainerContentView<SubType: UIView>: UIView, ContainerArrangeProtocol {
    
    var dataArray: [String] = [] {
        didSet {
            var initBlock = initSubviewBlock
            if initBlock == nil {
                initBlock = {
                    return SubType()
                }
            }
            guard let initBlock = initBlock else {
                return
            }
            arrangedSubviews.forEach { view in
                view.isHidden = true
            }
            if arrangedSubviews.count < dataArray.count {
                for _ in arrangedSubviews.count ..< dataArray.count {
                    addArrangedSubview(initBlock())
                }
            }
            for (index, _) in dataArray.enumerated() {
                let view = arrangedSubviews[index]
                view.tag = index
                view.isHidden = false
            }
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
     
    typealias T = SubType
    
    var horizontalSpacing: CGFloat = 3
    
    var verticalSpacing: CGFloat = 3
    
    var flowAlignment: ContainerAlignment = .leading
    var itemAlignment: ContainerAlignment = .center
    
    var numberOfLines: Int = 0
    
    var arrangedSubviews: [SubType] = []
    
    var minSize: CGSize = .zero
    var maxSize: CGSize = .zero
    
    var viewWillDisplayTitleAtIndex: ((SubType, String, Int) -> ())?
    var didSelectedViewTitleAtIndex: ((SubType, String, Int) -> ())?
    var addActionWithViewTitleAtIndex: ((SubType, String, Int) -> ())? = { view, title, index in
        if let button = view as? UIButton {
            button.setTitle(title, for: .normal)
            if button.allTargets.isEmpty {
                button.addTarget(ContainerContentView<SubType>.self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            }
        } else {
            if let label = view as? UILabel {
                label.text = title
            }
            if (view.gestureRecognizers ?? []).isEmpty {
                let tapGesture = UITapGestureRecognizer(target: ContainerContentView<SubType>.self, action: #selector(tapAction(_:)))
                view.addGestureRecognizer(tapGesture)
            }
        }
    }
    
    var initSubviewBlock: (() -> SubType)?
    
    var subviewsHeightChanged: ((CGFloat) -> ())?
    
    @objc func buttonAction(_ button: UIButton) {
        if let button = button as? SubType {
            didSelectedViewTitleAtIndex?(button, dataArray[button.tag], button.tag)
        }
    }
    
    @objc func tapAction(_ gesture: UITapGestureRecognizer) {
        if let view = gesture.view as? SubType {
            didSelectedViewTitleAtIndex?(view, dataArray[view.tag], view.tag)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subviewsHeightChanged?(reloadSubviews())
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 200, height: 200)
    }
    
}

public enum ContainerAlignment {
    
    case leading
    
    case trailing
    
    case center
    
    case top
    
    case bottom
     
}

protocol ContainerArrangeProtocol: UIView {
    associatedtype T: UIView
    
    var dataArray: [String] { get set }
    
    var horizontalSpacing: CGFloat { get set }
    
    var verticalSpacing: CGFloat { get set }
    
    var flowAlignment: ContainerAlignment { get set }
    var itemAlignment: ContainerAlignment { get set }
     
    var numberOfLines: Int { get set }
  
    var arrangedSubviews: [T] { get set }
    
    var minSize: CGSize { get set }
    var maxSize: CGSize { get set }
     
    var viewWillDisplayTitleAtIndex: ((T, String, Int) -> ())? { get set }
    var addActionWithViewTitleAtIndex: ((T, String, Int) -> ())? { get set }
    
    func addArrangedSubview(_ view: T)
    
    @discardableResult func reloadSubviews() -> CGFloat
     
}

extension ContainerArrangeProtocol {
 
    func addArrangedSubview(_ view: T) {
        if !arrangedSubviews.contains(view) {
            arrangedSubviews.append(view)
            addSubview(view)
        }
    }
    
    @discardableResult func reloadSubviews() -> CGFloat { 
        
        guard !arrangedSubviews.isEmpty else {
            return 0
        }
        
        var lineViews: [[T]] = []
        var lastView: T?
        var isEnd = false
        
        arrangedSubviews.enumerated().forEach { info in
            let view = info.element
            let index = info.offset
            guard !isEnd else {
                return
            }
            
            guard bounds.size.width != 0 else {
                isEnd = true
                return
            }
            
            guard !view.isHidden else { 
                return
            }
            
            if !dataArray.isEmpty {
                addAction(view: view, title: dataArray[index], index: view.tag)
                viewWillDisplayTitleAtIndex?(view, dataArray[index], view.tag)
            }
            let systemSize = view.systemLayoutSizeFitting(bounds.size)
            var sizeWidth = systemSize.width
            if minSize.width != 0 {
                sizeWidth = max(minSize.width, sizeWidth)
            }
            if maxSize.width != 0 {
                sizeWidth = min(maxSize.width, sizeWidth)
            }
            var sizeHeight = systemSize.height
            if minSize.height != 0 {
                sizeHeight = max(minSize.height, sizeHeight)
            }
            if maxSize.height != 0 {
                sizeHeight = min(maxSize.height, sizeHeight)
            }
            view.frame = CGRect(origin: .zero, size: .init(width: sizeWidth, height: sizeHeight))
            
            let width = min(view.bounds.width, bounds.width)
            let height = view.bounds.height
            let viewSize = CGSize(width: width, height: height)
            
            view.isHidden = false
            
            /// 第一个
            guard let last = lastView else {
                lineViews.append([view])
                view.frame = CGRect(origin: .zero, size: viewSize)
                lastView = view
                return
            }
            
            // 是否换行
            let isLineFeed = last.frame.maxX + horizontalSpacing + width > bounds.width
            
            guard numberOfLines == 0 ||
                    (numberOfLines != 0 && (lineViews.count < numberOfLines || lineViews.count == numberOfLines && !isLineFeed)) else {
                view.isHidden = true
                isEnd = true
                return
            }
            
            // 换行
            if isLineFeed {
                if let maxView = lineViews[lineViews.count - 1].max(by: { $0.frame.maxY < $1.frame.maxY }) {
                    view.frame = CGRect(origin: CGPoint(x: 0, y: maxView.frame.maxY + verticalSpacing), size: viewSize)
                }
                lineViews.append([view])
            } else {
                /// 不换行
                lineViews[lineViews.count - 1].append(view)
                view.frame = CGRect(origin: CGPoint(x: last.frame.maxX + horizontalSpacing, y: last.frame.minY), size: viewSize)
            }
            lastView = view
        }
        
        loadFlowAlignment(views: lineViews)
        guard !lineViews.isEmpty else {
            return 0
        }
        
        let maxView = lineViews[lineViews.count - 1].max(by: { $0.frame.maxY < $1.frame.maxY })
        return maxView?.frame.maxY ?? 0
    }
    
    func loadFlowAlignment(views: [[T]]) {
        switch flowAlignment {
        case .leading:
            break
        case .center:
            views.forEach { rowViews in
                if let rowLast = rowViews.last {
                    let trans = (bounds.size.width - rowLast.frame.maxX) / 2
                    rowViews.forEach { view in
                        view.frame = view.frame.offsetBy(dx: trans, dy: 0)
                    }
                }
            }
        case .trailing:
            views.forEach { rowViews in
                if let rowLast = rowViews.last {
                    let trans = (bounds.size.width - rowLast.frame.maxX)
                    rowViews.forEach { view in
                        view.frame = view.frame.offsetBy(dx: trans, dy: 0)
                    }
                }
            }
        default:
            break
        }
        
        switch itemAlignment {
        case .top:
            break
        case .center:
            views.forEach { rowViews in
                if let rowMaxY = rowViews.max(by: { $0.frame.maxY < $1.frame.maxY }) {
                    rowViews.forEach { view in
                        let trans = (rowMaxY.frame.maxY - view.frame.maxY) / 2
                        view.frame = view.frame.offsetBy(dx: 0, dy: trans)
                    }
                }
            }
        case .bottom:
            views.forEach { rowViews in
                if let rowMaxY = rowViews.max(by: { $0.frame.maxY < $1.frame.maxY }) {
                    rowViews.forEach { view in
                        let trans = (rowMaxY.frame.maxY - view.frame.maxY) 
                        view.frame = view.frame.offsetBy(dx: 0, dy: trans)
                    }
                }
            }
        default:
            break
        }
    }
    
    
    func addAction(view: T, title: String, index: Int) {
        addActionWithViewTitleAtIndex?(view, title, index)
    }
    
}
