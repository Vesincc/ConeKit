//
//  Response.swift
//  CaptionsKit
//
//  Created by HanQi on 2021/5/25.
//

import Foundation

// MARK: - Response
public class Response {
    
    internal init(statusCode: Int, data: Data, request: URLRequest?, response: HTTPURLResponse?) {
        self.statusCode = statusCode
        self.data = data
        self.request = request
        self.response = response
    }
      
    
    public let statusCode: Int
    
    public let data: Data
    
    public var object: [String : Any] = [:]
    
    public let request: URLRequest?
    
    public let response: HTTPURLResponse?
    
}

extension Response: CustomDebugStringConvertible {
    
    var description: String {
        return "Status Code: \(statusCode), Data Length: \(data.count)"
    }
    
    public var debugDescription: String {
        description
    }
    
}

extension Response: Equatable {
    
    public static func == (lhs: Response, rhs: Response) -> Bool {
        lhs.statusCode == rhs.statusCode &&
            lhs.data == rhs.data &&
            lhs.response == rhs.response
    }
}

// MARK: - ProgressResponse
public struct ProgressResponse {
    
    internal init(response: Response? = nil, progressObject: Progress? = nil) {
        self.response = response
        self.progressObject = progressObject
    }
    
    
    let response: Response?
    
    let progressObject: Progress?
    
}

extension ProgressResponse {
    
    public var completed: Bool {
        return response != nil
    }
    
    public var progress: Double {
        if completed {
            return 1.0
        } else if let progressObject = progressObject, progressObject.totalUnitCount > 0 {
            return progressObject.fractionCompleted
        } else {
            return 0.0
        }
    }
    
}
