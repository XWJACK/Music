//
//  PlayerModel.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

/// 播放器状态
///
/// - playing: 正在播放
/// - paused: 暂停
enum MusicPlayerStatus {
    case playing
    case paused
}

enum LovedStatus: Int {
    case normal
    case loved
}

/// 音乐播放模式
enum MusicPlayerPlayMode {
    case single
    case order
    case random
}
/// 下载状态模式
enum MusicPlayerDownloadMode {
    case normal
    case downloaded
    case disable
}
