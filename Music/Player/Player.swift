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
    
    /// Returns the total duration, in seconds, of the sound associated with the audio player.
    var duration: TimeInterval { get }
    
    /// By setting this property you can seek to a specific point in a sound file or implement audio fast-forward and rewind functions.
    var currentTime: TimeInterval { get set }
    
    /// Initializes and returns an audio player using the specified Resource whitch confirm AudioPlayerResourcesConvertible and file type hint.
    /// The utiString file type hint tells the parser what kind of sound data to expect so that files which are not self identifying, 
    /// or possibly even corrupt, can be successfully parsed.
    ///
    /// - Parameters:
    ///   - resource: The Resource whitch confirm AudioPlayerResourcesConvertible
    ///   - utiString: A UTI that is used as a file type hint. The supported UTIs are defined in File Format UTIs.
    /// - Throws: On success, an initialized AudioPlayer object whitch confirm AudioPlayer. If nil, the outError parameter contains an MusicError instance describing the problem.
    init(contentsOf resource: AudioPlayerResourcesConvertible, fileTypeHint utiString: String?) throws
}

protocol AudioPlayerControl {
    
    /// play the sound
    func play()
    
    /// pause the sound
    func pause()
    
    /// stop play
    func stop()
}

