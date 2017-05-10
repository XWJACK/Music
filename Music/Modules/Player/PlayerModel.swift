//
//  PlayerModel.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

/// Music Player Status
enum MusicPlayerStatus {
    case playing
    case paused
}

/// Music Player Love Mode
enum MusicPlayerLoveMode {
    case love
    case loved
    case disable
}

/// Music Player Play Mode
enum MusicPlayerPlayMode {
    case single
    case order
    case random
}

/// Music Player Download Mode
enum MusicPlayerDownloadMode {
    case download
    case downloaded
    case disable
}

struct MusicPlayerResource {
    var id: String
    let name: String = ""
    let isDownload: Bool = false
    let isLoved: Bool = false
    let pictureImageURL: URL? = nil
    let backgroundImageURL: URL? = nil
}

struct MusicPlayerResponse {
    
    struct Music {
//        var data = Data()
        var response: ((Data) -> ())? = nil
        var progress: ((Progress) -> ())? = nil
        
        init(response: ((Data) -> ())? = nil,
             progress: ((Progress) -> ())? = nil) {
            
            self.response = response
            self.progress = progress
        }
    }
    
    struct Lyric {
        var success: ((String) -> ())? = nil
        init(success: ((String) -> ())? = nil) {
            
            self.success = success
        }
    }
    
    var music: Music
    var lyric: Lyric
    
    var failed: ((Error) -> ())? = nil
    
    init(music: Music, lyric: Lyric) {
        self.music = music
        self.lyric = lyric
    }
}
