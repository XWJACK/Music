//
//  PlayerModel.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation
import AVFoundation

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

struct MusicPlayerModel {
    var isDownloaded: Bool = false
    var isLoved: Bool = false
    let musicName: String = ""
    let musicURL: URL?
    let lyricURL: URL?
    let avaterURL: URL?
    let backgroundImageURL: URL?
}
