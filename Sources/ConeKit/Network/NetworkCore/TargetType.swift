//
//  TargetType.swift
//  CaptionsKit
//
//  Created by HanQi on 2021/5/25.
//

import Foundation

public protocol TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL { get }

    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }

    /// The HTTP method used in the request.
    var method: Method { get }

    /// The type of HTTP task to be performed.
    var task: Task { get }

    /// The headers to be used in the request.
    var headers: [String: String]? { get }

    /// The type of validation to perform on the request. Default is `.none`.
    var validationType: ValidationType { get }
    
    var timeOut: TimeInterval { get }
    
    var encryptAvailable: Bool { get }
    
}

public extension TargetType {

    /// The type of validation to perform on the request. Default is `.none`.
    var validationType: ValidationType {
        return .none
    }
}

public extension Method {
    /// A Boolean value determining whether the request supports multipart.
    var supportsMultipart: Bool {
        switch self {
        case .post, .put, .patch, .connect:
            return true
        default:
            return false
        }
    }
}
