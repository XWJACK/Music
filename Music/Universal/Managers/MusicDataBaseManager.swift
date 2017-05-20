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
        let lyric = Expression<JSON>("lyric")
        let artist = Expression<JSON>("artist")
        let album = Expression<JSON>("album")
        let info = Expression<JSON>("info")
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
        
        musicDB?.trace{ ConsoleLog.verbose($0) }
        
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
    
    //MARK: - Check
    
    func isCached(_ identifiter: MusicResourceIdentifier) -> Bool {
        do {
            return try musicDB?.pluck(cache.table.select(cache.id).filter(cache.id == identifiter)) != nil
        } catch {
            ConsoleLog.error(error)
            return false
        }
    }
    
    func isDownload(_ identifiter: MusicResourceIdentifier) -> Bool {
        do {
            return try musicDB?.pluck(download.table.select(download.id).filter(download.id == identifiter)) != nil
        } catch {
            ConsoleLog.error(error)
            return false
        }
    }
    
    //MARK: - List
    
    func cacheList() -> [MusicResourceIdentifier] {
        do {
            return Array(try musicDB!.prepare(cache.table).map{ $0.get(cache.id) })
        } catch {
            ConsoleLog.error(error)
            return []
        }
    }
    
    func downloadList() -> [MusicResourceIdentifier] {
        do {
            return Array(try musicDB!.prepare(download.table).map{ $0.get(download.id) })
        } catch {
            ConsoleLog.error(error)
            return []
        }
    }
    
    //MARK: - Count
    
    func cacheCount() -> Int {
        do {
            return try musicDB?.scalar(cache.table.select(cache.id.count)) ?? 0
        } catch {
            ConsoleLog.error(error)
            return 0
        }
    }
    
    func downloadCount() -> Int {
        do {
            return try musicDB?.scalar(download.table.select(download.id.count)) ?? 0
        } catch {
            ConsoleLog.error(error)
            return 0
        }
    }
    
    //MARK: - Save Resource
    
    func cache(_ resource: MusicResource) {
        do {
            try musicDB?.run(self.cache.table.insert(self.cache.id <- resource.id))
            save(resource)
        } catch {
            ConsoleLog.error("Erro Cache resource information to DataBase")
        }
    }
    
    //MARK: - Get Reshource
    
    func get(_ resouceId: MusicResourceIdentifier) -> MusicResource? {
        do {
            guard let result = try musicDB?.pluck(self.resource.table.filter(cache.id == resouceId)) else { return nil }
            let resource = MusicResource(id: result[self.resource.id])
            resource.name = result[self.resource.name]
            resource.duration = result[self.resource.duration]
            resource.lyric = MusicLyricModel(result[self.resource.lyric])
            resource.album = MusicAlbumModel(result[self.resource.album])
            resource.artist = MusicArtistModel(result[self.resource.artist])
            resource.info = MusicResouceInfoModel(result[self.resource.info])
            return resource
        } catch {
            ConsoleLog.error(error)
            return nil
        }
    }
    
    private func save(_ resource: MusicResource) {
        do {
            try musicDB?.run(self.resource.table.insert(self.resource.id <- resource.id,
                                                        self.resource.name <- resource.name,
                                                        self.resource.duration <- resource.duration,
                                                        self.resource.lyric <- resource.lyric?.rawJSON ?? emptyJSON,
                                                        self.resource.album <- resource.album?.rawJSON ?? emptyJSON,
                                                        self.resource.artist <- resource.artist?.rawJSON ?? emptyJSON,
                                                        self.resource.info <- resource.info?.rawJSON ?? emptyJSON))
        } catch {
            ConsoleLog.error("Erro Cache resource information to DataBase")
        }
    }
}
