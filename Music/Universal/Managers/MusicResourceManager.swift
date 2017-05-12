//
//  MusicResourceManager.swift
//  Music
//
//  Created by Jack on 5/6/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation
import Log

typealias MusicResourceIdentifier = String

typealias MusicResourceCollection = [MusicResourceIdentifier: MusicResource]

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
    var name: String = ""
    var md5: String? = nil
    var resourceSource: ResourceSource = .network
    var musicUrl: URL? = nil
    var lyric: String? = nil
    var picUrl: URL? = nil
    
    init(id: String) {
        self.id = id
    }
    
    init(_ json: JSON) {
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
        
        DispatchQueue.global().async {
            self.cachedResourceList = MusicFileManager.default.search(fromURL: MusicFileManager.default.musicCacheURL)
            self.downloadedResouceList = MusicFileManager.default.search(fromURL: MusicFileManager.default.musicDownloadURL)
        }
    }
    
    /// Rest Resources
    ///
    /// - Parameters:
    ///   - resources: Collection for MusicResourceIdentifier
    ///   - resourceIndex: Begin music resource index
    ///   - mode: MusicPlayerPlayMode
    func reset(_ resources: [MusicResource],
               withIdentifier identifier: String,
               resourceIndex: Int,
               withMode mode: MusicPlayerPlayMode? = nil) {
        
        if let mode = mode { self.resourceLoadMode = mode }
        self.currentResourceIndex = resourceIndex
        self.currentRandomResourceIndex = randomResourceIndexs.index(of: resourceIndex) ?? 0
        
        guard self.currentResourceIdentifier != identifier else { return }
        
        self.currentResourceIdentifier = identifier
        self.resources = resources
        self.randomResourceIndexs = uniqueRandom(0...resources.count - 1)
        self.currentRandomResourceIndex = randomResourceIndexs.index(of: resourceIndex)!
        
//        self.resources.filter{ cachedResourceList[$0.id] != nil }
//        self.resources.sor
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
            
            guard let index = self.resources.index(where: { $0.id == resourceId }) else { failedBlock?(MusicError.resourcesError(.noResource)); return }
            let originResource = self.resources[index]
            guard let musicUrl = originResource.musicUrl else { failedBlock?(MusicError.resourcesError(.invalidURL)); return }
            
            var data: Data?
            let cacheGroup = DispatchGroup()
            let resourceGroup = DispatchGroup()
            
            //Reading Music Data
            if originResource.resourceSource == .network {
                cacheGroup.enter()
                // Request Music Source
                MusicNetwork.default.request(musicUrl,
                                             response: MusicResponse(responseData: responseBlock,
                                                                     progress: progressBlock,
                                                                     response: {
                                                                        cacheGroup.leave()
                                             }, success: {
                                                data = $0
                                             }, failed: failedBlock))
                
            } else {
                //Reading Music File
                guard let data = try? FileHandle(forReadingFrom: musicUrl).readDataToEndOfFile() else { failedBlock?(MusicError.fileError(.readingError)); return  }
                let progress = Progress(totalUnitCount: Int64(data.count))
                progress.completedUnitCount = Int64(data.count)
                
                responseBlock?(data)
                progressBlock?(progress)
            }
            
            //Request Lyric
            if originResource.lyric == nil {
                cacheGroup.enter()
                resourceGroup.enter()
                MusicNetwork.default.request(MusicAPI.default.lyric(musicID: originResource.id), response: { (_, _, _) in
                    cacheGroup.leave()
                    resourceGroup.leave()
                }, success: {
                    guard let lyric = $0["lrc"]["lyric"].string else { return }
                    self.resources[index].lyric = lyric
                }, failed: failedBlock)
            }
            
            //        if originResource.
            
            // Reading Music Lyric
            //        guard let infoData = try? FileHandle(forReadingFrom: musicUrl.appendingPathExtension("info")).readDataToEndOfFile() else { failedBlock?(MusicError.resourcesError(.invalidInfo)); return }
            //        let resource = MusicResource(JSON(data: infoData))
            //        response?.lyric.success?(resource.lyric ?? "Empty Lyric")
            
            //        group.enter()
            //        // Request Music Lyric
            //        MusicNetwork.default.request(MusicAPI.default.lyric(musicID: resourceID), success: {
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
            
            cacheGroup.notify(queue: self.cacheQueue, execute: {
                guard let validData = data else { return }
                self.cache(&self.resources[index], data: validData)
            })
            
            resourceGroup.notify(queue: .main, execute: {
                resourceBlock?(self.resources[index])
            })
        }
    }
    
//    func download(_ resourceId: MusicResourceIdentifier, response: MusicResponse? = nil) {
//        guard let index = resources.index(where: { $0.id == resourceId }) else { response?.failed?(MusicError.resourcesError(.noResource)); return }
//        let resource = resources[index]
//        //TODO:
//    }
    
    private func cache(_ resource: inout MusicResource, data: Data) {
        resource.resourceSource = .cache
        resource.md5 = resource.id.md5()
        
        guard let md5 = resource.md5 else { assertionFailure("MD5 error for resource"); return }
        do {
            ConsoleLog.verbose("Cache music: " + md5)
            let musicUrl = MusicFileManager.default.musicCacheURL.appendingPathComponent(md5)
            try data.write(to: musicUrl)
            try resource.codeing.write(toFile: MusicFileManager.default.musicCacheURL.appendingPathComponent(md5 + ".info").path, atomically: true, encoding: .utf8)
            resource.musicUrl = musicUrl
            cachedResourceList[resource.id] = resource
        } catch {
            ConsoleLog.error(error.localizedDescription)
        }
        
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
