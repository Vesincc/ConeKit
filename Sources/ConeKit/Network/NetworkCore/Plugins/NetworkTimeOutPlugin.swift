//
//  NetworkTimeOutPlugin.swift
//  CaptionsKit
//
//  Created by HanQi on 2021/5/28.
//

import Foundation

public struct NetworkTimeOutPlugin {
    public init() {
        
    }
}

extension NetworkTimeOutPlugin: PluginType {
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.timeoutInterval = target.timeOut
        return request
    }
    
}
