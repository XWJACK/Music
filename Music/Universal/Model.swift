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
    let picUrl: URL?
    let img1v1Url: URL?
    
    init(_ json: JSON) {
        name = json["name"].stringValue
        picUrl = json["picUrl"].url
        img1v1Url = json["img1v1Url"].url
    }
}

struct MusicAlbum: JSONInitable {
    let name: String
    let blurPicUrl: URL?
    let picURL: URL?
    
    init(_ json: JSON) {
        name = json["name"].stringValue
        blurPicUrl = json["blurPicUrl"].url
        picURL = json["picURL"].url
    }
}

//MARK: - Search

struct SearchModel: JSONInitable {
    
    let id: String
    let name: String
    let artists: [MusicArtist]
    let album: MusicAlbum
    let mp3URL: URL?
    
    init(_ json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        mp3URL = json["mp3Url"].url
        
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
