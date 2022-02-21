//
//  NetworkProvider_Internal.swift
//  CaptionsKit
//
//  Created by HanQi on 2021/5/25.
//

import Foundation

extension NetworkProvider {
    
    func requestNormal(_ target: Target, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping Completion) -> Cancellable {
        let endpoint = self.endpointClosure(target)
        let cancellableToken = CancellableWrapper()

        // Allow plugins to modify response
        let pluginsWithCompletion: Completion = { result in
            let processedResult = self.plugins.reduce(result) { $1.process($0, target: target) }
            completion(processedResult)
        }

        if trackInflights {
            lock.lock()
            var inflightCompletionBlocks = self.inflightRequests[endpoint]
            inflightCompletionBlocks?.append(pluginsWithCompletion)
            self.inflightRequests[endpoint] = inflightCompletionBlocks
            lock.unlock()

            if inflightCompletionBlocks != nil {
                return cancellableToken
            } else {
                lock.lock()
                self.inflightRequests[endpoint] = [pluginsWithCompletion]
                lock.unlock()
            }
        }

        let performNetworking = { (requestResult: Result<URLRequest, NetworkError>) in
            if cancellableToken.isCancelled {
                self.cancelCompletion(pluginsWithCompletion, target: target)
                return
            }

            var request: URLRequest!

            switch requestResult {
            case .success(let urlRequest):
                request = urlRequest
            case .failure(let error):
                pluginsWithCompletion(.failure(error))
                return
            }

            let networkCompletion: Completion = { result in
              if self.trackInflights {
                self.inflightRequests[endpoint]?.forEach { $0(result) }

                self.lock.lock()
                self.inflightRequests.removeValue(forKey: endpoint)
                self.lock.unlock()
              } else {
                pluginsWithCompletion(result)
              }
            }

            cancellableToken.innerCancellable = self.performRequest(target, request: request, callbackQueue: callbackQueue, progress: progress, completion: networkCompletion, endpoint: endpoint)
        }

        requestClosure(endpoint, performNetworking)

        return cancellableToken
    }
    
    func cancelCompletion(_ completion: Completion, target: Target) {
        let error = NetworkError.underlying(NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil), nil)
        plugins.forEach { $0.didReceive(.failure(error), target: target) }
        completion(.failure(error))
    }
    
    private func performRequest(_ target: Target, request: URLRequest, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping Completion, endpoint: Endpoint) -> Cancellable {
        switch endpoint.task {
        case .requestPlain, .requestData, .requestJSONEncodable, .requestCustomJSONEncodable, .requestParameters, .requestCompositeData, .requestCompositeParameters:
            return self.sendRequest(target, request: request, callbackQueue: callbackQueue, progress: progress, completion: completion)
        case .uploadFile(let file):
            return self.sendUploadFile(target, request: request, callbackQueue: callbackQueue, file: file, progress: progress, completion: completion)
        case .uploadMultipart(let multipartBody), .uploadCompositeMultipart(let multipartBody, _):
            guard !multipartBody.isEmpty && endpoint.method.supportsMultipart else {
                fatalError("\(target) is not a multipart upload target.")
            }
            return self.sendUploadMultipart(target, request: request, callbackQueue: callbackQueue, multipartBody: multipartBody, progress: progress, completion: completion)
        case .downloadDestination(let destination), .downloadParameters(_, _, let destination):
            return self.sendDownloadRequest(target, request: request, callbackQueue: callbackQueue, destination: destination, progress: progress, completion: completion)
        }
    }
}

extension NetworkProvider {
    
    private func interceptor(target: Target) -> NetworkRequestInterceptor {
        return NetworkRequestInterceptor(prepare: { [weak self] urlRequest in
            return self?.plugins.reduce(urlRequest) { $1.prepare($0, target: target) } ?? urlRequest
        })
    }

    private func setup(interceptor: NetworkRequestInterceptor, with target: Target, and request: Request) {
        interceptor.willSend = { [weak self, weak request] urlRequest in
            guard let self = self, let request = request else { return }

            let stubbedAlamoRequest = RequestTypeWrapper(request: request, urlRequest: urlRequest)
            self.plugins.forEach { $0.willSend(stubbedAlamoRequest, target: target) }
        }
    }
    
    func sendUploadMultipart(_ target: Target, request: URLRequest, callbackQueue: DispatchQueue?, multipartBody: [MultipartFormData], progress: ProgressBlock? = nil, completion: @escaping Completion) -> CancellableToken {
        let formData = RequestMultipartFormData()
        formData.applyNetworkMultipartFormData(multipartBody)

        let interceptor = self.interceptor(target: target)
        let request = session.upload(multipartFormData: formData, with: request, interceptor: interceptor)
        setup(interceptor: interceptor, with: target, and: request)

        let validationCodes = target.validationType.statusCodes
        let validatedRequest = validationCodes.isEmpty ? request : request.validate(statusCode: validationCodes)
        return sendAlamofireRequest(validatedRequest, target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }

    func sendUploadFile(_ target: Target, request: URLRequest, callbackQueue: DispatchQueue?, file: URL, progress: ProgressBlock? = nil, completion: @escaping Completion) -> CancellableToken {
        let interceptor = self.interceptor(target: target)
        let uploadRequest = session.upload(file, with: request, interceptor: interceptor)
        setup(interceptor: interceptor, with: target, and: uploadRequest)

        let validationCodes = target.validationType.statusCodes
        let alamoRequest = validationCodes.isEmpty ? uploadRequest : uploadRequest.validate(statusCode: validationCodes)
        return sendAlamofireRequest(alamoRequest, target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }

    func sendDownloadRequest(_ target: Target, request: URLRequest, callbackQueue: DispatchQueue?, destination: @escaping DownloadDestination, progress: ProgressBlock? = nil, completion: @escaping Completion) -> CancellableToken {
        let interceptor = self.interceptor(target: target)
        let downloadRequest = session.download(request, interceptor: interceptor, to: destination)
        setup(interceptor: interceptor, with: target, and: downloadRequest)

        let validationCodes = target.validationType.statusCodes
        let alamoRequest = validationCodes.isEmpty ? downloadRequest : downloadRequest.validate(statusCode: validationCodes)
        return sendAlamofireRequest(alamoRequest, target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func sendRequest(_ target: Target, request: URLRequest, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping Completion) -> CancellableToken {
        let interceptor = self.interceptor(target: target)
        let initialRequest = session.request(request, interceptor: interceptor)
        setup(interceptor: interceptor, with: target, and: initialRequest)

        let validationCodes = target.validationType.statusCodes
        let alamoRequest = validationCodes.isEmpty ? initialRequest : initialRequest.validate(statusCode: validationCodes)
        return sendAlamofireRequest(alamoRequest, target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func sendAlamofireRequest<T>(_ alamoRequest: T, target: Target, callbackQueue: DispatchQueue?, progress progressCompletion: ProgressBlock?, completion: @escaping Completion) -> CancellableToken where T: Requestable, T: Request {
        // Give plugins the chance to alter the outgoing request
        let plugins = self.plugins
        var progressAlamoRequest = alamoRequest
        let progressClosure: (Progress) -> Void = { progress in
            let sendProgress: () -> Void = {
                progressCompletion?(ProgressResponse(progressObject: progress))
            }

            if let callbackQueue = callbackQueue {
                callbackQueue.async(execute: sendProgress)
            } else {
                sendProgress()
            }
        }

        // Perform the actual request
        if progressCompletion != nil {
            switch progressAlamoRequest {
            case let downloadRequest as DownloadRequest:
                if let downloadRequest = downloadRequest.downloadProgress(closure: progressClosure) as? T {
                    progressAlamoRequest = downloadRequest
                }
            case let uploadRequest as UploadRequest:
                if let uploadRequest = uploadRequest.uploadProgress(closure: progressClosure) as? T {
                    progressAlamoRequest = uploadRequest
                }
            case let dataRequest as DataRequest:
                if let dataRequest = dataRequest.downloadProgress(closure: progressClosure) as? T {
                    progressAlamoRequest = dataRequest
                }
            default: break
            }
        }

        let completionHandler: RequestableCompletion = { response, request, data, error in
            let result = convertResponseToResult(response, request: request, data: data, error: error)
            // Inform all plugins about the response
            plugins.forEach { $0.didReceive(result, target: target) }
            if let progressCompletion = progressCompletion {
                let value = try? result.get()
                switch progressAlamoRequest {
                case let downloadRequest as DownloadRequest:
                    progressCompletion(ProgressResponse(response: value, progressObject: downloadRequest.downloadProgress))
                case let uploadRequest as UploadRequest:
                    progressCompletion(ProgressResponse(response: value, progressObject: uploadRequest.uploadProgress))
                case let dataRequest as DataRequest:
                    progressCompletion(ProgressResponse(response: value, progressObject: dataRequest.downloadProgress))
                default:
                    progressCompletion(ProgressResponse(response: value))
                }
            }
            completion(result)
        }

        progressAlamoRequest = progressAlamoRequest.response(callbackQueue: callbackQueue, completionHandler: completionHandler)

        progressAlamoRequest.resume()

        return CancellableToken(request: progressAlamoRequest)
    }
    
}

/// A public function responsible for converting the result of a `URLRequest` to a Result<Response, Error>.
public func convertResponseToResult(_ response: HTTPURLResponse?, request: URLRequest?, data: Data?, error: Swift.Error?) ->
    Result<Response, NetworkError> {
        switch (response, data, error) {
        case let (.some(response), data, .none):
            let response = Response(statusCode: response.statusCode, data: data ?? Data(), request: request, response: response)
            return .success(response)
        case let (.some(response), _, .some(error)):
            let response = Response(statusCode: response.statusCode, data: data ?? Data(), request: request, response: response)
            let error = NetworkError.underlying(error, response)
            return .failure(error)
        case let (_, _, .some(error)):
            let error = NetworkError.underlying(error, nil)
            return .failure(error)
        default:
            let error = NetworkError.underlying(NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil), nil)
            return .failure(error)
        }
}
