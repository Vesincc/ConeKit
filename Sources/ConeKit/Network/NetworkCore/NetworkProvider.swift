//
//  NetworkProvider.swift
//  CaptionsKit
//
//  Created by HanQi on 2021/5/25.
//

import Foundation

public typealias Completion = (_ result: Result<Response, NetworkError>) -> ()

public typealias ProgressBlock = (_ progress: ProgressResponse) -> Void

public protocol NetworkProviderType: AnyObject {
    
    associatedtype Target: TargetType
    
    func request(_ target: Target, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping Completion)  -> Cancellable
}

public class NetworkProvider<Target: TargetType> {
    
    public init(endpointClosure: @escaping NetworkProvider<Target>.EndpointClosure = NetworkProvider.AFEndpointMapping,
                  requestClosure: @escaping NetworkProvider<Target>.RequestClosure = NetworkProvider.AFRequestMapping,
                  session: Session = AFSession(),
                  plugins: [PluginType] = [],
                  trackInflights: Bool = false,
                  callbackQueue: DispatchQueue? = nil) {
        self.endpointClosure = endpointClosure
        self.requestClosure = requestClosure
        self.session = session
        self.plugins = plugins
        self.trackInflights = trackInflights
        self.callbackQueue = callbackQueue
    }
    
    
    public typealias EndpointClosure = (Target) -> Endpoint
    
    public typealias RequestResultClosure = (_ result: Result<URLRequest, NetworkError>) -> ()
    
    public typealias RequestClosure = (Endpoint, @escaping RequestResultClosure) -> Void 
    
    let endpointClosure: EndpointClosure
    
    let requestClosure: RequestClosure
    
    let session: Session
    
    public let plugins: [PluginType]
    
    public let trackInflights: Bool

    open internal(set) var inflightRequests: [Endpoint: [Completion]] = [:]
    
    let callbackQueue: DispatchQueue?
    
    let lock: NSRecursiveLock = NSRecursiveLock()
    
}

extension NetworkProvider {
    
    open func endpoint(_ token: Target) -> Endpoint {
        return endpointClosure(token)
    }
    
}

extension NetworkProvider: NetworkProviderType {
     
    public func request(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping Completion) -> Cancellable {
        
        let callbackQueue = callbackQueue ?? self.callbackQueue
        return requestNormal(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
     
}
 
