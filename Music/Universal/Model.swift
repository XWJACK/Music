//
//  Model.swift
//  Music
//
//  Created by Jack on 5/9/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

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
}

//MARK: - Lyric

struct LyricModel: JSONInitable {
    let lyric: String
    init(_ json: JSON) {
        lyric = json["lrc"]["lyric"].stringValue
    }
}

//MARK: - Play List

struct PlayListModel: JSONInitable {
    let id: String
    let name: String
    let coverImgUrl: URL?
    let creator: CreatorModel
    
    init(_ json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        coverImgUrl = json["coverImgUrl"].url
        creator = CreatorModel(json["creator"])
    }
}
