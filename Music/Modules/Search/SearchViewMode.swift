//
//  SearchViewMode.swift
//  Music
//
//  Created by Jack on 5/6/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

struct SearchViewMode {
    var name: String = ""
    var detail: String = ""
}

extension SearchMode {
    var searchViewMode: SearchViewMode {
        var data = SearchViewMode()
        data.name = name
        data.detail = artistsName + "-" + albumName
        return data
    }
}
