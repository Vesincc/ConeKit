//
//  File.swift
//  
//
//  Created by HanQi on 2021/8/12.
//

import Foundation
import UIKit

public extension UIDevice {
    
    func language() -> (lang: String, langContry: String) {
        let defs = UserDefaults.standard
        let languages = defs.object(forKey: "AppleLanguages")//获取系统支持的所有语言集合
        let preferredLanguage = (languages! as! [String]).first
        if preferredLanguage == nil{
            return ("en","en_US")
        }
        
        if let code = Locale.current.regionCode {
            let codeStr = String(format: "-%@", code)
            let c = preferredLanguage!
            let languageCode = c.replacingOccurrences(of: codeStr, with: "")
            return (languageCode, c)
        }
        return ("en", "en_US")
    }
    
    func createANewUuid() -> String {
         UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    @Keychained(key: "UIDevice.current.uuid", defaultValue: "")
    private static var savedUUID: String
    
    var uuid: String {
        if Self.savedUUID.isEmpty {
            Self.savedUUID = createANewUuid()
        }
        return Self.savedUUID
    }
     
}

public extension UIDevice {
    
    ///设备信息
    var deviceName: String {
        var systemInfo = utsname();
        uname(&systemInfo);
        let machineMirror = Mirror(reflecting: systemInfo.machine);
        let id = machineMirror.children.reduce("") { (id, args) in
            guard let value = args.value as? Int8,
                  value != 0 else {
                return id;
            }
            return id + String(UnicodeScalar(UInt8(value)));
        }
        switch id {
        case "iPod5,1":
            return "iPod Touch 5";
        case "iPod7,1":
            return "iPod Touch 6";
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":
            return "iPhone 4";
        case "iPhone4,1":
            return "iPhone 4s";
        case "iPhone5,1","iPhone5,2":
            return "iPhone 5";
        case "iPhone5,3", "iPhone5,4":
            return "iPhone 5c";
        case "iPhone6,1", "iPhone6,2":
            return "iPhone 5s";
        case "iPhone7,2":
            return "iPhone 6";
        case "iPhone7,1":
            return "iPhone6 Plus";
        case "iPhone8,1":
            return "iPhone 6s";
        case "iPhone8,2":
            return "iPhone6s Plus";
        case "iPhone8,4":
            return "iPhoneSE"
        case "iPhone9,1", "iPhone9,3":
            return "iPhone 7";
        case "iPhone9,2", "iPhone9,4":
            return "iPhone7 Plus";
        case "iPhone10,1", "iPhone10,4":
            return "iPhone 8";
        case "iPhone10,5", "iPhone10,2":
            return "iPhone8 Plus";
        case "iPhone10,3", "iPhone10,6":
            return "iPhone X";
        case "iPhone11,2":
            return"iPhone XS";
        case "iPhone11,6":
            return"iPhone XS MAX";
        case "iPhone11,8":
            return "iPhone XR";
            
        case "iPhone12,1":
            return "iPhone 11";
        case "iPhone12,3":
            return "iPhone 11 Pro";
        case "iPhone12,5":
            return "iPhone 11 Pro Max";
        case "iPhone12,8":
            return "iPhone SE (2nd generation)";
            
        case "iPhone13,1":
            return "iPhone 12 mini";
        case "iPhone13,2":
            return "iPhone 12";
        case "iPhone13,3":
            return "iPhone 12 Pro";
        case "iPhone13,4":
            return "iPhone 12 Pro Max";
            
            
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
            return "iPad 2";
        case "iPad3,1", "iPad3,2", "iPad3,3":
            return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":
            return "iPad 4";
        case "iPad4,1", "iPad4,2", "iPad4,3":
            return "iPad Air";
        case"iPad5,3","iPad5,4":
            return"iPad Air 2";
        case "iPad2,5", "iPad2,6", "iPad2,7":
            return "iPad Mini";
        case "iPad4,4", "iPad4,5", "iPad4,6":
            return "iPad Mini 2";
        case "iPad4,7", "iPad4,8", "iPad4,9":
            return "iPad Mini 3";
        case"iPad5,1","iPad5,2":
            return"iPad Mini 4";
        case"iPad6,7","iPad6,8":
            return"iPad Pro";
        case"AppleTV5,3":
            return"Apple TV";
        case"i386","x86_64":
            return"Simulator";
        default:
            return id;
        }
    }
    
    /// 是否是模拟器
    var isSimulator: Bool {
        return UIDevice.current.deviceName == "Simulator"
    }
    
}
