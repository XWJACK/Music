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
        var resource = MusicResource(id: id)
        resource.musicUrl = mp3Url
        resource.resourceSource = .network
        return resource
    }
}
