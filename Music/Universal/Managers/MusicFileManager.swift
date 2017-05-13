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
    
    /// Clear Cache
    ///
    /// - Parameter completed: Completed clear
    func clearCache(_ completed: (() -> ())? = nil) {
        ThirdFileManager.shared.cache.clearDiskCache {
            self.ioQueue.async {
                self.clear(self.musicCacheURL)
                self.clear(self.musicDownloadURL)
                self.createMusicCacheDirectory()
                self.createMusicDownloadDirectory()
                DispatchQueue.main.async {
                    completed?()
                }
            }
        }
    }
    
    /// Calculate Cahe size
    ///
    /// - Parameter completed: Completed calculate
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
        
        ThirdFileManager.shared.cache.calculateDiskCacheSize { (kingfisherSize) in
            self.ioQueue.async {
                
                let musicCacheSize = calculateFileSize(in: self.musicCacheURL)
                let musicDownloadSize = calculateFileSize(in: self.musicDownloadURL)
                
                DispatchQueue.main.async {
                    completed(Int64(kingfisherSize) + musicCacheSize + musicDownloadSize)
                }
            }
        }
    }
    
    /// Search MusicResourceCollection by url
    ///
    /// - Parameter url: URL
    /// - Returns: MusicResourceCollection
    func search(fromURL url: URL) -> MusicResourceCollection {
        var results: MusicResourceCollection = [:]
        
        if let contents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
            contents.filter({ $0.pathExtension == "info" }).forEach {
                
                guard let fileContent = FileHandle(forReadingAtPath: $0.path)?.readDataToEndOfFile() else { return }
                var resource = MusicResource(JSON(data: fileContent))
                resource.resourceSource = url == musicCacheURL ? .cache : .download
                resource.musicUrl = $0.deletingPathExtension()
                results[resource.id] = resource
                
            }
            
        }
        return results
    }
    
    /// Delete from url is exist
    ///
    /// - Parameter url: URL
    private func clear(_ url: URL) {
        if fileManager.fileExists(atPath: url.path) {
            try? fileManager.removeItem(at: url)
        }
    }
    
    /// Create Music Cache Directory if not exist
    private func createMusicCacheDirectory() {
        if !fileManager.fileExists(atPath: musicCacheURL.path) {
            try? fileManager.createDirectory(at: musicCacheURL, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    /// Create Music Download Directory if not exist
    private func createMusicDownloadDirectory() {
        if !fileManager.fileExists(atPath: musicDownloadURL.path) {
            try? fileManager.createDirectory(at: musicDownloadURL, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
