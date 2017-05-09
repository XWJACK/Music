//
//  MusicResourceConversion.swift
//  Music
//
//  Created by Jack on 5/8/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

extension SearchMode {
    var resource: MusicResource {
        var resource = MusicResource()
        resource.resourceID = id
        resource.resourceURL = mp3URL
        return resource
    }
}
