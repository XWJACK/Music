//
//  MusicResourceManager.swift
//  Music
//
//  Created by Jack on 5/6/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation


/// Music Resource
struct MusicResource: JSONInitable {
    
    /// Source of Resource
    ///
    /// - cache: Cache
    /// - download: Download
    /// - network: Network
    enum ResourceSource {
        case cache
        case download
        case network
    }
    
    let id: String
    var md5: String? = nil
    var resourceSource: ResourceSource = .network
    var musicUrl: URL? = nil
    var lyric: String? = nil
    
    init(id: String){
        self.id = id
    }
    
    init(_ json: JSON) {
        id = json["id"].stringValue
        md5 = json["md5"].string
        lyric = json["lyric"].string
    }
    
    var codeing: String {
        var code = ["id": id, "md5": md5 ?? { assertionFailure("Codeing with MD5 Error"); return "Error MD5" }()]
        if let lyric = lyric { code["lyric"] = lyric }
        return JSON(code).stringValue
    }
}

typealias MusicResourceCollection = [String: MusicResource]

class MusicResourceManager {
    
    static let `default` = MusicResourceManager()
    
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
    
    func current() -> String {
        return resources[currentResourceIndex].id
    }
    
    func last() -> String {
        if currentResourceIndex == 0 { currentResourceIndex = resources.count - 1 }
        else { currentResourceIndex -= 1 }
        return resources[currentResourceIndex].id
    }
    
    func next() -> MusicResource {
        currentResourceIndex = (currentResourceIndex + 1) % resources.count
        return resources[currentResourceIndex]
    }
    
    /// Request Music by resource id
    ///
    /// - Parameters:
    ///   - resourceID: Resource id
    ///   - response: MusicPlayerResponse
    func request(_ resourceID: String, response: MusicPlayerResponse? = nil) {
        
        guard let index = resources.index(where: { $0.id == resourceID }) else { response?.failed?(MusicError.resourcesError(.noResource)); return }
        let resource = resources[index]
        guard let musicUrl = resource.musicUrl else { response?.failed?(MusicError.resourcesError(.invalidURL)); return }
        
        if resource.resourceSource == .network {
            
            var data: Data?
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "com.xwjack.music.musicResourceManager.request", attributes: .concurrent, target: .global())
            
            group.enter()
            // Request Music Source
            MusicNetwork.default.request(musicUrl, response: MusicResponse(response: {
                response?.music.response?($0)
            }, progress: {
                response?.music.progress?($0)
            }, success: {
                data = $0
                group.leave()
            }, failed: {
                print($0)
                group.leave()
            }))
            
            group.enter()
            // Request Music Lyric
            MusicNetwork.default.request(MusicAPI.default.lyric(musicID: resourceID), success: {
                
                let lyricModel = LyricModel($0)
                self.resources[index].lyric = lyricModel.lyric
                response?.lyric.success?(lyricModel.lyric)
                group.leave()
            }, failed: {
                print($0)
                group.leave()
            })
            
            group.notify(queue: queue, execute: {
                guard let validData = data else { return }
                self.cache(&self.resources[index], data: validData)
            })
            
        } else {
            //TODO: Globle dispatch to read file
            
            //Reading Music File
            guard let data = try? FileHandle(forReadingFrom: musicUrl).readDataToEndOfFile() else { response?.failed?(MusicError.resourcesError(.invalidData)); return  }
            let progress = Progress(totalUnitCount: Int64(data.count))
            progress.completedUnitCount = Int64(data.count)
            
            response?.music.response?(data)
            response?.music.progress?(progress)
            
            // Reading Music Lyric
            guard let infoData = try? FileHandle(forReadingFrom: musicUrl.appendingPathExtension("info")).readDataToEndOfFile() else { response?.failed?(MusicError.resourcesError(.invalidInfo)); return }
            let resource = MusicResource(JSON(data: infoData))
            response?.lyric.success?(resource.lyric ?? "Empty Lyric")
        }
    }
    
    func download(_ resourceID: String, response: MusicResponse? = nil) {
        guard let index = resources.index(where: { $0.id == resourceID }) else { response?.failed?(MusicError.resourcesError(.noResource)); return }
        let resource = resources[index]
        //TODO:
    }
    
    private func cache(_ resource: inout MusicResource, data: Data) {
        var resource = resource
        resource.resourceSource = .cache
        resource.md5 = resource.id.md5()
        
        guard let md5 = resource.md5 else { assertionFailure("MD5 error for resource"); return }
        try? FileHandle(forWritingTo: MusicFileManager.default.musicCacheURL.appendingPathComponent(md5)).write(data)
        try? resource.codeing.write(to: MusicFileManager.default.musicCacheURL.appendingPathComponent(md5 + ".info"), atomically: true, encoding: .utf8)
    }
    
    private func save(_ resource: MusicResource) {
        var resource = resource
//        resource.isCached = false
//        resource.isDownload = true
        resource.md5 = resource.id.md5()
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
