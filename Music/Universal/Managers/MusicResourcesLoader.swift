//
//  MusicResourcesLoader.swift
//  Music
//
//  Created by Jack on 5/6/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

struct MusicResource {
    var isCached: Bool = false
    var isDownload: Bool = false
    var resourceID: String = ""
    var resourceURL: URL? = nil
}

class MusicResourcesLoader {
    
    static let `default` = MusicResourcesLoader()
    
    var resourceLoadMode: MusicPlayerPlayMode = .order
    
    private init() {
        
    }
    
//    func last() -> MusicResource {
//        
//    }
//    
//    func next() -> MusicResource {
//        
//    }
}
