//
//  MusicResourcesLoader.swift
//  Music
//
//  Created by Jack on 5/6/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation


/// Music Resource
struct MusicResource: JSONInitable {
    var isCached: Bool = false
    var isDownload: Bool = false
    var id: String = ""
    var md5: String? = nil
    var musicUrl: URL? = nil
    var lyric: String? = nil
    
    init(){}
    
    init(_ json: JSON) {
        id = json["id"].stringValue
        md5 = json["md5"].stringValue
        lyric = json["lyric"].string
    }
    
    var codeing: String {
        var code = ["id": id, "md5": md5 ?? { assertionFailure("Codeing with MD5 Error"); return "Error MD5" }()]
        if let lyric = lyric { code["lyric"] = lyric }
        return JSON(code).stringValue
    }
}

typealias MusicResourceCollection = [String: MusicResource]

class MusicResourcesLoader {
    
    static let `default` = MusicResourcesLoader()
    
    var resourceLoadMode: MusicPlayerPlayMode = .order
    
    private var resources: [MusicResource] = []
    private var resourcesIndexs: [Int] = []
    private var currentResourceIndex: Int = 0
    private var cachedResourceList: MusicResourceCollection = [:]
    private var downloadedResouceList: MusicResourceCollection = [:]
    
    private init() {
        DispatchQueue.global().async {
            self.cachedResourceList = MusicFileManager.default.search(fromURL: MusicFileManager.default.musicCacheURL)
            self.downloadedResouceList = MusicFileManager.default.search(fromURL: MusicFileManager.default.musicDownloadURL)
        }
    }
    
    func reset(_ resources: [MusicResource], resourceIndex: Int, withMode mode: MusicPlayerPlayMode? = nil) {
        if let mode = mode { self.resourceLoadMode = mode }
        self.resources = resources
        self.resourcesIndexs = uniqueRandom(0...resources.count - 1)
        self.currentResourceIndex = resourceIndex
    }
    
    func cache(_ resource: MusicResource) {
        var resource = resource
        resource.isCached = true
        resource.md5 = resource.id.md5()
//        cachedResourceList.append(resource)
    }
    
    func save(_ resource: MusicResource) {
        var resource = resource
        resource.isDownload = true
        resource.md5 = resource.id.md5()
//        cachedResourceList.append(resource)
    }
    
    func current() -> MusicResource {
        return resources[currentResourceIndex]
    }
    
    func last() -> MusicResource {
        if currentResourceIndex == 0 { currentResourceIndex = resources.count - 1 }
        else { currentResourceIndex -= 1 }
        return resources[currentResourceIndex]
    }
    
    func next() -> MusicResource {
        currentResourceIndex = (currentResourceIndex + 1) % resources.count
        return resources[currentResourceIndex]
    }
    
    private func uniqueRandom(_ range: ClosedRange<Int>) -> [Int] {
        var result: [Int] = Array(range.lowerBound...range.upperBound)
        result.reserveCapacity(range.count)
        var i = range.count
        result.forEach{ _ in
            let index = Int(arc4random_uniform(UInt32(i)))
            (result[i - 1], result[index]) = (result[index], result[i - 1])
            i -= 1
        }
        return result
    }
}
