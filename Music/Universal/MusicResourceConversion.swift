//
//  MusicResourceConversion.swift
//  Music
//
//  Created by Jack on 5/8/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

// MARK: - SearchModel -> MusicResource
extension SearchModel {
    var resource: MusicResource {
        var resource = MusicResource()
        resource.id = id
        resource.musicUrl = mp3URL
        return resource
    }
}
