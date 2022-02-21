//
//  File.swift
//  
//
//  Created by HanQi on 2021/8/12.
//

import Foundation
import UIKit

public extension UIDevice {
    
    /// 倒计时
    /// - Parameters:
    ///   - repeatTimes: 重复次数
    ///   - spacing: 每次重复间隔
    ///   - timerInit: 初始化 返回总倒计时时间
    ///   - timerProgress: progress 返回剩余计时时间
    ///   - timerEnd: timerEnd
    static func countdown(_ repeatTimes: Int,
                          spacing: TimeInterval,
                          timerInit: ((_ countTime: Int) -> Void)? = nil,
                          timerProgress: ((_ lastTime: Int) -> Void)? = nil,
                          timerEnd: (() -> Void)? = nil) {
        
        // 倒计时总时间
        let countTime = repeatTimes * Int(spacing)
        let endTime = UIDevice.current.runingTimeDouble + Double(countTime)
        
        let timer = DispatchSource.makeTimerSource(flags: [], queue: .global())
        timer.setEventHandler {
            let timeSpacing = lround(endTime - UIDevice.current.runingTimeDouble)
            if timeSpacing == countTime {
                DispatchQueue.main.async {
                    timerInit?(countTime)
                }
            } else if timeSpacing > 0 {
                DispatchQueue.main.async {
                    timerProgress?(timeSpacing)
                }
            } else {
                timer.cancel()
                DispatchQueue.main.async {
                    timerEnd?()
                }
            }
        }
        timer.schedule(deadline: .now(), repeating: spacing, leeway: .milliseconds(300))
        timer.resume()
    }
    
}

public extension UIDevice {
    
    /// 设备运行时间 和修改时间无关
    var runningTime: Int {
        now() - boottime()
    }
    
    var runingTimeDouble: Double {
        let value = CACurrentMediaTime()
        let d = value - Double(Int(value))
        return Double(runningTime) + d
    }
    
    private func boottime() -> Int {
        var mid = [CTL_KERN, KERN_BOOTTIME]
        var boottime = timeval()
        var size = MemoryLayout.size(ofValue: boottime)
        if sysctl(&mid, 2, &boottime, &size, nil, 0) != -1 {
            return boottime.tv_sec
        }
        return 0
    }
    
    func now() -> Int {
        var now =  timeval()
        var tz = timezone()
        gettimeofday(&now, &tz)
        return now.tv_sec
    }
}
