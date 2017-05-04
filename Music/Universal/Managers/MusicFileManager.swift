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
    
    func clearCache() {
        
    }
}
