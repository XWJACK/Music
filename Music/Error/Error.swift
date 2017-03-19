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
        case invaliedURL
    }
    
    enum PlayerError {
        case seekError
    }
    
    case resourcesError(ResourcesError)
    case playerError(PlayerError)
}



enum FileError {
    case fileExist
    case fileNotExist
    case floderExist
    case floderNotExist
    case floderIsNotEmpty
}

