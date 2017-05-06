//
//  Error.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

enum MusicError: Error {
    
    enum ResourcesError {
        case invalidURL
        case invalidData
    }
    
    enum PlayerError {
        case playError(ResourcesError)
    }
    
    enum FileError {
        case fileExist
        case fileNotExist
        case floderExist
        case floderNotExist
        case floderIsNotEmpty
    }
    
    enum CacheError {
        case created(FileError)
        case deleted(FileError)
    }
    
    enum NetworkError {
        /// Response with empty data
        case emptyData
        /// parse data fail
        case parseFail
    }
    
    case resourcesError(ResourcesError)
    case playerError(PlayerError)
    case networkError(NetworkError)
}
