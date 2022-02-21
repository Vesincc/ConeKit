//
//  File.swift
//  
//
//  Created by HanQi on 2021/9/2.
//

import Foundation
import UIKit

public class BlurEffectView : UIVisualEffectView {
    
    @IBInspectable var intensity: CGFloat = 0.1
    
    private var theEffect: UIVisualEffect?
    private var animator: UIViewPropertyAnimator?
      
    override init(effect: UIVisualEffect?) {
        theEffect = effect
        super.init(effect: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        theEffect = self.effect
        
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActiveNotification), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.effect = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func becomeActiveNotification() {
        draw(bounds)
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        effect = nil
        animator?.stopAnimation(true)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in
            self.effect = theEffect
        }
        animator?.fractionComplete = intensity
    }
    
}

