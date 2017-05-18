//
//  MusicDataBaseManager.swift
//  Music
//
//  Created by Jack on 5/18/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation
import SQLite

class MusicDataBaseManager {
    
    static let `default`: MusicDataBaseManager = MusicDataBaseManager()
    
    private struct Resource {
        let table = Table("resources")
        let id = Expression<String>("id")
        let name = Expression<String>("name")
        let duration = Expression<Double>("duration")
        let lyric = Expression<Blob?>("lyric")
        let artist = Expression<Blob>("artist")
        let album = Expression<Blob>("album")
        let info = Expression<Blob?>("info")
    }
    
    private struct Cache {
        let table = Table("cache")
        let id = Expression<String>("id")
    }
    
    private struct Download {
        let table = Table("download")
        let id = Expression<String>("id")
    }
    
    private let musicDB: Connection?
//    private let userTable = Table("user")
    
    private let resource = Resource()
    private let cache = Cache()
    private let download = Download()
    
    private init() {
        musicDB = try? Connection(MusicFileManager.default.musicDataBaseURL.appendingPathComponent("music.db").path)
        
        do {
            /// Created resouce table
            try musicDB?.run(resource.table.create(ifNotExists: true, block: { (table) in
                table.column(resource.id, primaryKey: true)
                table.column(resource.name)
                table.column(resource.duration)
                table.column(resource.lyric)
                table.column(resource.artist)
                table.column(resource.album)
                table.column(resource.info)
            }))
            /// Created cache table
            try musicDB?.run(cache.table.create(ifNotExists: true, block: { (table) in
                table.column(cache.id, primaryKey: true)
            }))
            /// Created download table
            try musicDB?.run(download.table.create(ifNotExists: true, block: { (table) in
                table.column(download.id, primaryKey: true)
            }))
        } catch {
            ConsoleLog.error("Create Music DB Table Error: \(error)")
        }
    }
    
    func cache(_ resource: MusicResource) {
        do {
            try musicDB?.run(self.cache.table.insert(self.cache.id <- resource.id))
            try musicDB?.run(self.resource.table.insert())
        } catch {
            ConsoleLog.error("Erro Cache resource information to DataBase")
        }
    }
}
