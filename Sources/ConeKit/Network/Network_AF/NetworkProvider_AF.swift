//
//  NetworkProvider_AF.swift
//  CaptionsKit
//
//  Created by HanQi on 2021/5/25.
//

import Foundation

public extension NetworkProvider {
    
    final class func AFEndpointMapping(for target: Target) -> Endpoint {
        return Endpoint(url: URL.init(target: target).absoluteString,
                        method: target.method,
                        task: target.task,
                        httpHeaderFields: target.headers)
    }
    
    final class func AFRequestMapping(for endpoint: Endpoint, closure: RequestResultClosure) {
        do {
            let urlRequest = try endpoint.urlRequest()
            closure(.success(urlRequest))
        } catch NetworkError.requestMapping(let url) {
            closure(.failure(NetworkError.requestMapping(url)))
        } catch NetworkError.parameterEncoding(let error) {
            closure(.failure(NetworkError.parameterEncoding(error)))
        } catch {
            closure(.failure(NetworkError.underlying(error, nil)))
        }
    }
    
    final class func AFSession() -> Session {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default

        return Session(configuration: configuration, startRequestsImmediately: false)
    }
    
}
