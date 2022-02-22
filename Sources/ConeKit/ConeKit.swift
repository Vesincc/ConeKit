import UIKit
public struct ConeKit {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}


class TempClass {
    
    func ddd() {
        
        Setter(UIButton())
            .titleText("ddd", for: .normal)
            .titleText("aaa", for: .selected)
            .titleFont(UIFont.systemFont(ofSize: 12))
            .target(self, action: #selector(temp), for: .touchUpInside)
            .contentEdgeInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            .imageEdgeInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            .titleColor(.red, for: .normal)
            .image(UIImage(named: "d"), for: .normal)
            .imageContentMode(.scaleToFill)
            .backgroundImage(UIImage(named: "c"), for: .normal)
            .cornerRadius(1)
            .apply()
        
        let label = Setter(UILabel())
            .text("ddd")
            .font(UIFont.systemFont(ofSize: 12))
            .textColor(UIColor.red)
            .subject
        
        let imageView = Setter(UIImageView())
            .image(UIImage(named: "ddd"))
            .contentMode(.scaleToFill)
            .subject
         
    }
    
    @objc func temp() {
        
    }
    
}
