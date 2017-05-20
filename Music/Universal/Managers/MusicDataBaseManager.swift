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
        let table: Table
        let id = Expression<String>("id")
        let name = Expression<String>("name")
        let duration = Expression<Double>("duration")
        let lyric = Expression<JSON>("lyric")
        let artist = Expression<JSON>("artist")
        let album = Expression<JSON>("album")
        let info = Expression<JSON>("info")
        
        private(set) var sqlStatement: String = ""
        
        init(table: Table) {
            self.table = table
            
            sqlStatement = self.table.create(ifNotExists: true) { (table) in
                table.column(id, primaryKey: true)
                table.column(name)
                table.column(duration)
                table.column(lyric)
                table.column(artist)
                table.column(album)
                table.column(info)
            }
        }
        
        func save(resource: MusicResource) -> [Setter] {
            return [id <- resource.id,
                    name <- resource.name,
                    duration <- resource.duration,
                    lyric <- resource.lyric?.rawJSON ?? emptyJSON,
                    album <- resource.album?.rawJSON ?? emptyJSON,
                    artist <- resource.artist?.rawJSON ?? emptyJSON,
                    info <- resource.info?.rawJSON ?? emptyJSON]
        }
        
        func get(fromRow row: Row) -> MusicResource {
            let resource = MusicResource(id: row[id])
            resource.name = row[name]
            resource.duration = row[duration]
            resource.lyric = MusicLyricModel(row[lyric])
            resource.album = MusicAlbumModel(row[album])
            resource.artist = MusicArtistModel(row[artist])
            resource.info = MusicResouceInfoModel(row[info])
            return resource
        }
    }
    
    private struct List {
        let table: Table
        let id = Expression<String>("id")
        
        private(set) var sqlStatement: String = ""
        
        init(table: Table) {
            self.table = table
            
            sqlStatement = self.table.create(ifNotExists: true, block: { (table) in
                table.column(id, primaryKey: true)
            })
        }
    }
    
    private let musicDB: Connection?
    
    private let resource = Resource(table: Table("Resources"))
    private let cache = List(table: Table("Cache"))
    private let download = List(table: Table("Download"))
    private let leastResources = Resource(table: Table("LeastResources"))
    
    private init() {
        musicDB = try? Connection(MusicFileManager.default.musicDataBaseURL.appendingPathComponent("music.db").path)
        
        musicDB?.trace{ ConsoleLog.verbose($0) }
        
        do {
            /// Created resouce table
            try musicDB?.run(resource.sqlStatement)
            /// Created cache table
            try musicDB?.run(cache.sqlStatement)
            /// Created download table
            try musicDB?.run(download.sqlStatement)
            /// Created least reshources table
            try musicDB?.run(leastResources.sqlStatement)
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
    
    //MARK: - List Count
    
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
            ConsoleLog.error("Cache resource information to DataBase with error: \(error)")
        }
    }
    
    //MARK: - Least Resources
    
    func update(leastResources: [MusicResource]) {
        do {
            try musicDB?.run(self.leastResources.table.delete())
            for resource in leastResources {
                try musicDB?.run(self.leastResources.table.insert(self.leastResources.save(resource: resource)))
            }
        } catch {
            ConsoleLog.error("Update least resources with error: \(error)")
        }
    }
    
    func getLeastResources() -> [MusicResource] {
        do {
            return Array(try musicDB!.prepare(self.leastResources.table).map{ self.leastResources.get(fromRow: $0) })
        } catch {
            ConsoleLog.error(error)
            return []
        }
    }
    
    //MARK: - Get Resource
    
    func get(_ resouceId: MusicResourceIdentifier) -> MusicResource? {
        do {
            guard let row = try musicDB?.pluck(self.resource.table.filter(cache.id == resouceId)) else { return nil }
            return self.resource.get(fromRow: row)
        } catch {
            ConsoleLog.error(error)
            return nil
        }
    }
    
    private func save(_ resource: MusicResource) {
        do {
            try musicDB?.run(self.resource.table.insert(self.resource.save(resource: resource)))
        } catch {
            ConsoleLog.error("Erro Cache resource information to DataBase")
        }
    }
}
