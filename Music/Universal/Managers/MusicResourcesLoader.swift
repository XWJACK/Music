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
    
    var codeing: String { return JSON(["resourceID": resourceID, "resourceMD5": resourceMD5!]).stringValue }
}

typealias MusicResourceCollection = [String: MusicResource]

class MusicResourcesLoader {
    
    static let `default` = MusicResourcesLoader()
    
    var resourceLoadMode: MusicPlayerPlayMode = .order
    
    private(set) var resources: [MusicResource] = []
    private(set) var resourcesIndexs: [Int] = []
    private(set) var currentResourceIndex: Int = 0
    private(set) var cachedResourceList: MusicResourceCollection = [:]
    private(set) var downloadedResouceList: MusicResourceCollection = [:]
    
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
        resource.resourceMD5 = resource.resourceID.md5()
//        cachedResourceList.append(resource)
    }
    
    func save(_ resource: MusicResource) {
        var resource = resource
        resource.isDownload = true
        resource.resourceMD5 = resource.resourceID.md5()
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
