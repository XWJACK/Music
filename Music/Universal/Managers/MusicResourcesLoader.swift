//
//  MusicResourcesLoader.swift
//  Music
//
//  Created by Jack on 5/6/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

struct MusicResource: JSONInitable {
    var isCached: Bool = false
    var isDownload: Bool = false
    var resourceID: String = ""
    var resourceMD5: String? = nil
    var resourceURL: URL? = nil
    
    init(){}
    
    init(_ json: JSON) {
        resourceID = json["resourceID"].stringValue
        resourceMD5 = json["resourceMD5"].stringValue
    }
}

class MusicResourcesLoader {
    
    static let `default` = MusicResourcesLoader()
    
    var resourceLoadMode: MusicPlayerPlayMode = .order
    
    private(set) var resources: [MusicResource] = []
    private(set) var currentIndex: Int = 0
    private(set) var cachedResourceList: [MusicResource] = []
    private(set) var downloadedResouceList: [MusicResource] = []
    
    private init() {
        DispatchQueue.global().async {
            self.cachedResourceList = MusicFileManager.default.search(fromURL: MusicFileManager.default.musicCacheURL)
            self.downloadedResouceList = MusicFileManager.default.search(fromURL: MusicFileManager.default.musicDownloadURL)
        }
    }
    
    func reset(_ resources: [MusicResource], resourceIndex: Int = 0, withMode mode: MusicPlayerPlayMode = .order) {
        self.resourceLoadMode = mode
        self.resources = resources
        self.currentIndex = resourceIndex
    }
    
//    func last() -> MusicResource {
//        
//    }
//    
//    func next() -> MusicResource {
//        
//    }
}
