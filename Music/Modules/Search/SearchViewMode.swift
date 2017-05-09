//
//  SearchViewMode.swift
//  Music
//
//  Created by Jack on 5/6/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

struct SearchViewModel {
    var name: String = ""
    var detail: String = ""
}

extension SearchModel {
    var searchViewMode: SearchViewModel {
        var data = SearchViewModel()
        data.name = name
        data.detail = (artists.first?.name ?? "") + "-" + album.name
        return data
    }
}
