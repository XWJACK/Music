//
//  MusicResourceManager.swift
//  Music
//
//  Created by Jack on 5/6/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

typealias MusicResourceIdentifier = String
typealias ResponseData = (Data) -> ()
typealias MusicResourceCollection = [MusicResourceIdentifier: MusicResource]

/// Music Resource
class MusicResource: JSONInitable, CustomDebugStringConvertible, CustomStringConvertible {
    
    /// Source of Resource
    ///
    /// - cache: Cache
    /// - download: Download
    /// - buffering: In Buffering
    /// - network: Network
    enum ResourceSource {
        case cache
        case download
        case network
    }
    
    let id: String
    var name: String = ""
    var duration: TimeInterval?
    
    var resourceSource: ResourceSource = .network
    
    var lyric: MusicLyricModel?
    var info: MusicResouceInfoModel?
    var album: MusicAlbumModel?
    
    init(id: String) {
        self.id = id
    }
    
    required init(_ json: JSON) {
        id = json["id"].string ?? { assertionFailure("Error Music Id"); return "Error Id" }()
        name = json["name"].stringValue
        duration = json["duration"].double
        
        lyric = MusicLyricModel(json["lyric"])
        info = MusicResouceInfoModel(json["info"])
        album = MusicAlbumModel(json["album"])
    }
    
    var encode: String {
        var dic: [String: Any] = ["id": id]
        dic["name"] = name
        dic["duration"] = duration
        
        dic["lyric"] = lyric?.encode
        dic["info"] = info?.encode
        dic["album"] = album?.encode
        
        return JSON(dic).rawString() ?? ""
    }
    
    var debugDescription: String {
        return description
    }
    
    var description: String {
        return  "- id: \(id)\n" +
                "- name: \(name)\n" +
                "- duration: \(duration ?? nil)\n" +
                "- lyric: \(lyric ?? nil)\n" +
                "- info: \(info ?? nil)\n" +
                "- album: \(album ?? nil)\n"
    }
}

class MusicResourceManager {
    
    static let `default` = MusicResourceManager()
    
    var resourceLoadMode: MusicPlayerPlayMode = .order
    
    private var currentResourceIdentifier: String = ""
    
    private var resources: [MusicResource] = []
    private var randomResourceIndexs: [Int] = []
    
    private var currentResourceIndex: Int = 0
    private var currentRandomResourceIndex: Int = 0
    
    private var cachedResourceList: MusicResourceCollection = [:]
    private var downloadedResouceList: MusicResourceCollection = [:]
    
    
    /// Background serial cache queue
    private let cacheQueue: DispatchQueue
    
    private let playResourceQueue: DispatchQueue
    private var playResources: [String: (responseBlock: ((Data) -> ())?, progressBlock: ((Progress) -> ())?, resourceBlock: ((MusicResource) -> ())?)] = [:]
    
    private init() {
        
        playResourceQueue = DispatchQueue(label: "com.xwjack.Music.MusicResourceManager.playResourceQueue",
                                          qos: .default,
                                          attributes: [.concurrent])
        
        cacheQueue = DispatchQueue(label: "com.xwjack.Music.MusicResourceManager.cacheQueue",
                                   qos: .background)
        
//        DispatchQueue.global().async {
            cachedResourceList = search(fromURL: MusicFileManager.default.musicCacheURL)
            downloadedResouceList = search(fromURL: MusicFileManager.default.musicDownloadURL)
//        }
    }
    
    /// Rest Resources, only effective if identifier is different
    ///
    /// - Parameters:
    ///   - resources: Collection for MusicResourceIdentifier
    ///   - resourceIndex: Begin music resource index
    ///   - mode: MusicPlayerPlayMode
    func reset(_ resources: [MusicResource],
               withIdentifier identifier: String,
               currentResourceIndex: Int,
               withMode mode: MusicPlayerPlayMode? = nil) {
        
        if let mode = mode { self.resourceLoadMode = mode }
        self.currentResourceIndex = currentResourceIndex
        self.currentRandomResourceIndex = randomResourceIndexs.index(of: currentResourceIndex) ?? 0
        
        guard self.currentResourceIdentifier != identifier else { return }
        
        self.currentResourceIdentifier = identifier
        self.resources = resources
        self.randomResourceIndexs = uniqueRandom(0...resources.count - 1)
        self.currentRandomResourceIndex = randomResourceIndexs.index(of: currentResourceIndex)!
        
        for (index, resource) in self.resources.enumerated() where cachedResourceList[resource.id] != nil {
            self.resources[index] = cachedResourceList[resource.id]!
        }
        
        for (index, resource) in self.resources.enumerated() where downloadedResouceList[resource.id] != nil {
            self.resources[index] = downloadedResouceList[resource.id]!
        }
    }
    
    /// Get Current MusicResource
    ///
    /// - Returns: MusicResource
    func current() -> MusicResource {
//        guard currentResourceIndex < resources.count else { return }
        return resources[currentResourceIndex]
    }
    
    /// Last MusicResource
    ///
    /// - Returns: MusicResource
    func last() -> MusicResource {
        
        switch resourceLoadMode {
        case .order:
            if currentResourceIndex == 0 { currentResourceIndex = resources.count - 1 }
            else { currentResourceIndex -= 1 }
        case .random:
            if currentResourceIndex == 0 { currentResourceIndex = randomResourceIndexs.count - 1 }
            else { currentResourceIndex -= 1 }
            currentResourceIndex = randomResourceIndexs[currentRandomResourceIndex]
        default: break
        }
        return current()
    }
    
    /// Next MusicResource
    ///
    /// - Returns: MusicResource
    func next() -> MusicResource {
        switch resourceLoadMode {
        case .order:
            currentResourceIndex = (currentResourceIndex + 1) % resources.count
        case .random:
            currentRandomResourceIndex = (currentRandomResourceIndex + 1) % randomResourceIndexs.count
            currentResourceIndex = randomResourceIndexs[currentRandomResourceIndex]
        default: break
        }
        return current()
    }
    

    func register(_ resourceId: String,
                  responseBlock: ((Data) -> ())? = nil,
                  progressBlock: ((Progress) -> ())? = nil,
                  resourceBlock: ((MusicResource) -> ())? = nil,
                  failedBlock: ((Error) -> ())? = { ConsoleLog.error($0) }) {
        
        if playResources[resourceId] != nil {
            playResources[resourceId] = (responseBlock, progressBlock, resourceBlock)
            return
        }
        
        playResources[resourceId] = (responseBlock, progressBlock, resourceBlock)
        
        playResourceQueue.async {
            
            /// Find resource by id
            guard let index = self.resources.index(where: { $0.id == resourceId }) else { failedBlock?(MusicError.resourcesError(.noResource)); return }
            let originResource = self.resources[index]
            
            var data: Data?
            let cacheGroup = DispatchGroup()
            let resourceGroup = DispatchGroup()
            
            //Reading music data from network
            if originResource.resourceSource == .network {
                cacheGroup.enter()
                
                // Request Music Source
                MusicNetwork.send(API.musicUrl(musicID: originResource.id))
                    .receive(queue: .global(), json: { (json) in
                        
                    guard let firstJson = json["data"].array?.first else { return }
                    let model = MusicResouceInfoModel(firstJson)
                    originResource.info = model
                    
                    guard let url = model.url else { failedBlock?(MusicError.resourcesError(.invalidURL)); return }
                        
                    MusicNetwork.send(url)
                        .receive(data: self.playResources[resourceId]?.responseBlock)
                        .receive(progress: self.playResources[resourceId]?.progressBlock)
                        .receive(queue: .global(), response: { cacheGroup.leave() })
                        .receive(queue: .global(), success: { data = $0 })
                })
                
            } else {// Reading music data from local
                ConsoleLog.verbose("Reading: " + originResource.id + " music from local")
                guard let musicUrl = originResource.info?.url else { failedBlock?(MusicError.resourcesError(.invalidURL)); return }
                //Reading Music File
                guard let data = try? FileHandle(forReadingFrom: musicUrl).readDataToEndOfFile() else {
                    failedBlock?(MusicError.fileError(.readingError))
                    /// Then request from network
                    originResource.resourceSource = .network
                    self.register(originResource.id,
                                  responseBlock: self.playResources[resourceId]?.responseBlock,
                                  progressBlock: self.playResources[resourceId]?.progressBlock,
                                  resourceBlock: self.playResources[resourceId]?.resourceBlock,
                                  failedBlock: failedBlock)
                    return
                }
                let progress = Progress(totalUnitCount: Int64(data.count))
                progress.completedUnitCount = Int64(data.count)
                
                self.playResources[resourceId]?.responseBlock?(data)
                self.playResources[resourceId]?.progressBlock?(progress)
            }
            
            //Request Lyric if not exist
            if !(originResource.lyric?.hasLyric ?? false) {
                cacheGroup.enter()
                resourceGroup.enter()
                
                MusicNetwork.send(API.lyric(musicID: originResource.id))
                    .receive(queue: .global(), json: { (json) in
                        originResource.lyric = MusicLyricModel(json)
                    })
                    .receive(queue: .global(), response: {
                        cacheGroup.leave()
                        resourceGroup.leave()
                    })
            }
            
            /// Completed request data, and now it can be cache to file
            cacheGroup.notify(queue: self.cacheQueue, execute: {
                guard let validData = data else { return }
                self.cache(originResource, data: validData)
            })
            
            /// Completed request resource
            resourceGroup.notify(queue: .main, execute: {
                self.playResources[resourceId]?.resourceBlock?(originResource)
            })
        }
    }
    
    func unRegister(_ resourceId: String) {
        guard playResources[resourceId] != nil else { return }
        playResources[resourceId] = (nil, nil, nil)
    }
    
//    func download(_ resourceId: MusicResourceIdentifier, successBlock: (() -> ())? = nil) {
//        
//        if let index = resources.index(where: { $0.id == resourceId }) {
//            let originResource = resources[index]
//        }
//    }

    
    /// Cache resource to local
    ///
    /// - Parameters:
    ///   - resource: MusicResource
    ///   - data: Music Data
    private func cache(_ resource: MusicResource, data: Data) {
        resource.info?.md5 = resource.id.md5()
        
        guard let md5 = resource.info?.md5 else { ConsoleLog.error("MD5 Error for resource: " + resource.id); return }
        do {
            ConsoleLog.verbose("Cache music: " + md5)
            let musicUrl = MusicFileManager.default.musicCacheURL.appendingPathComponent(md5)
            try data.write(to: musicUrl)
            try resource.encode.data(using: .utf8)?.write(to: MusicFileManager.default.musicCacheURL.appendingPathComponent(md5 + ".info"))
//            try resource.encode.data(using: .utf8)?.write(toFile: MusicFileManager.default.musicCacheURL.appendingPathComponent(md5 + ".info").path, atomically: true, encoding: .utf8)
            resource.info?.url = musicUrl
            resource.resourceSource = .cache
        } catch {
            ConsoleLog.error(error)
        }
    }
    
    private func save(_ resource: MusicResource) {
//        resource.isCached = false
//        resource.isDownload = true
//        resource.md5 = resource.id.md5()
    }
    
    /// Search MusicResourceCollection by url
    ///
    /// - Parameter url: URL
    /// - Returns: MusicResourceCollection
    private func search(fromURL url: URL) -> MusicResourceCollection {
        var results: MusicResourceCollection = [:]
        
        if let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
            contents.filter({ $0.pathExtension == "info" }).forEach {
                
                guard let fileContent = FileHandle(forReadingAtPath: $0.path)?.readDataToEndOfFile() else { return }
                let resource = MusicResource(JSON(data: fileContent))
                resource.resourceSource = url == MusicFileManager.default.musicCacheURL ? .cache : .download
                resource.info?.url = $0.deletingPathExtension()
                results[resource.id] = resource
            }
        }
        return results
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
