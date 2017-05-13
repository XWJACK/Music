//
//  APIModel.swift
//  Music
//
//  Created by Jack on 5/9/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

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
//    let picUrl: URL?
//    let imageUrl: URL?
    
    init(_ json: JSON) {
        name = json["name"].stringValue
//        picUrl = json["picUrl"].url
//        imageUrl = json["img1v1Url"].url
    }
}

//MARK: - Music Album

struct MusicAlbumModel: JSONInitable {
    let name: String
//    let blurPicUrl: URL?
    let picUrl: URL?
    
    init(_ json: JSON) {
        name = json["name"].stringValue
//        blurPicUrl = json["blurPicUrl"].url
        picUrl = json["picUrl"].url
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

//MARK: - Music Detail

struct MusicDetailModel: JSONInitable {
    let id: String
    let name: String
    let artists: [MusicArtistModel]
    let album: MusicAlbumModel
    
    init(_ json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        artists = json["ar"].array?.map{ MusicArtistModel($0) } ?? []
        album = MusicAlbumModel(json["al"])
    }
    
    var musicPlayListDetailViewModel: MusicPlayListDetailViewModel {
        var data = MusicPlayListDetailViewModel()
        data.name = name
        data.detail = (artists.first?.name ?? "") + "-" + album.name
        return data
    }
}

//MARK: - Music URL

struct MusicURLModel: JSONInitable {
    
    let id: String
    let url: URL?
    let md5: String
    let size: Int64
    let bitRate: UInt32
    
    init(_ json: JSON) {
        id = json["id"].stringValue
        url = json["url"].url
        md5 = json["md5"].stringValue
        size = json["size"].int64Value
        bitRate = json["br"].uInt32 ?? 320000
    }
}

//MARK: - Music Search

struct MusicSearchModel: JSONInitable {
    
    let id: String
    let name: String
    let artists: [MusicArtistModel]
    let album: MusicAlbumModel
//    let mp3Url: URL?
    
    init(_ json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
//        mp3Url = json["mp3Url"].url
        
        artists = json["artists"].arrayValue.map{ MusicArtistModel($0) }
        album = MusicAlbumModel(json["album"])
    }
    
    var musicSearchViewMode: MusicSearchViewModel {
        var data = MusicSearchViewModel()
        data.name = name
        data.detail = (artists.first?.name ?? "") + "-" + album.name
        return data
    }
    
    var resource: MusicResource {
        let resource = MusicResource(id: id)
        resource.name = name
//        resource.musicUrl = mp3Url
        resource.resourceSource = .network
        resource.picUrl = album.picUrl
        return resource
    }
}

//MARK: - Lyric

struct MusicLyricModel: JSONInitable {
    let lyric: String
    init(_ json: JSON) {
        lyric = json["lrc"]["lyric"].stringValue
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
        musicDetail = json["tracks"].array?.map{ MusicDetailModel($0) } ?? []
    }
}
