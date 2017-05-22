//
//  ThreadManager.swift
//  Music
//
//  Created by Jack on 5/22/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

class ThreadManager {
    static let `default`: ThreadManager = ThreadManager()
    
    /// Audio parse serial queue
    let audioParseQueue: DispatchQueue
    
    /// Music resource manager cache / download queue
    let resourceQueue: DispatchQueue
    
    init() {
        audioParseQueue = DispatchQueue(label: "com.Music.ThreadManager.AudioParseQueue")
        resourceQueue = DispatchQueue(label: "com.Music.ThreadManager.MusicResourceManagerQueue",
                                      qos: .background)
    }
}
