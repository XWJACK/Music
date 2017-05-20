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
class MusicResource {
    
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
    var duration: TimeInterval = 0.1
    
    var resourceSource: ResourceSource = .network
    
    var lyric: MusicLyricModel?
    var info: MusicResouceInfoModel?
    var album: MusicAlbumModel?
    var artist: MusicArtistModel?
    
    init(id: String) {
        self.id = id
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
    
    /// Background serial cache queue
    private let cacheQueue: DispatchQueue
    
    private let playResourceQueue: DispatchQueue
    private var playResources: [String: ((Data) -> ())?] = [:]
    
    
    private var dataBaseManager: MusicDataBaseManager { return MusicDataBaseManager.default }
    private var fileManager: MusicFileManager { return MusicFileManager.default }
    
    private init() {
        
        playResourceQueue = DispatchQueue(label: "com.xwjack.Music.MusicResourceManager.playResourceQueue",
                                          qos: .default,
                                          attributes: [.concurrent])
        
        cacheQueue = DispatchQueue(label: "com.xwjack.Music.MusicResourceManager.cacheQueue",
                                   qos: .background)
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
        
        let cacheList = dataBaseManager.cacheList()
        let downloadList = dataBaseManager.downloadList()
        
        for (index, resource) in self.resources.enumerated() where cacheList.contains(resource.id) {
            self.resources[index].resourceSource = .cache
        }
        
        for (index, resource) in self.resources.enumerated() where downloadList.contains(resource.id) {
            self.resources[index].resourceSource = .download
        }
    }
    
    /// Get Current MusicResource
    ///
    /// - Returns: MusicResource
    func current() -> MusicResource {
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
    

    func register(_ resourceId: MusicResourceIdentifier,
                  responseBlock: ((Data) -> ())? = nil,
                  resourceBlock: ((MusicResource) -> ())? = nil,
                  failedBlock: ((Error) -> ())? = { ConsoleLog.error($0) }) {
        
        playResourceQueue.async {
            
            /// Find resource by id
            guard let index = self.resources.index(where: { $0.id == resourceId }) else { failedBlock?(MusicError.resourcesError(.noResource)); return }
            let originResource = self.resources[index]
            
            var data: Data?
            let cacheGroup = DispatchGroup()
            let resourceGroup = DispatchGroup()
            
            //Reading music data from network
            if originResource.resourceSource == .network {
                
                if self.playResources[resourceId] != nil {
                    self.playResources[resourceId] = (responseBlock)
                    return
                }
                
                self.playResources[resourceId] = (responseBlock)
                
                cacheGroup.enter()
                // Request Music Source
                MusicNetwork.send(API.musicUrl(musicID: originResource.id))
                    .receive(queue: .global(), json: { (json) in
                        
                    guard let firstJson = json["data"].array?.first else { return }
                    let model = MusicResouceInfoModel(firstJson)
                    originResource.info = model
                    
                    guard let url = model.url else { failedBlock?(MusicError.resourcesError(.invalidURL)); return }
                        
                    MusicNetwork.send(url)
                        .receive(data: { self.playResources[resourceId]??($0) })
                        .receive(queue: self.cacheQueue, response: { cacheGroup.leave() })
                        .receive(queue: self.cacheQueue, success: { data = $0 })
                })
                
                //Request Lyric if not exist
                if originResource.lyric?.lyric == nil {
                    cacheGroup.enter()
                    resourceGroup.enter()
                    
                    MusicNetwork.send(API.lyric(musicID: originResource.id))
                        .receive(queue: self.cacheQueue, json: { (json) in
                            originResource.lyric = MusicLyricModel(json)
                        })
                        .receive(queue: self.cacheQueue, response: {
                            cacheGroup.leave()
                            resourceGroup.leave()
                        })
                }
                
                /// Completed request data, and now it can be cache to file
                cacheGroup.notify(queue: self.cacheQueue, execute: {
                    guard let validData = data else { return }
                    self.cache(self.resources[index], data: validData)
                })
                
            } else {// Reading music data from local
                ConsoleLog.verbose("Reading: " + originResource.id + " music from local")
                
                let readingFromLocal: (URL) -> () = {
                    //Reading Music File
                    do {
                        let data = try FileHandle(forReadingFrom: $0).readDataToEndOfFile()
                        DispatchQueue.main.async {
                            responseBlock?(data)
                        }
                    } catch {
                        failedBlock?(MusicError.fileError(.readingError))
                        ConsoleLog.error(error)
                        return
                    }
                }
                
                /// Aleardy reading data from database
                if let musicUrl = originResource.info?.url {
                    readingFromLocal(musicUrl)
                } else {
                    guard let localResource = self.dataBaseManager.get(originResource.id) else { failedBlock?(MusicError.resourcesError(.noResource)); return }
                    localResource.resourceSource = originResource.resourceSource
                    localResource.info?.url = localResource.resourceSource == .cache ? self.fileManager.musicCacheURL.appendingPathComponent(localResource.info!.md5) : self.fileManager.musicDownloadURL.appendingPathComponent(localResource.info!.md5)
                    self.resources[index] = localResource
                    readingFromLocal(localResource.info!.url!)
                }
            }
            
            /// Completed request resource
            resourceGroup.notify(queue: .main, execute: {
                resourceBlock?(self.resources[index])
            })
        }
    }
    
    func unRegister(_ resourceId: MusicResourceIdentifier) {
        guard playResources[resourceId] != nil else { return }
        playResources[resourceId] = (nil)
    }

    private func destoryRegister(_ resourceId: MusicResourceIdentifier) {
        playResources[resourceId] = nil
    }
    
    /// Cache resource to local
    ///
    /// - Parameters:
    ///   - resource: MusicResource
    ///   - data: Music Data
    private func cache(_ resource: MusicResource, data: Data) {
        guard let md5 = resource.info?.md5 else { ConsoleLog.error("No MD5 in resource: " + resource.id); return }
        do {
            ConsoleLog.verbose("Cache music: \(resource)")
            let musicUrl = fileManager.musicCacheURL.appendingPathComponent(md5)
            try data.write(to: musicUrl)
            resource.info?.url = musicUrl
            resource.resourceSource = .cache
            MusicDataBaseManager.default.cache(resource)
            destoryRegister(resource.id)
        } catch {
            ConsoleLog.error(error)
        }
    }
    
    private func save(_ resource: MusicResource) {
//        resource.isCached = false
//        resource.isDownload = true
//        resource.md5 = resource.id.md5()
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
