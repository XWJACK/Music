//
//  LocalAudioPlayer.swift
//  Music
//
//  Created by Jack on 3/19/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation
import AVFoundation

class LocalAudioPlayer: AVAudioPlayer, AudioPlayer {
    
    override required init() {
        super.init()
    }
    
    func seek(toTime time: TimeInterval) throws {
        if !play(atTime: time) { throw MusicError.playerError(.seekError) }
    }

    func play(with resources: AudioPlayerResourcesConvertible) throws {
        
    }
}
