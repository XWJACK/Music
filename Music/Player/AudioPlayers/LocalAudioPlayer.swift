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
    
    required convenience init(contentsOf resource: AudioPlayerResourcesConvertible, fileTypeHint utiString: String?) throws {
        do {
            let url = try resource.asResources()
            try self.init(contentsOf: url, fileTypeHint: utiString)
        } catch {
            throw MusicError.resourcesError(.invaliedURL)
        }
    }
    
    func seek(toTime time: TimeInterval) throws {
        ///By setting this property you can seek to a specific point in a sound file or implement audio fast-forward and rewind functions.
//        if !play(atTime: time) { throw MusicError.playerError(.seekError) }
    }
    
    @objc(AudioPlayer) func play() {
        super.play()
    }
}
