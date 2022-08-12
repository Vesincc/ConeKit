//
//  File.swift
//  
//
//  Created by HanQi on 2021/9/2.
//

import Foundation
import UIKit

fileprivate extension UIBlurEffect {
    class func effect(with radius: CGFloat) -> UIBlurEffect? {
        self.perform(NSSelectorFromString("effectWithBlurRadius:"), with: radius).takeUnretainedValue() as? UIBlurEffect
    }
}

open class BlurEffectView : UIVisualEffectView {
     
    @IBInspectable var radius: CGFloat = 20 {
        didSet {
            self.effect = UIBlurEffect.effect(with: radius)
        }
    }
     
    public init(radius: CGFloat) {
        self.radius = radius
        super.init(effect: UIBlurEffect.effect(with: radius))
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
         
    }
    
}

