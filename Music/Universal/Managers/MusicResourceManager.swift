//
//  MusicResourceManager.swift
//  Music
//
//  Created by Jack on 5/6/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

typealias MusicResourceIdentifier = String

typealias MusicResourceCollection = [MusicResourceIdentifier: MusicResource]

/// Music Resource
class MusicResource: JSONInitable {
    
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
    var name: String = ""
    var md5: String? = nil
    var resourceSource: ResourceSource = .network
    var musicUrl: URL? = nil
    var lyric: String? = nil
    var picUrl: URL? = nil
    
    init(id: String) {
        self.id = id
    }
    
    required init(_ json: JSON) {
        id = json["id"].string ?? { assertionFailure("Error Music Id"); return "Error Id" }()
        md5 = json["md5"].string
        name = json["name"].stringValue
        picUrl = json["picUrl"].url
        lyric = json["lyric"].string
    }
    
    var codeing: String {
        var code: [String: String] = ["id": id, "md5": md5 ?? { assertionFailure("Codeing with MD5 Error"); return "Error MD5" }()]
        code["lyric"] = lyric
        code["picUrl"] = picUrl?.absoluteString
        code["name"] = name
        
        return JSON(code).rawString([.jsonSerialization: true]) ?? ""
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
    private var cacheQueue: DispatchQueue
    
    private init() {
        cacheQueue = DispatchQueue(label: "com.xwjack.Music.MusicResourceManager.cacheQueue",
                                   qos: .background,
                                   target: .global())
        
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
        
//        for (index, resource) in self.resources.enumerated() where cachedResourceList[resource.id] != nil {
//            self.resources[index] = cachedResourceList[resource.id]!
//        }
//        
//        for (index, resource) in self.resources.enumerated() where downloadedResouceList[resource.id] != nil {
//            self.resources[index] = downloadedResouceList[resource.id]!
//        }
    }
    
    /// Get Current MusicResourceIdentifier
    ///
    /// - Returns: MusicResourceIdentifier
    func current() -> MusicResourceIdentifier {
        return resources[currentResourceIndex].id
    }
    
    /// Last MusicResourceIdentifier
    ///
    /// - Returns: MusicResourceIdentifier
    func last() -> MusicResourceIdentifier {
        
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
    
    /// Next MusicResourceIdentifier
    ///
    /// - Returns: MusicResourceIdentifier
    func next() -> MusicResourceIdentifier {
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
    
    /// Request Music by resource id
    ///
    /// - Parameters:
    
    ///   - resourceId: Resource id
    ///   - response: MusicPlayerResponse
    func request(_ resourceId: String,
                 responseBlock: ((Data) -> ())? = nil,
                 progressBlock: ((Progress) -> ())? = nil,
                 resourceBlock: ((MusicResource) -> ())? = nil,
                 failedBlock: ((Error) -> ())? = { ConsoleLog.error($0) }) {
        
        DispatchQueue.global().async {
            
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
                MusicNetwork.default.request(API.default.musicUrl(musicID: originResource.id), success: { (json) in
                    
                    guard let firstJson = json["data"].array?.first else { return }
                    let model = MusicResouceInfoModel(firstJson)
                    guard let url = model.url else { failedBlock?(MusicError.resourcesError(.invalidURL)); return }
                    originResource.musicUrl = url
                    
                    MusicNetwork.default.request(url, response: MusicResponse(responseData: responseBlock, progress: progressBlock, response: { 
                        cacheGroup.leave()
                    }, success: {
                        data = $0
                    }, failed: failedBlock))
                                                
                }, failed: failedBlock)
                
            } else {// Reading music data from local
                ConsoleLog.verbose("Reading: " + originResource.id + " music from local")
                guard let musicUrl = originResource.musicUrl else { failedBlock?(MusicError.resourcesError(.invalidURL)); return }
                //Reading Music File
                guard let data = try? FileHandle(forReadingFrom: musicUrl).readDataToEndOfFile() else {
                    failedBlock?(MusicError.fileError(.readingError))
                    /// Then request from network
                    originResource.resourceSource = .network
                    self.request(originResource.id, responseBlock: responseBlock, progressBlock: progressBlock, resourceBlock: resourceBlock, failedBlock: failedBlock)
                    return
                }
                let progress = Progress(totalUnitCount: Int64(data.count))
                progress.completedUnitCount = Int64(data.count)
                
                responseBlock?(data)
                progressBlock?(progress)
            }
            
            //Request Lyric if not exist
            if originResource.lyric == nil {
                cacheGroup.enter()
                resourceGroup.enter()
                MusicNetwork.default.request(API.default.lyric(musicID: originResource.id), response: { (_, _, _) in
                    cacheGroup.leave()
                    resourceGroup.leave()
                }, success: {
                    guard let lyric = $0["lrc"]["lyric"].string else { return }
                    originResource.lyric = lyric
                }, failed: failedBlock)
            }
            
            //        if originResource.
            
            // Reading Music Lyric
            //        guard let infoData = try? FileHandle(forReadingFrom: musicUrl.appendingPathExtension("info")).readDataToEndOfFile() else { failedBlock?(MusicError.resourcesError(.invalidInfo)); return }
            //        let resource = MusicResource(JSON(data: infoData))
            //        response?.lyric.success?(resource.lyric ?? "Empty Lyric")
            
            //        group.enter()
            //        // Request Music Lyric
            //        MusicNetwork.default.request(API.default.lyric(musicID: resourceID), success: {
            //
            //            let lyricModel = MusicLyricModel($0)
            //            self.resources[index].lyric = lyricModel.lyric
            //            response?.lyric.success?(lyricModel.lyric)
            //            group.leave()
            //        }, failed: {
            //            print($0)
            //            group.leave()
            //        })
            //
            
            /// Completed request data, and now it can be cache to file
            cacheGroup.notify(queue: self.cacheQueue, execute: {
                guard let validData = data else { return }
                self.cache(originResource, data: validData)
            })
            
            /// Completed request resource
            resourceGroup.notify(queue: .main, execute: {
                resourceBlock?(originResource)
            })
        }
    }
    
//    func download(_ resourceId: MusicResourceIdentifier, successBlock: (() -> ())? = nil) {
//        
//        if let index = resources.index(where: { $0.id == resourceId }) {
//            let originResource = resources[index]
//        }
//    }

    private func cache(_ resource: MusicResource, data: Data) {
        resource.resourceSource = .cache
        resource.md5 = resource.id.md5()
        
        guard let md5 = resource.md5 else { ConsoleLog.error("MD5 Error for resource: " + resource.id); return }
        do {
            ConsoleLog.verbose("Cache music: " + md5)
            let musicUrl = MusicFileManager.default.musicCacheURL.appendingPathComponent(md5)
            try data.write(to: musicUrl)
            try resource.codeing.write(toFile: MusicFileManager.default.musicCacheURL.appendingPathComponent(md5 + ".info").path, atomically: true, encoding: .utf8)
            resource.musicUrl = musicUrl
        } catch {
            ConsoleLog.error(error.localizedDescription)
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
                resource.musicUrl = $0.deletingPathExtension()
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
