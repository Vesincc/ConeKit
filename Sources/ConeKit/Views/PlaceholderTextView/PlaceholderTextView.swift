//
//  File.swift
//  
//
//  Created by HanQi on 2022/8/16.
//

import UIKit

class PlaceholderTextView: UITextView {
     
    
    @IBInspectable var placeholderColor: UIColor? {
        get {
            placeholderLabel.textColor
        }
        set {
            placeholderLabel.textColor = newValue
        }
    }
    
    @IBInspectable var placeholder: String? {
        get {
            placeholderLabel.text
        }
        set {
            if let new = newValue {
                placeholderLabel.text = NSLocalizedString(new, comment: new)
            } else {
                placeholderLabel.text = newValue
            }
        }
    }
    
    var placeholderFont: UIFont?
    
    var placeholderLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        return l
    }()
     
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configerViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configerViews()
    }
    
    func configerViews() {
        addSubview(placeholderLabel)
        textContainer.lineFragmentPadding = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged(noti:)), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.font = placeholderFont ?? self.font
        let rect = bounds.inset(by: textContainerInset)
        let size = placeholderLabel.sizeThatFits(rect.size)
        placeholderLabel.frame = CGRect(origin: rect.origin, size: size)
    }
    
    @objc func textChanged(noti: Notification) {
        guard let textView = noti.object as? PlaceholderTextView, textView == self else {
            return
        }
        placeholderLabel.isHidden = !(textView.text ?? "").isEmpty
    }

}
