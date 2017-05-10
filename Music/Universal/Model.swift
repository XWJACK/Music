//
//  Model.swift
//  Music
//
//  Created by Jack on 5/9/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

struct MusicAccount: JSONInitable {
    let id: String
    let userName: String
    
    init(_ json: JSON) {
        id = json["id"].stringValue
        userName = json["userName"].stringValue
    }
}

struct MusicProfile: JSONInitable {
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

struct MusicArtist: JSONInitable {
    let name: String
//    let picUrl: URL?
//    let imageUrl: URL?
    
    init(_ json: JSON) {
        name = json["name"].stringValue
//        picUrl = json["picUrl"].url
//        imageUrl = json["img1v1Url"].url
    }
}

struct MusicAlbum: JSONInitable {
    let name: String
//    let blurPicUrl: URL?
    let picUrl: URL?
    
    init(_ json: JSON) {
        name = json["name"].stringValue
//        blurPicUrl = json["blurPicUrl"].url
        picUrl = json["picUrl"].url
    }
}

struct CreatorModel: JSONInitable {
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

struct MusicDetail: JSONInitable {
    let id: String
    let name: String
    let artists: [MusicArtist]
    let album: MusicAlbum
    
    init(_ json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        artists = json["ar"].array?.map{ MusicArtist($0) } ?? []
        album = MusicAlbum(json["al"])
    }
    
    var playListDetailViewModel: PlayListDetailViewModel {
        var data = PlayListDetailViewModel()
        data.name = name
        data.detail = (artists.first?.name ?? "") + "-" + album.name
        return data
    }
}

//MARK: - Search

struct SearchModel: JSONInitable {
    
    let id: String
    let name: String
    let artists: [MusicArtist]
    let album: MusicAlbum
    let mp3Url: URL?
    
    init(_ json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        mp3Url = json["mp3Url"].url
        
        artists = json["artists"].arrayValue.map{ MusicArtist($0) }
        album = MusicAlbum(json["album"])
    }
    
    var searchViewMode: SearchViewModel {
        var data = SearchViewModel()
        data.name = name
        data.detail = (artists.first?.name ?? "") + "-" + album.name
        return data
    }
}

//MARK: - Lyric

struct LyricModel: JSONInitable {
    let lyric: String
    init(_ json: JSON) {
        lyric = json["lrc"]["lyric"].stringValue
    }
}

//MARK: - Play List

class PlayListModel: JSONInitable {
    let id: String
    let name: String
    let coverImgUrl: URL?
    let creator: CreatorModel
    let trackCount: Int
    
    required init(_ json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        coverImgUrl = json["coverImgUrl"].url
        creator = CreatorModel(json["creator"])
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

class PlayListDetailModel: PlayListModel {
    
    var musicDetail: [MusicDetail] = []
    
    required init(_ json: JSON) {
        super.init(json)
        musicDetail = json["tracks"].array?.map{ MusicDetail($0) } ?? []
    }
}
