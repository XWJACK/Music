//
//  CacheManager.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

final class CacheManager {
    
    typealias Success = () -> ()
    typealias Fail = (CacheError) -> ()
    
    static let `default`: CacheManager = CacheManager()
    
    private(set) var allCachesFolder: [URL] = []
    private let cachesURL: URL?
    
    private init() {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cachesURL = urls.first
    }
    
    func create(folder name: String, success: Success?, fail: Fail?) {
        
    }
    
    func delete(folder name: String, success: Success?, fail: Fail?) {
        
    }
    
    func deleteCache() {
        
    }
}

private extension URL {
}
