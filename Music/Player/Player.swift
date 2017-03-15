//
//  Player.swift
//  Music
//
//  Created by Jack on 3/14/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation
import AVFoundation

class LocalAudioPlayer: AVAudioPlayer {
    
}

protocol PlayerControl {
    func play() -> Bool
    func play(atTime time: TimeInterval) -> Bool
    func pause()
    func stop()
    func last()
    func next()
}
