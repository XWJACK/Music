//
//  MusicFileManager.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

struct FileManagerFolderOptions: OptionSet {
    
    var rawValue: UInt
    
    static let all = FileManagerFolderOptions(rawValue: 1 << 0)
    static let musicCache = FileManagerFolderOptions(rawValue: 1 << 0)
    static let musicDownload = FileManagerFolderOptions(rawValue: 1 << 0)
    
    init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

final class MusicFileManager {
    
    static let `default` = MusicFileManager()
    
    private(set) var allCachesFolder: [URL] = []
    private let fileManager: FileManager = FileManager.default
    private let cachesURL: URL
    
    private init() {
        cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func initFloder() {
        do {
//            try fileManager.createDirectory(at: <#T##URL#>, withIntermediateDirectories: true)
        } catch {
            
        }
    }
    
    func delete(withOption option: FileManagerFolderOptions) {
        
    }
}
