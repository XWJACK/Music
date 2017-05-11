//
//  MusicAPI.swift
//  Music
//
//  Created by Jack on 5/4/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

/// Music API
open class MusicAPI {
    
    public static let `default`: MusicAPI = MusicAPI()
    
    public var baseURLString: String? //"http://Your API Server Address"
    
    private func request(path: String,
                         parameters: Parameters = [:],
                         method: HTTPMethod = .get) -> URLRequest {
        
        let requestURL = URL(string: path, relativeTo: URL(string: baseURLString ?? ""))
        
        return try! URLEncoding.default.encode(URLRequest(url: requestURL!, method: method), with: parameters)
    }
    
    //MARK: - Search
    
    /// 搜索类型
    ///
    /// - 单曲: <#单曲 description#>
    /// - 专辑: <#专辑 description#>
    /// - 歌手: <#歌手 description#>
    /// - 歌单: <#歌单 description#>
    /// - 用户: <#用户 description#>
    /// - MV: <#MV description#>
    /// - 歌词: <#歌词 description#>
    /// - 电台: <#电台 description#>
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
    
    /// 搜索
    ///
    /// - Parameters:
    ///   - keyWords: 关键字
    ///   - limit: 一次返回多少数据
    ///   - offset: 偏移量，用于分页
    ///   - type: 搜索类型
    /// - Returns: URLRequest
    open func search(keyWords: String, limit: Int? = nil, offset: Int? = nil, type: SearchType? = nil) -> URLRequest {
        
        var parameters: Parameters = ["keywords": keyWords]
        
        parameters["limit"] = limit
        parameters["offset"] = offset
        parameters["type"] = type
        
        return request(path: "/search", parameters: parameters)
    }
    
    //MARK: - Login
    
    /// 登录类型
    ///
    /// - phone: 手机号登录
    /// - email: 网易邮箱登录
    public enum LoginType {
        case phone
        case email
    }
    
    /// 登录
    ///
    /// - Parameters:
    ///   - userName: 用户名
    ///   - password: 密码
    ///   - type: 登录类型
    /// - Returns: URLRequest
    open func login(userName: String, password: String, type: LoginType = .phone) -> URLRequest {
        
        var path = "/login"
        let parameters: Parameters = ["userName": userName, "password": password]
        if type == .phone { path += "/cellphone" }
        
        return request(path: path, parameters: parameters)
    }
    
    //MARK: - Music URL
    
    /// 获取音乐URL
    ///
    /// - Parameter id: 音乐ID
    /// - Returns: URLRequest
    open func musicUrl(musicID id: String) -> URLRequest {
        let parameters: Parameters = ["id": id]
        return request(path: "/music/url", parameters: parameters)
    }
    
    //MARK: - Lyric
    
    /// 获取歌词
    ///
    /// - Parameter id: 音乐ID
    /// - Returns: URLRequest
    open func lyric(musicID id: String) -> URLRequest {
        let parameters: Parameters = ["id": id]
        return request(path: "/lyric", parameters: parameters)
    }
    
    //MARK: - Like
    
    /// 喜欢／不喜欢音乐
    ///
    /// - Parameters:
    ///   - id: 音乐ID
    ///   - isLike: 喜欢／不喜欢
    /// - Returns: URLRequest
    open func like(musicID id: String, isLike: Bool = true) -> URLRequest {
        let parameters: Parameters = ["id": id, "like": isLike.description]
        return request(path: "/like", parameters: parameters)
    }
    
    //MARK: - Song detail
    
    /// 获取音乐详情
    ///
    /// - Parameter ids: 音乐ID
    /// - Returns: URLRequest
    open func detail(musicIds ids: String...) -> URLRequest {
        let parameters: Parameters = ["ids": ids.joined(separator: ",")]
        return request(path: "/song/detail", parameters: parameters)
    }
    
    //MARK: - Play List
    
    /// 获取用户音乐列表
    ///
    /// - Parameter uid: 用户ID
    /// - Returns: URLRequest
    open func playList(userId uid: String) -> URLRequest {
        let parameters: Parameters = ["uid": uid]
        return request(path: "/user/playlist", parameters: parameters)
    }
    
    /// 获取歌单详情
    ///
    /// - Parameter id: 歌单ID
    /// - Returns: URLRequest
    open func detail(listId id: String) -> URLRequest {
        let parameters: Parameters = ["id": id]
        return request(path: "/playlist/detail", parameters: parameters)
    }
}
