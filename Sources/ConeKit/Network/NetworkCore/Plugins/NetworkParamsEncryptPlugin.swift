//
//  NetworkParamsEncryptPlugin.swift
//  CaptionsKit
//
//  Created by HanQi on 2021/5/28.
//

import Foundation

public class NetworkParamsEncryptPlugin {
    public init(encryptBlock: @escaping ([String : Any], TargetType) -> [String : Any], decryptBlock: @escaping (Data, TargetType) -> [String : Any]) {
        self.encryptBlock = encryptBlock
        self.decryptBlock = decryptBlock
    }

    public let encryptBlock: ([String : Any], TargetType) -> [String : Any]
    
    public let decryptBlock: (Data, TargetType) -> [String : Any]
}
 
extension NetworkParamsEncryptPlugin: PluginType {
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        switch target.task {
        case .requestParameters(parameters: let params, encoding: let encoding):
            let encrypted = try? request.encoded(parameters: encryptBlock(params, target), parameterEncoding: encoding)
            return encrypted ?? request
        default:
            return request
        }
    }
    
    public func process(_ result: Result<Response, NetworkError>, target: TargetType) -> Result<Response, NetworkError> {
        switch result {
        case .success(let response):
            response.object = decryptBlock(response.data, target)
            return .success(response)
        case .failure(let error):
            return .failure(error)
        }
    }
    
}
