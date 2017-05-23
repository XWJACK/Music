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
    
    private(set) var resources: [MusicResource] = []
    private var randomResourceIndexs: [Int] = []
    
    private var currentResourceIndex: Int = 0
    private var currentRandomResourceIndex: Int = 0
    
    private var playResources: [String: Client] = [:]
    
    
    private var threadManager: ThreadManager { return ThreadManager.default }
    private var dataBaseManager: MusicDataBaseManager { return MusicDataBaseManager.default }
    private var fileManager: MusicFileManager { return MusicFileManager.default }
    
    private init() {
        resources = dataBaseManager.getLeastResources()
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
                  failedBlock: ((Error) -> ())? = { ConsoleLog.error($0) }) {
        
        /// Find resource by id
        guard let index: Int = resources.index(where: { $0.id == resourceId }) else { failedBlock?(MusicError.resourcesError(.noResource)); return }
        let originResource: MusicResource = resources[index]
        
        var data: Data?
        let cacheGroup: DispatchGroup = DispatchGroup()
        
        //Reading music data from network
        if originResource.resourceSource == .network {
            cacheGroup.enter()
            
            self.musicUrl(originResource.id, block: { (model) in
                originResource.info = model
                guard let url = model?.url else { failedBlock?(MusicError.resourcesError(.invalidURL)); return }
                
                ConsoleLog.verbose("Request Music Data")
                self.playResources[originResource.id] =
                    MusicNetwork.send(url)
                        .receive(queue: self.threadManager.audioParseQueue, data: responseBlock)
                        .receive(queue: self.threadManager.resourceQueue, response: { cacheGroup.leave() })
                        .receive(queue: self.threadManager.resourceQueue, success: { data = $0 })
            })
            
            if originResource.lyric?.lyric == nil {
                cacheGroup.enter()
                self.lyric(originResource.id, block: { (model) in
                    originResource.lyric = model
                    cacheGroup.leave()
                })
            }
            
            /// Completed request data, and now it can be cache to file
            cacheGroup.notify(queue: self.threadManager.resourceQueue, execute: {
                guard let validData = data else { return }
                self.cache(originResource, data: validData)
            })
            
        } else {// Reading music data from local
            ConsoleLog.verbose("Reading: " + originResource.id + " music from " + (originResource.resourceSource == .cache ? "Cache" : "Download"))
            
            let readingFromLocal: (URL) -> () = { url in
                //Reading Music File
                self.threadManager.audioParseQueue.async {
                    do {
                        let data: Data = try FileHandle(forReadingFrom: url).readDataToEndOfFile()
                        responseBlock?(data)
                    } catch {
                        failedBlock?(MusicError.fileError(.readingError))
                        ConsoleLog.error(error)
                        return
                    }
                }
            }
            
            /// Aleardy reading data from database
            if let musicUrl = originResource.info?.url {
                if !musicUrl.isFileURL {
                    if originResource.resourceSource == .download {
                        originResource.info?.url = self.fileManager.musicDownloadURL.appendingPathComponent(originResource.info!.md5)
                    } else {
                        originResource.info?.url = self.fileManager.musicCacheURL.appendingPathComponent(originResource.info!.md5)
                    }
                }
                readingFromLocal(originResource.info!.url!)
            } else {
                threadManager.audioParseQueue.async {
                    guard let localResource = self.dataBaseManager.get(resourceId: originResource.id) else { failedBlock?(MusicError.resourcesError(.noResource)); return }
                    localResource.info?.url = localResource.resourceSource == .cache ? self.fileManager.musicCacheURL.appendingPathComponent(localResource.info!.md5) : self.fileManager.musicDownloadURL.appendingPathComponent(localResource.info!.md5)

                    originResource.lyric = localResource.lyric
                    originResource.info = localResource.info
                    
                    readingFromLocal(localResource.info!.url!)
                }
            }
        }
    }
    
    /// Get music info from resource id
    ///
    /// - Parameters:
    ///   - resourceId: MusicResourceIdentifier
    ///   - block: MusicResouceInfoModel block
    func musicUrl(_ resourceId: MusicResourceIdentifier, block: @escaping (MusicResouceInfoModel?) -> ()) {
        // Request Music Source
        ConsoleLog.verbose("Request Music Info")
        MusicNetwork.send(API.musicUrl(musicID: resourceId))
            .receive(queue: .global(), json: { (json) in
                guard let firstJson = json["data"].array?.first else { block(nil); return }
                block(MusicResouceInfoModel(firstJson))
            })
            .receive(queue: .global(), failed: { _ in block(nil) })
    }
    
    /// Get lyric from resource id
    ///
    /// - Parameters:
    ///   - resourceId: MusicResourceIdentifier
    ///   - block: MusicLyricModel block
    func lyric(_ resourceId: MusicResourceIdentifier, block: @escaping (MusicLyricModel?) -> ()) {
        ConsoleLog.verbose("Request Lyric")
        MusicNetwork.send(API.lyric(musicID: resourceId))
            .receive(queue: .global(), json: { block(MusicLyricModel($0)) })
            .receive(queue: .global(), failed: { _ in block(nil) })
    }
    
    func unRegister(_ resourceId: MusicResourceIdentifier) {
        playResources[resourceId]?.task.cancel()
        destoryRegister(resourceId)
    }

    func clear() {
        resources.filter{ $0.resourceSource != .download }.forEach{ $0.resourceSource = .network }
    }
    
    func download(_ resource: MusicResource,
                  successBlock: (() -> ())? = nil,
                  progressBlock: ((Progress) -> ())? = nil) {
        
        switch resource.resourceSource {
        case .download: return
        case .cache:
            ConsoleLog.verbose("Move Cache file to Download")
            guard let url: URL = resource.info?.url else { return }
            download(resource, withFileURL: url)

            let progress = Progress(totalUnitCount: 1)
            progress.completedUnitCount = 1
            
            successBlock?()
            progressBlock?(progress)
        case .network:
            ConsoleLog.verbose("Download music file from network")
            let downloadGroup: DispatchGroup = DispatchGroup()
            var url: URL?
            let downloadBlock: (URL) -> () = {
                MusicNetwork.download($0)
                    .receive(queue: self.threadManager.resourceQueue, download: {
                        url = $0
                        downloadGroup.leave()
                    })
            }
            
            downloadGroup.enter()
            if let musicUrl = resource.info?.url {
                downloadBlock(musicUrl)
            } else {
                musicUrl(resource.id, block: { (model) in
                    resource.info = model
                    guard let musicUrl: URL = model?.url else { return }
                    downloadBlock(musicUrl)
                })
            }
            
            //TODO: 这里为了保持数据库中数据完整性。
            if resource.lyric?.lyric == nil {
                downloadGroup.enter()
                self.lyric(resource.id, block: { (model) in
                    resource.lyric = model
                    downloadGroup.leave()
                })
            }
            
            /// Completed download Info.
            downloadGroup.notify(queue: self.threadManager.resourceQueue, execute: {
                guard let validUrl = url else { return }
                self.download(resource, withFileURL: validUrl)
                successBlock?()
            })
        }
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
            dataBaseManager.cache(resource)
            destoryRegister(resource.id)
        } catch {
            ConsoleLog.error(error)
        }
    }
    
    private func download(_ resource: MusicResource, withFileURL url: URL) {
        guard let md5 = resource.info?.md5 else { ConsoleLog.error("No MD5 in resource: " + resource.id); return }
        do {
            ConsoleLog.verbose("Download music: \(resource)")
            let musicUrl = fileManager.musicDownloadURL.appendingPathComponent(md5)
            try FileManager.default.moveItem(at: url, to: musicUrl)
            resource.info?.url = musicUrl
            resource.resourceSource = .download
            dataBaseManager.download(resource)
        } catch {
            ConsoleLog.error(error)
        }
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
