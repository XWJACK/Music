//
//  MusicAPI.swift
//  Music
//
//  Created by Jack on 5/4/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public typealias JSON = SwiftyJSON.JSON

/// Result for Response formatter
public struct MusicAPIResult {
    public let code: Int
    public let result: JSON
}

extension JSON {
    /// Parse Code
    var code: Int { return self["code"].intValue }
    /// Parse Data
    var result: JSON { return self["result"] }
}

public protocol JSONInitable {
    init(_ json: JSON)
}

extension JSONInitable {
    static func collection(_ json: JSON) -> [Self] {
        return json.map{ (_, itemJSON) in Self(itemJSON) }
    }
}

open class MusicAPI {
    
    public static let `default`: MusicAPI = MusicAPI()
    
    public var baseURLString: String?
    
    //MARK: - Search
    
    public enum SearchType: Int {
        case 单曲 = 1//: 单曲
        case 专辑 = 10//: 专辑
        case 歌手 = 100///: 歌手
        case 歌单 = 1000//: 歌单
        case 用户 = 1002//: 用户
        case MV = 1004//: MV
        case 歌词 = 1006//: 歌词
        case 电台 = 1009//: 电台
    }
    
    open func search(keyWords: String, limit: Int? = nil, offset: Int? = nil, type: SearchType? = nil) -> MusicResponse {
        
        let requestURL = URL(string: "/search", relativeTo: URL(string: baseURLString ?? ""))!
        var parameters: Parameters = ["keywords": keyWords]
        
        if let limit = limit { parameters["limit"] = limit }
        if let offset = offset { parameters["offset"] = offset }
        if let type = type { parameters["type"] = type }
        
        let request = Alamofire.request(requestURL, method: .get, parameters: parameters)
        return MusicResponse(request)
    }
}

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
