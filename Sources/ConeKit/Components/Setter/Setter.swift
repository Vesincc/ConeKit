//
//  File.swift
//  
//
//  Created by HanQi on 2022/2/22.
//

import Foundation
import UIKit

@dynamicMemberLookup
public struct Setter<Subject> {
    
    public init(_ subject: Subject) {
        self.subject = subject
    }
    
    public let subject: Subject
     
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Subject, Value>) -> ((Value) -> Setter<Subject>) {
        var subject = self.subject
        return { value in
            subject[keyPath: keyPath] = value
            return Setter(subject)
        }
    }
    
    public func excute(_ callback: (Subject) -> ()) -> Setter<Subject> {
        callback(self.subject)
        return Setter(subject)
    }
    
    public func apply() {
    }
}

public extension Setter where Subject: UIButton {
     
    func target(_ target: Any?, action: Selector, for event: UIControl.Event) -> Setter<Subject> {
        subject.addTarget(target, action: action, for: event)
        return Setter(subject)
    }
    
    func titleText(_ text: String?, for state: UIControl.State) -> Setter<Subject> {
        subject.setTitle(text, for: state)
        if subject.title(for: .highlighted) == nil {
            if state == .normal {
                subject.setTitle(text, for: [.normal, .highlighted])
            } else if state == .selected {
                subject.setTitle(text, for: [.selected, .highlighted])
            }
        }
        return Setter(subject)
    }
     
    func titleColor(_ color: UIColor?, for state: UIControl.State) -> Setter<Subject> {
        subject.setTitleColor(color, for: state)
        if subject.titleColor(for: .highlighted) == nil {
            if state == .normal {
                subject.setTitleColor(color, for: [.normal, .highlighted])
            } else if state == .selected {
                subject.setTitleColor(color, for: [.selected, .highlighted])
            }
        }
        return Setter(subject)
    }
     
    func titleFont(_ font: UIFont) -> Setter<Subject> {
        subject.titleLabel?.font = font
        return Setter(subject)
    }
     
    func titleNumberOfLines(_ number: Int) -> Setter<Subject> {
        subject.titleLabel?.numberOfLines = number
        return Setter(subject)
    }
     
    func titleLineBreakMode(_ mode: NSLineBreakMode) -> Setter<Subject> {
        subject.titleLabel?.lineBreakMode = mode
        return Setter(subject)
    }
     
    func attributedTitle(_ title: NSAttributedString?, for state: UIControl.State) -> Setter<Subject> {
        subject.setAttributedTitle(title, for: state)
        if subject.title(for: .highlighted) == nil {
            if state == .normal {
                subject.setAttributedTitle(title, for: [.normal, .highlighted])
            } else if state == .selected {
                subject.setAttributedTitle(title, for: [.selected, .highlighted])
            }
        }
        return Setter(subject)
    }
     
    func image(_ image: UIImage?, for state: UIControl.State) -> Setter<Subject> {
        subject.setImage(image, for: .normal)
        if subject.image(for: .highlighted) == nil {
            if state == .normal {
                subject.setImage(image, for: [.normal, .highlighted])
            } else if state == .selected {
                subject.setImage(image, for: [.selected, .highlighted])
            }
        }
        return Setter(subject)
    }
      
    func imageContentMode(_ mode: UIView.ContentMode) -> Setter<Subject> {
        subject.imageView?.contentMode = mode
        return Setter(subject)
    }
     
    func backgroundImage(_ image: UIImage?, for state: UIControl.State) -> Setter<Subject> {
        subject.setBackgroundImage(image, for: .normal)
        return Setter(subject)
    }
    
}
