//
//  NormalAlertProtocol.swift
//  MyKit
//
//  Created by HanQi on 2021/3/23.
//

import Foundation
import UIKit

public enum NormalAlertStyle {
    case none
    case pop
    case sheetBottom
    case sheetRight
    case sheetTop
}

public protocol NormalAlertProtocol: UIViewController {
    
    var maskView: UIView! { get }
    
    var contentView: UIView! { get }
    
    func show(_ parent: UIViewController?, style: NormalAlertStyle, duration: TimeInterval)
    func hide(style: NormalAlertStyle, completion: (() -> Void)?)
    
}

public extension NormalAlertProtocol {
    
    func show(_ parent: UIViewController?, style: NormalAlertStyle, duration: TimeInterval = 0.2) {
        
        guard let parent = parent ?? UIViewController.top.viewController else {
            return
        }
        modalPresentationStyle = .overFullScreen
        animationDuration = duration
        
        switch style {
        case .none:
            showWithNone(parent: parent)
        case .pop:
            showWithPop(parent: parent)
        case .sheetBottom:
            showWithSheetBottom(parent: parent)
        case .sheetRight:
            showWithSheetRight(parent: parent)
        case .sheetTop:
            showWithSheetTop(parent: parent)
        }
        
    }
    
    func hide(style: NormalAlertStyle, completion: (() -> Void)? = nil) {
        switch style {
        case .none:
            hideWithNone(completion: completion)
        case .pop:
            hideWithPop(completion: completion)
        case .sheetBottom:
            hideWithSheetBottom(completion: completion)
        case .sheetRight:
            hideWithSheetRight(completion: completion)
        case .sheetTop:
            hideWithSheetTop(completion: completion)
        }
    }
}

fileprivate struct MTMAlertStyleAssociatedObjectByHQ {
    static var isExecutedAnimation = "MTMAlertStyleAssociatedObjectByHQ.isExecutedAnimation"
    static var alertAnimation = "MTMAlertStyleAssociatedObjectByHQ.alertAnimation"
    static var animationDuration = "MTMAlertStyleAssociatedObjectByHQ.animationDuration"
    static var isChanedViewDidLayoutSubviews = false
}

fileprivate extension UIViewController {
    var animationDuration: TimeInterval {
        get {
            objc_getAssociatedObject(self, &MTMAlertStyleAssociatedObjectByHQ.animationDuration) as? TimeInterval ?? 0
        }
        set {
            objc_setAssociatedObject(self, &MTMAlertStyleAssociatedObjectByHQ.animationDuration, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    
    var alertAnimation: (() -> Void)? {
        get {
            objc_getAssociatedObject(self, &MTMAlertStyleAssociatedObjectByHQ.alertAnimation) as? (() -> Void) ?? nil
        }
        set {
            changeViewDidLayoutSubviewsMethod()
            objc_setAssociatedObject(self, &MTMAlertStyleAssociatedObjectByHQ.alertAnimation, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    
    var isExecutedAnimation: Bool {
        get {
            objc_getAssociatedObject(self, &MTMAlertStyleAssociatedObjectByHQ.isExecutedAnimation) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &MTMAlertStyleAssociatedObjectByHQ.isExecutedAnimation, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    
    func changeViewDidLayoutSubviewsMethod( ) {
        if !MTMAlertStyleAssociatedObjectByHQ.isChanedViewDidLayoutSubviews {
            let originalSelector = #selector(viewDidLayoutSubviews)
            let swizzledSelector = #selector(hq_viewDidLayoutSubviews)
            
            let originalMethod = class_getInstanceMethod(UIViewController.classForCoder(), originalSelector)
            let swizzledMethod = class_getInstanceMethod(UIViewController.classForCoder(), swizzledSelector)
             
            let didAddMethod: Bool = class_addMethod(UIViewController.classForCoder(), originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
            if didAddMethod {
                class_replaceMethod(UIViewController.classForCoder(), swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
            } else {
                method_exchangeImplementations(originalMethod!, swizzledMethod!)
            }
            MTMAlertStyleAssociatedObjectByHQ.isChanedViewDidLayoutSubviews = true
        }
    }
    
    @objc func hq_viewDidLayoutSubviews() {
        hq_viewDidLayoutSubviews()
        if !isExecutedAnimation {
            isExecutedAnimation = true
            alertAnimation?()
        }
    }
}

// MARK: - NormalAlertStyle none
fileprivate extension NormalAlertProtocol {
    
    func showWithNone(parent: UIViewController) {
        parent.present(self, animated: false, completion: nil)
    }
    
    func hideWithNone(completion: (() -> Void)?) {
        dismiss(animated: false, completion: completion)
    }
    
}

// MARK: - NormalAlertStyle pop
fileprivate extension NormalAlertProtocol {
    
    func showWithPop(parent: UIViewController) {
        alertAnimation = { [weak self] in
            guard let self = self else { return }
            self.maskView.alpha = 0
            self.contentView.transform = .init(scaleX: 0.9, y: 0.9)
            UIView.animate(withDuration: self.animationDuration * 5 / 8.0) {
                self.maskView.alpha = 1
                self.contentView.transform = .init(scaleX: 1.05, y: 1.05)
            } completion: { (finish) in
                if finish {
                    UIView.animate(withDuration: self.animationDuration * 3 / 8.0) {
                        self.contentView.transform = .identity
                    }
                }
            }

        }
        parent.present(self, animated: false, completion: nil)
    }
    
    func hideWithPop(completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.8 * animationDuration, animations: {
            self.view.alpha = 0
        }) { (finished) in
            if finished {
                self.dismiss(animated: false, completion: completion)
            }
        }
    }
    
}

// MARK: - NormalAlertStyle sheetBottom
fileprivate extension NormalAlertProtocol {
    
    func showWithSheetBottom(parent: UIViewController) {
        alertAnimation = { [weak self] in
            guard let self = self else { return }
            self.maskView.alpha = 0
            self.contentView.transform = .init(translationX: 0, y: self.maskView.bounds.height - self.contentView.frame.origin.y)
            UIView.animate(withDuration: self.animationDuration) {
                self.maskView.alpha = 1
                self.contentView.transform = .identity
            }
        }
        parent.present(self, animated: false, completion: nil)
    }
    
    func hideWithSheetBottom(completion: (() -> Void)?) {
        UIView.animate(withDuration: animationDuration, animations: {
            self.maskView.alpha = 0
            self.contentView.transform = .init(translationX: 0, y: self.maskView.bounds.height - self.contentView.frame.origin.y)
        }) { (finished) in
            if finished {
                self.dismiss(animated: false, completion: completion)
            }
        }
    }
    
}

// MARK: - NormalAlertStyle sheetRight
fileprivate extension NormalAlertProtocol {
    
    func showWithSheetRight(parent: UIViewController) {
        alertAnimation = { [weak self] in
            guard let self = self else { return }
            self.maskView.alpha = 0
            self.contentView.transform = .init(translationX: self.maskView.frame.maxX - self.contentView.frame.maxX + self.contentView.bounds.width, y: 0)
            UIView.animate(withDuration: self.animationDuration) {
                self.maskView.alpha = 1
                self.contentView.transform = .identity
            }
        }
        parent.present(self, animated: false, completion: nil)
    }
    
    func hideWithSheetRight(completion: (() -> Void)?) {
        UIView.animate(withDuration: animationDuration, animations: {
            self.maskView.alpha = 0
            self.contentView.transform = .init(translationX: self.maskView.frame.maxX - self.contentView.frame.maxX + self.contentView.bounds.width, y: 0)
        }) { (finished) in
            if finished {
                self.dismiss(animated: false, completion: completion)
            }
        }
    }
    
}

// MARK: - NormalAlertStyle sheetTop
fileprivate extension NormalAlertProtocol {
    
    func showWithSheetTop(parent: UIViewController) {
        alertAnimation = { [weak self] in
            guard let self = self else { return }
            self.maskView.alpha = 0
            self.contentView.transform = .init(translationX: 0, y: self.maskView.frame.minY - self.contentView.frame.minY - self.contentView.frame.height)
            UIView.animate(withDuration: self.animationDuration) {
                self.maskView.alpha = 1
                self.contentView.transform = .identity
            }
        }
        parent.present(self, animated: false, completion: nil)
    }
    
    func hideWithSheetTop(completion: (() -> Void)?) {
        UIView.animate(withDuration: animationDuration, animations: {
            self.maskView.alpha = 0
            self.contentView.transform = .init(translationX: 0, y: self.maskView.frame.minY - self.contentView.frame.minY - self.contentView.frame.height)
        }) { (finished) in
            if finished {
                self.dismiss(animated: false, completion: completion)
            }
        }
    }
    
}
