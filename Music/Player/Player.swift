//
//  Player.swift
//  Music
//
//  Created by Jack on 3/14/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioPlayer: AudioPlayerControl {
    init()
}

protocol AudioPlayerControl {
    func play(with resources: AudioPlayerResourcesConvertible) throws
    func seek(toTime time: TimeInterval) throws
    func pause()
    func stop()
//    func last()
//    func next()
}
