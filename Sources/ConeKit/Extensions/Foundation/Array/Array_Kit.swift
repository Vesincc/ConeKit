//
//  Array_Kit.swift
//  InstagramFontsKit
//
//  Created by HanQi on 2021/4/8.
//

import Foundation

public extension Array {
    
    // 安全取值
    subscript(safe index: Int) -> Element? {
        return (0 ..< count).contains(index) ? self[index] : nil
    }
    
    func random(_ randomCount: Int) -> [Element] {
        var temp: [Element] = self
        var result: [Element] = []
        if isEmpty {
            return result
        }
        let minCount = Swift.min(count, randomCount)
        for _ in 0 ..< minCount {
            result.append(temp.remove(at: Int.random(in: 0 ..< temp.count)))
        }
        return result
    }
}

public extension Array where Element: Hashable {
    /// 是否有相同元素
    /// - Parameter array: [Element]
    /// - Returns: true 有
    func sameElement(_ array: Self) -> Bool {
        var seen: Set<Element> = []
        seen.formSymmetricDifference(Set(array))
        seen.formSymmetricDifference(Set(self))
        return seen.count != 0
    }
}

public extension Array where Element == String {
    
    func split(with str: String) -> String {
        var temp = ""
        self.forEach { t in
            if !t.isEmpty {
                if temp.isEmpty {
                    temp += t
                } else {
                    temp += "\(str)\(t)"
                }
            }
        }
        return temp
    }
    
    func firstNoEmptyValue() -> String {
        var res = ""
        for t in self {
            if !t.isEmpty {
                res = t
                break
            }
        }
        return res
    }
    
}
