//
//  DebugNetwork.swift
//  Music
//
//  Created by Jack on 5/4/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

public typealias DebugBlock = ((DebugNetwork) -> ())

public enum DebugContent: String {
    case success    = "********** Success  **********"
    case fail       = "**********   Fail   **********"
    case all        = "********** Response **********"
}

public class DebugNetwork: CustomDebugStringConvertible {
    
    public var requestID: String { return debugRequest.request?.originRequest.task?.taskIdentifier.description ?? "Unknow Request ID" }
    public var requestURL: String { return debugRequest.request?.originRequest.request?.url?.absoluteString ?? "Unknow Request URL" }
    public var requestMethod: String { return debugRequest.request?.originRequest.request?.httpMethod ?? "Unknow Request Method" }
    public var requestData: String { return debugRequest.request?.originRequest.request?.httpBody?.description ?? "No Request Body" }
    
    public let debugRequest: DebugRequest
    public let debugResponse: DebugResponse
    
    public var debugDescription: String {
        return
            "\n********** Network Debug ID:\(requestID) **********\n" +
            "\(requestMethod): " + "\(requestURL)" +
            debugRequest.debugDescription +
            debugResponse.debugDescription +
            "\n"
    }
    
    init(_ request: MusicDataRequest) {
        debugRequest = DebugRequest(request)
        debugResponse = DebugResponse(request)
    }
}

public final class DebugRequest: CustomDebugStringConvertible {
    
    var request: LPDataRequest?
    public var headers: [String: Any] {
        return (request?.originRequest.request?.allHTTPHeaderFields +
            (LPNetworkManager.sessionManager.session.configuration.httpAdditionalHeaders as? [String: String])) ?? [:]
    }
    
    public var debugDescription: String {
        return
            "\n****** Request Headers: ******\n" +
            headers.debugString +
            "\n**********************\n" +
            (request?.originRequest.request.debugDescription ?? "")
    }
    
    init(_ request: LPDataRequest) {
        self.request = request
    }
}

public final class DebugResponse: CustomDebugStringConvertible {
    
    var request: LPDataRequest?
    public var statusCode: String { return request?.originRequest.response?.statusCode.description ?? "Unknow Status Code" }
    public var responseHeaders: [String: Any] { return request?.originRequest.response?.allHeaderFields as? [String: Any] ?? [:] }
    public var responseData: JSON? { return request?.resultJSON }
    
    public var debugDescription: String {
        return
            "\nResponse Code:\(statusCode)\n" +
            "****** Response Headers: *****\n" +
            responseHeaders.debugString +
            "\n****** Response Data *********\n" +
            responseData.debugDescription
    }
    
    init(_ response: LPDataRequest?) {
        self.request = response
    }
}

private extension Dictionary {
    var debugString: String {
        return self.map{ (key, value) in "\(key): \(value)"}.joined(separator: "\n")
    }
}

private func +<Key: Hashable, Value> (_ lfs: [Key: Value]?, _ rfs: [Key: Value]?) -> [Key: Value]? {
    var temp = lfs
    rfs?.forEach{ key, value in temp?[key] = value }
    return temp
}
