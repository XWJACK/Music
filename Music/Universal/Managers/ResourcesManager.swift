//
//  ResourcesManager.swift
//  Music
//
//  Created by Jack on 3/19/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

protocol AudioPlayerResourcesConvertible {
    func asResources() throws -> URL
}

extension URL: AudioPlayerResourcesConvertible {
    func asResources() throws -> URL { return self }
}

extension String: AudioPlayerResourcesConvertible {
    func asResources() throws -> URL {
        guard let url = URL(string: self) else { throw MusicError.resourcesError(.invaliedURL) }
        return url
    }
}

class ResourcesManager {
    static let `default` = ResourcesManager()
    private var resources: [AudioPlayerResourcesConvertible] = []
    
    func add(searchPath path: String) {
        
    }
}
