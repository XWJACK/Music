//
//  APIModel.swift
//  Music
//
//  Created by Jack on 5/9/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

protocol JSONInitable {
    init(_ json: JSON)
}

//MARK: - Music Account

struct MusicAccountModel: JSONInitable {
    let id: String
    let userName: String
    
    init(_ json: JSON) {
        id = json["id"].stringValue
        userName = json["userName"].stringValue
    }
}

//MARK: - Music Profile

struct MusicProfileModel: JSONInitable {
    let userId: String
    let nickname: String
    let avatarUrl: URL?
    let backgroundUrl: URL?
    
    init(_ json: JSON) {
        userId = json["userId"].stringValue
        nickname = json["nickname"].stringValue
        avatarUrl = json["avatarUrl"].url
        backgroundUrl = json["backgroundUrl"].url
    }
}

//MARK: - Music Artist

struct MusicArtistModel: JSONInitable {
    let name: String
    
    init(_ json: JSON) {
        name = json["name"].stringValue
    }
}

//MARK: - Music Album

struct MusicAlbumModel: JSONInitable {
    let name: String
    let picUrl: URL?
    
    init(_ json: JSON) {
        name = json["name"].stringValue
        picUrl = json["picUrl"].url
    }
    
    var encode: String {
        var dic: [String: Any] = ["name": name]
        dic["picUrl"] = picUrl?.absoluteString
        return JSON(dic).rawString() ?? ""
    }
}

//MARK: - Music Creator

struct MusicCreatorModel: JSONInitable {
    let userId: String
    let nickname: String
    let avatarUrl: URL?
    let backgroundUrl: URL?
    
    init(_ json: JSON) {
        userId = json["userId"].stringValue
        nickname = json["nickname"].stringValue
        avatarUrl = json["avatarUrl"].url
        backgroundUrl = json["backgroundUrl"].url
    }
}

//MARK: - Music Detail ( Serach / PlayList)

struct MusicDetailModel {
    
    let id: String
    let name: String
    let duration: TimeInterval?
    let artists: [MusicArtistModel]
    let album: MusicAlbumModel
    
    init(searchJSON json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        duration = json["duration"].double
        
        artists = json["artists"].arrayValue.map{ MusicArtistModel($0) }
        album = MusicAlbumModel(json["album"])
    }
    
    init(playListJSON json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        duration = json["dt"].double
        artists = json["ar"].array?.map{ MusicArtistModel($0) } ?? []
        album = MusicAlbumModel(json["al"])
    }
    
    var musicPlayListDetailViewModel: MusicPlayListDetailViewModel {
        var model = MusicPlayListDetailViewModel()
        model.name = name
        model.detail = (artists.first?.name ?? "") + "-" + album.name
        return model
    }
    
    var musicSearchViewModel: MusicSearchViewModel {
        var model = MusicSearchViewModel()
        model.name = name
        model.detail = (artists.first?.name ?? "") + "-" + album.name
        return model
    }
    
    var resource: MusicResource {
        let resource = MusicResource(id: id)
        resource.name = name
        resource.duration = duration
        
        resource.resourceSource = .network
        resource.album = album
        return resource
    }
}

//MARK: - Music Resource Info

struct MusicResouceInfoModel: JSONInitable {
    
    let id: String
    var url: URL? = nil
    var md5: String? = nil
    /// File size
    var size: Int64? = nil
    /// Audio bit rate
    var bitRate: UInt32? = nil
    
    init(id: String) {
        self.id = id
    }
    
    init(_ json: JSON) {
        id = json["id"].stringValue
        url = json["url"].url
        md5 = json["md5"].string
        size = json["size"].int64
        bitRate = json["br"].uInt32
    }
    
    var encode: String {
        var dic: [String: Any] = ["id": id]
        dic["url"] = url?.absoluteString
        dic["md5"] = md5
        dic["size"] = size
        dic["br"] = bitRate
        return JSON(dic).rawString() ?? ""
    }
}

//MARK: - Lyric

struct MusicLyricModel: JSONInitable {
    
    private(set) var hasLyric: Bool = true
    let lyric: String
    
    init(_ json: JSON) {
        hasLyric = !(json["nolyric"].bool ?? false)
        lyric = json["lrc"]["lyric"].string ?? "Empty Lyric"
    }
    
    var encode: String {
        let dic: [String: Any] = ["nolyric": !hasLyric, "lrc": ["lyric": lyric]]
        return JSON(dic).rawString() ?? ""
    }
}

//MARK: - Play List

class MusicPlayListModel: JSONInitable {
    let id: String
    let name: String
    let coverImgUrl: URL?
    let creator: MusicCreatorModel
    let trackCount: Int
    
    required init(_ json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        coverImgUrl = json["coverImgUrl"].url
        creator = MusicCreatorModel(json["creator"])
        trackCount = json["trackCount"].intValue
    }
    
    var musicCollectionListViewModel: MusicCollectionListViewModel {
        var data = MusicCollectionListViewModel()
        data.coverImageUrl = coverImgUrl
        data.name = name
        data.detail = trackCount.description + " songs"
        return data
    }
}

//MARK: - Play List Detail

class MusicPlayListDetailModel: MusicPlayListModel {
    
    var musicDetail: [MusicDetailModel] = []
    
    required init(_ json: JSON) {
        super.init(json)
        musicDetail = json["tracks"].array?.map{ MusicDetailModel(playListJSON: $0) } ?? []
    }
}
