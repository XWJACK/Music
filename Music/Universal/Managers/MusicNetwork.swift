//
//  MusicNetwork.swift
//  Music
//
//  Created by Jack on 5/8/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

/// Result for Response formatter
struct MusicAPIResult {
    public let code: Int
    public let result: JSON
}

extension JSON {
    /// Parse Code
    var code: Int { return self["code"].intValue }
    /// Parse Data
    var result: JSON { return self["result"] }
    /// Is Success for response
    var isSuccess: Bool { return code == 200 }
}

protocol JSONInitable {
    init(_ json: JSON)
}

extension JSONInitable {
    static func collection(_ json: JSON) -> [Self] {
        return json.map{ (_, itemJSON) in Self(itemJSON) }
    }
}

struct MusicResponse {
    var progressInstance = Progress() {
        didSet {
            progress?(progressInstance)
        }
    }
    var data = Data()
    
    var responseData: ((Data) -> ())? = nil
    var progress: ((Progress) -> ())? = nil
    
    var success: ((Data) -> ())? = nil
    var response: (() -> ())? = nil
    var download: ((URL) -> ())? = nil
    var failed: ((Error) -> ())? = { ConsoleLog.error($0) }
    
    init(responseData: ((Data) -> ())? = nil,
         progress: ((Progress) -> ())? = nil,
         response: (() -> ())? = nil,
         success: ((Data) -> ())? = nil,
         failed: ((Error) -> ())? = { ConsoleLog.error($0) },
         download: ((URL) -> ())? = nil) {
        
        self.responseData = responseData
        self.progress = progress
        self.response = response
        self.success = success
        self.failed = failed
        self.download = download
    }
}

class MusicNetwork: NSObject, URLSessionDataDelegate, URLSessionDownloadDelegate {
    
    static let `default`: MusicNetwork = MusicNetwork()
    var timeOutInterval: TimeInterval = 60
    
    private let configuration: URLSessionConfiguration = .default
    private var session: URLSession?
    private var requests: [Int: MusicResponse] = [:]
    private let lock = NSLock()
    
    private subscript(task: URLSessionTask) -> MusicResponse? {
        get {
            lock.lock() ; defer { lock.unlock() }
            return requests[task.taskIdentifier]
        }
        set {
            lock.lock() ; defer { lock.unlock() }
            requests[task.taskIdentifier] = newValue
        }
    }
    
    /// New session for MusicNetwork by default session config
    private override init() {
        super.init()
        
        configuration.timeoutIntervalForRequest = timeOutInterval
        session = URLSession(configuration: configuration,
                             delegate: self,
                             delegateQueue: .main)
    }
    
    /// Request by URLRequest
    ///
    /// - Parameters:
    ///   - urlRequest: URLRequest
    ///   - success: Success
    ///   - failed: Failed
    func request(_ urlRequest: URLRequest,
                 response: ((Data?, URLResponse?, Error?) -> ())? = nil,
                 success: ((JSON) -> ())? = nil,
                 failed: ((Error) -> ())? = { ConsoleLog.error($0) }) {

        session?.dataTask(with: urlRequest) { (data, urlResponse, error) in
            response?(data, urlResponse, error)
            if let error = error { failed?(error); return }
            if let data = data { success?(JSON(data: data)) }
        }.resume()
    }
    
    /// Request by url
    ///
    /// - Parameters:
    ///   - url: URL
    ///   - response: MusicResponse
    func request(_ url: URL, response: MusicResponse? = nil) {
        guard let dataTask = session?.dataTask(with: url) else { return }
        self[dataTask] = response == nil ? MusicResponse() : response
        dataTask.resume()
    }
    
    /// Download by url
    ///
    /// - Parameters:
    ///   - url: URL
    ///   - response: MusicResponse
    func download(_ url: URL, response: MusicResponse? = nil) {
        guard let dataTask = session?.downloadTask(with: url) else { return }
        self[dataTask] = response == nil ? MusicResponse() : response
        dataTask.resume()
    }
    
    //MARK: - URLSessionTaskDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if let error = error {
            self[task]?.failed?(error)
        } else if let successBlock = self[task]?.success {
            successBlock(self[task]!.data)
        }
        self[task]?.response?()
    }
    
    //MARK - URLSessionDataDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        self[dataTask]?.data.append(data)
        self[dataTask]?.responseData?(data)
        
        guard let response = self[dataTask] else { return }
        let totalBytesExpected = dataTask.response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
        let progress = Progress(totalUnitCount: totalBytesExpected)
        progress.completedUnitCount = Int64(response.data.count)
        self[dataTask]?.progressInstance = progress
    }
    
    //MARK - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self[downloadTask]?.download?(location)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Progress(totalUnitCount: totalBytesExpectedToWrite)
        progress.completedUnitCount = totalBytesWritten
        self[downloadTask]?.progressInstance = progress
    }
}
/*
open class MusicResponse {
    
    /// Alamofire origin Request
    private(set) var originRequest: DataRequest
    
    /// Alamofire origin Task Delegate
    var delegate: TaskDelegate { return originRequest.delegate }
    
    /// response for data
    private(set) var response: DataResponse<MusicAPIResult>?
    
    /// Result Raw JSON
    private(set) var json: JSON = JSON.null
    
    /// Result Raw Data
    var data: Data { return response?.data ?? Data() }
    
    /// Is Http Request Error
    var isHttpError: Bool { return self.response?.response?.statusCode == nil ? true : !(self.response!.response!.statusCode >= 200 && self.response!.response!.statusCode < 300) }
    
    /// Is Custom Error
    var isCustomError: Bool { return response?.result.value?.code != 200 }
    
    /// Error
    var isError: Bool { return isHttpError || isCustomError }
    
    /// Success
    var isSuccess: Bool { return !isHttpError && !isCustomError }
    
    init(_ request: DataRequest) {
        originRequest = request
        request.responseData { (response) in
            
            let handler: (Result<MusicAPIResult>) -> () = { result in
                self.response = DataResponse(request: response.request,
                                             response: response.response,
                                             data: response.data,
                                             result: result,
                                             timeline: response.timeline)
                
                
                //                let debugNetwork = DebugNetwork(self)
                //                if let allBlock = self.debugTo[.all] { allBlock(debugNetwork) }
                //                else if self.isSuccess { self.debugTo[.success]?(debugNetwork) }
                //                else { self.debugTo[.fail]?(debugNetwork) }
            }
            
            /// parse data to json
            guard let data = response.data, !data.isEmpty else { handler(.failure(MusicError.networkError(.emptyData)));return }
            
            /// Get result json
            let json = JSON(data: data)
            self.json = json
            
            /// parse data to LPResult
            let code = json.code
            
            let result = Result.success(MusicAPIResult(code: code, result: json))
            
            handler(result)
        }
    }
    
    @discardableResult
    func response(queue: DispatchQueue = DispatchQueue.main, _ handler: @escaping () -> ()) -> Self {
        delegate.queue.addOperation {
            queue.async {
                /// Unnecessary to retain self
                handler()
            }
        }
        return self
    }
    
    /// Response from server
    ///
    /// - parameter queue:   The queue on which the completion handler is dispatched.
    /// - parameter handler: The code to be executed once the request has finished.
    ///                      pass json instance when success and data is not nil, else fail
    ///
    /// - returns: The request
    @discardableResult
    func response(queue: DispatchQueue = DispatchQueue.main, jsonHandler handler: @escaping (JSON) -> ()) -> Self {
        delegate.queue.addOperation {
            queue.async {
                handler(self.json)
            }
        }
        return self
    }
    
    /// Response from server
    ///
    /// - parameter queue:   The queue on which the completion handler is dispatched.
    /// - parameter handler: The code to be executed once the request has finished.
    ///                      pass data if content else emptyData
    ///
    /// - returns: The request
    @discardableResult
    func response(queue: DispatchQueue = DispatchQueue.main, rawDataHandler handler: @escaping (Data) -> ()) -> Self {
        delegate.queue.addOperation {
            queue.async {
                handler(self.data)
            }
        }
        return self
    }
    
    /// Success with statusCode between 200 and 300
    ///
    /// - parameter queue:   The queue on which the handler is dispatched.
    /// - parameter handler: The code to be executed once the request has finished.
    ///
    /// - returns: The request
    @discardableResult
    func success(queue: DispatchQueue = DispatchQueue.main, _ handler: @escaping () -> ()) -> Self {
        delegate.queue.addOperation {
            queue.async {
                if self.isSuccess { handler() }
            }
        }
        return self
    }
    
    /// Success with statusCode between 200 and 300 and custom code equal 200
    ///
    ///
    /// - parameter queue:   The queue on which the handler is dispatched.
    /// - parameter handler: The code to be executed once the request has finished.
    ///
    /// - returns: The request
    @discardableResult
    func success(queue: DispatchQueue = DispatchQueue.main, jsonHandler handler: @escaping (JSON) -> ()) -> Self {
        delegate.queue.addOperation {
            queue.async {
                if self.isSuccess { handler(self.json) }
            }
        }
        return self
    }
    
    //    @discardableResult
    //    func success<T: JSONInitable>(queue: DispatchQueue = DispatchQueue.main, genericHandler handler: @escaping (T) -> ()) -> Self {
    //        return success(queue: queue, jsonHandler: { (json) in
    //            handler(T((self.response?.result.value?.result)!))
    //        })
    //    }
    
    //    @discardableResult
    //    func success<T: JSONInitable>(queue: DispatchQueue = DispatchQueue.main, genericArrayHandler handler: @escaping ([T]) -> ()) -> Self {
    //        return success(queue: queue, jsonHandler: { (json) in
    //            handler(T.collection((self.response?.result.value?.result)!))
    //        })
    //    }
    
    //    
    //    func failed() {
    //        
    //    }
}
*/
