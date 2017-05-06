//
//  SearchMode.swift
//  Music
//
//  Created by Jack on 5/5/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

struct SearchMode: JSONInitable {
    
    let id: String
    let name: String
    let artistsName: String
    let albumName: String
    let mp3URL: URL?
    
    init(_ json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        mp3URL = json["mp3Url"].url
        
        artistsName = json["artists"]["name"].stringValue
        albumName = json["album"]["name"].stringValue
    }
}
