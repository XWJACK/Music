//
//  MusicAPI.swift
//  Music
//
//  Created by Jack on 5/4/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

extension URLRequest {
    static var api: MusicAPI { return MusicAPI.default }
}

open class MusicAPI {
    
    public static let `default`: MusicAPI = MusicAPI()
    
    public var baseURLString: String? //"http://Your API Server Address"
    
    //MARK: - Search
    
    public enum SearchType: Int {
        case 单曲 = 1
        case 专辑 = 10
        case 歌手 = 100
        case 歌单 = 1000
        case 用户 = 1002
        case MV = 1004
        case 歌词 = 1006
        case 电台 = 1009
    }
    
    open func search(keyWords: String, limit: Int? = nil, offset: Int? = nil, type: SearchType? = nil) -> URLRequest {
        
        let requestURL = URL(string: "/search", relativeTo: URL(string: baseURLString ?? ""))!
        var parameters: Parameters = ["keywords": keyWords]
        
        if let limit = limit { parameters["limit"] = limit }
        if let offset = offset { parameters["offset"] = offset }
        if let type = type { parameters["type"] = type }
        
        return try! URLEncoding.default.encode(URLRequest(url: requestURL, method: .get), with: parameters)
    }
}
