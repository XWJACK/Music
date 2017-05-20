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
    
    private let resourceControl = Resource(table: Table("Resources"))
    private let cacheControl = List(table: Table("Cache"))
    private let downloadControl = List(table: Table("Download"))
    private let leastResourcesControl = Resource(table: Table("LeastResources"))
    
    private init() {
        musicDB = try? Connection(MusicFileManager.default.musicDataBaseURL.appendingPathComponent("music.db").path)
        
        musicDB?.trace{ ConsoleLog.verbose($0) }
        
        do {
            /// Created resouce table
            try musicDB?.run(resourceControl.sqlStatement)
            /// Created cache table
            try musicDB?.run(cacheControl.sqlStatement)
            /// Created download table
            try musicDB?.run(downloadControl.sqlStatement)
            /// Created least reshources table
            try musicDB?.run(leastResourcesControl.sqlStatement)
        } catch {
            ConsoleLog.error("Create Music DB Table Error: \(error)")
        }
    }
    
    //MARK: - Check
    
    func isCached(_ identifiter: MusicResourceIdentifier) -> Bool {
        do {
            return try musicDB?.pluck(cacheControl.table.select(cacheControl.id).filter(cacheControl.id == identifiter)) != nil
        } catch {
            ConsoleLog.error(error)
            return false
        }
    }
    
    func isDownload(_ identifiter: MusicResourceIdentifier) -> Bool {
        do {
            return try musicDB?.pluck(downloadControl.table.select(downloadControl.id).filter(downloadControl.id == identifiter)) != nil
        } catch {
            ConsoleLog.error(error)
            return false
        }
    }
    
    //MARK: - List
    
    func cacheList() -> [MusicResourceIdentifier] {
        do {
            return Array(try musicDB!.prepare(cacheControl.table).map{ $0.get(cacheControl.id) })
        } catch {
            ConsoleLog.error(error)
            return []
        }
    }
    
    func downloadList() -> [MusicResourceIdentifier] {
        do {
            return Array(try musicDB!.prepare(downloadControl.table).map{ $0.get(downloadControl.id) })
        } catch {
            ConsoleLog.error(error)
            return []
        }
    }
    
    //MARK: - List Count
    
    func cacheCount() -> Int {
        do {
            return try musicDB?.scalar(cacheControl.table.select(cacheControl.id.count)) ?? 0
        } catch {
            ConsoleLog.error(error)
            return 0
        }
    }
    
    func downloadCount() -> Int {
        do {
            return try musicDB?.scalar(downloadControl.table.select(downloadControl.id.count)) ?? 0
        } catch {
            ConsoleLog.error(error)
            return 0
        }
    }
    
    //MARK: - Save Resource
    
    func cache(_ resource: MusicResource) {
        do {
            try musicDB?.run(cacheControl.table.insert(cacheControl.id <- resource.id))
            save(resource)
        } catch {
            ConsoleLog.error("Cache resource information to DataBase with error: \(error)")
        }
    }
    
    //MARK: - Least Resources
    
    func update(leastResources: [MusicResource]) {
        do {
            try musicDB?.run(leastResourcesControl.table.delete())
            for resource in leastResources {
                try musicDB?.run(leastResourcesControl.table.insert(leastResourcesControl.save(resource: resource)))
            }
        } catch {
            ConsoleLog.error("Update least resources with error: \(error)")
        }
    }
    
    func getLeastResources() -> [MusicResource] {
        do {
            return Array(try musicDB!.prepare(leastResourcesControl.table).map{ leastResourcesControl.get(fromRow: $0) })
        } catch {
            ConsoleLog.error(error)
            return []
        }
    }
    
    func update(leastResource resource: MusicResource) {
        do {
            try musicDB?.run(leastResourcesControl.table.filter(leastResourcesControl.id == resource.id).update(leastResourcesControl.save(resource: resource)))
        } catch {
            ConsoleLog.error("Update least resources with error: \(error)")
        }
    }
    
    //MARK: - Get Resource
    
    func get(_ resouceId: MusicResourceIdentifier) -> MusicResource? {
        do {
            guard let row = try musicDB?.pluck(resourceControl.table.filter(cacheControl.id == resouceId)) else { return nil }
            return resourceControl.get(fromRow: row)
        } catch {
            ConsoleLog.error(error)
            return nil
        }
    }
    
    private func save(_ resource: MusicResource) {
        do {
            try musicDB?.run(resourceControl.table.insert(resourceControl.save(resource: resource)))
        } catch {
            ConsoleLog.error("Erro Cache resource information to DataBase")
        }
    }
}
