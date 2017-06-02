//
//  DispatchManager.swift
//  Music
//
//  Created by Jack on 5/22/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

final class DispatchManager {
    
    static let `default`: DispatchManager = DispatchManager()
    
    /// Audio parse serial queue
    let audioParseQueue: DispatchQueue
    
    /// Music resource manager cache / download background queue
    let resourceQueue: DispatchQueue
    
    /// If is aleardy in main, it will execuse synchronous, or execuse asynchronous
    var main: SafeMainDispatchQueue { return SafeMainDispatchQueue.default }
    
    /// Music player queue
    var playerQueue: DispatchQueue
    
    init() {
        audioParseQueue = DispatchQueue(label: "com.Music.DispatchManager.AudioParse.Serial")
        playerQueue = DispatchQueue(label: "com.Music.DispatchManager.MusicPlayer.Serial")
        resourceQueue = DispatchQueue(label: "com.Music.DispatchManager.Resource.background.Serial",
                                      qos: .background)
    }
}

final class SafeMainDispatchQueue {
    
    private let mainQueueKey = DispatchSpecificKey<String>()
    private let mainQueueValue: String = "com.Music.DispatchManager.main"
    
    fileprivate static let `default` = SafeMainDispatchQueue()
    
    private init() {
        DispatchQueue.main.setSpecific(key: mainQueueKey, value: mainQueueValue)
    }
    
    func async(execute work: @escaping () -> ()) {
        
        if DispatchQueue.getSpecific(key: SafeMainDispatchQueue.default.mainQueueKey) == SafeMainDispatchQueue.default.mainQueueValue {
            work()
        } else {
            DispatchQueue.main.async {
                work()
            }
        }
    }
}
