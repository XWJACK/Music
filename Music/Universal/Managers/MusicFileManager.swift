//
//  MusicFileManager.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation
import Kingfisher

final class MusicFileManager {
    
    static let `default` = MusicFileManager()
    
    private let fileManager = FileManager.default
    private let ioQueue: DispatchQueue
    
    let musicLibraryURL: URL
    
    let musicCacheURL: URL
    let musicDownloadURL: URL
    let musicDataBaseURL: URL
    
    var isDataBaseExist: Bool { return fileManager.fileExists(atPath: musicDataBaseURL.path) }
    
    private init() {
        musicLibraryURL = try! fileManager.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Music/")
        musicCacheURL = musicLibraryURL.appendingPathComponent("Cache/")
        musicDownloadURL = musicLibraryURL.appendingPathComponent("Download/")
        musicDataBaseURL = musicLibraryURL
        
        ioQueue = DispatchQueue(label: "com.xwjack.music.fileManager")
        createMusicCacheDirectory()
        createMusicDownloadDirectory()
    }
    
    /// Clear Cache
    ///
    /// - Parameter completed: Completed clear
    func clearCache(_ completed: (() -> ())? = nil) {
        KingfisherManager.shared.cache.clearDiskCache {
            self.ioQueue.async {
                self.clear(self.musicCacheURL)

                MusicDataBaseManager.default.clear()
                MusicResourceManager.default.clear()
                
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
        
        KingfisherManager.shared.cache.calculateDiskCacheSize { (kingfisherSize) in
            self.ioQueue.async {
                
                let musicCacheSize = calculateFileSize(in: self.musicCacheURL)
//                let musicDownloadSize = calculateFileSize(in: self.musicDownloadURL)
                
                DispatchQueue.main.async {
                    completed(Int64(kingfisherSize) + musicCacheSize)// + musicDownloadSize)
                }
            }
        }
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
