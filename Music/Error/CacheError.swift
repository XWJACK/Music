//
//  CacheError.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

enum CacheError {
    case created(FileError)
    case deleted(FileError)
}
