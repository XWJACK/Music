//
//  MusicFileManager.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

final class MusicFileManager {
    
    static let `default` = MusicFileManager()
    
    private let fileManager = FileManager.default
    private let ioQueue: DispatchQueue
    
    let musicCacheURL: URL
    let musicDownloadURL: URL
    let libraryURL: URL
    
    private init() {
        libraryURL = try! fileManager.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        musicCacheURL = libraryURL.appendingPathComponent("Music/Cache/")
        musicDownloadURL = libraryURL.appendingPathComponent("Music/Download/")
        ioQueue = DispatchQueue(label: "com.xwjack.music.fileManager")
        createMusicCacheDirectory()
        createMusicDownloadDirectory()
    }
    
    func clearCache(_ completed: (() -> ())? = nil) {
        
        ioQueue.async {
            self.clear(self.musicCacheURL)
            self.clear(self.musicDownloadURL)
            self.createMusicCacheDirectory()
            DispatchQueue.main.async {
                completed?()
            }
        }
    }
    
    func calculateCache(_ completed: @escaping (Int64) -> ()) {
        
        func calculateFileSize(in url: URL) -> Int64 {
            let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .totalFileAllocatedSizeKey]
            var diskCacheSize: Int64 = 0
            
            guard let fileEnumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles, errorHandler: nil),
                let urls = fileEnumerator.allObjects as? [URL] else {
                    return diskCacheSize
            }
            
            for fileUrl in urls {
                
                do {
                    let resourceValues = try fileUrl.resourceValues(forKeys: resourceKeys)
                    // If it is a Directory. Continue to next file URL.
                    if resourceValues.isDirectory == true {
                        continue
                    }
                    
                    if let fileSize = resourceValues.totalFileAllocatedSize {
                        diskCacheSize += Int64(fileSize)
                    }
                } catch _ { }
            }
            
            return diskCacheSize
        }
        
        ioQueue.async {
            
            let musicCacheSize = calculateFileSize(in: self.musicCacheURL)
            let musicDownloadSize = calculateFileSize(in: self.musicDownloadURL)
                
            DispatchQueue.main.async {
                completed(Int64(musicCacheSize + musicDownloadSize))
            }
        }
    }
    
    func cache(by resourceMD5: String) {
        
    }
    
    func search(fromURL url: URL) -> MusicResourceCollection {
        if let contents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
            
            var results: MusicResourceCollection = [:]
            for content in contents.filter({ $0.pathExtension == "info" }) {
                guard let fileContent = FileHandle(forReadingAtPath: content.path)?.readDataToEndOfFile() else { continue }
                var data = MusicResource(JSON(data: fileContent))
                data.isCached = url == musicCacheURL
                data.isDownload = url == musicDownloadURL
                data.resourceURL = content
                results[data.resourceID] = data
            }
            
        }
        return [:]
    }
    
    private func clear(_ url: URL) {
        /// 删除音乐缓存目录
        if fileManager.fileExists(atPath: url.path) {
            try? fileManager.removeItem(at: url)
        }
    }
    
    private func createMusicCacheDirectory() {
        /// 创建音乐缓存目录
        if !fileManager.fileExists(atPath: musicCacheURL.path) {
            try? fileManager.createDirectory(at: musicCacheURL, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    private func createMusicDownloadDirectory() {
        /// 创建音乐下载目录
        if !fileManager.fileExists(atPath: musicDownloadURL.path) {
            try? fileManager.createDirectory(at: musicDownloadURL, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
