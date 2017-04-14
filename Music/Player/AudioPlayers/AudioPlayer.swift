//
//  AudioPlayer.swift
//  Music
//
//  Created by Jack on 3/19/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayer {
    
    var updateRate: TimeInterval = 0.1
    var isPlaying: Bool { return player.isPlaying }
    var totalTime: TimeInterval { return player.duration }
    var currentTime: TimeInterval { return player.currentTime }
    var currentTimeBlock: ((TimeInterval) -> ())? = nil
    
    private let player: AVAudioPlayer
    private var timer: Timer?
    
    init(data: Data, fileTypeHint utiString: String? = AVFileTypeMPEGLayer3) throws {
        do {
            player = try AVAudioPlayer(data: data, fileTypeHint: utiString)
        } catch {
            throw MusicError.resourcesError(.invalidData)
        }
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    func play() {
        if !isPlaying { player.play() }
        createTimer()
    }
    
    func pause() {
        if isPlaying { player.pause() }
        destoryTimer()
    }
    
    func seek(toTime time: TimeInterval) {
        player.currentTime = time
    }
    
    func stop() {
        player.stop()
        player.currentTime = 0
        destoryTimer()
    }
    
    @objc private func update() {
        currentTimeBlock?(currentTime)
    }
    
    private func createTimer() {
        timer = Timer(timeInterval: updateRate, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
    }
    
    private func destoryTimer() {
        timer?.invalidate()
        timer = nil
    }
}
