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
        case invalidInfo
        case noResource
    }
    
    enum PlayerError {
        case playError(ResourcesError)
    }
    
    enum FileError {
        case readingError
    }
    
    enum NetworkError {
        case emptyData
        case parseFail
        case code(Int)
    }
    
    case resourcesError(ResourcesError)
    case fileError(FileError)
    case playerError(PlayerError)
    case networkError(NetworkError)
}
