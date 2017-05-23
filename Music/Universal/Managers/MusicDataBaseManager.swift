//
//  MusicDataBaseManager.swift
//  Music
//
//  Created by Jack on 5/18/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation
import SQLite

private struct Resource {
    let table: Table
    let id = Expression<String>("id")
    let name = Expression<String>("name")
    let duration = Expression<Double>("duration")
    let lyric = Expression<JSON>("lyric")
    let artist = Expression<JSON>("artist")
    let album = Expression<JSON>("album")
    let info = Expression<JSON>("info")
    
    let status = Expression<Int>("status")
    
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
            table.column(status)
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
        resource.lyric = row[lyric] == emptyJSON ? nil : MusicLyricModel(row[lyric])
        resource.album = row[album] == emptyJSON ? nil : MusicAlbumModel(row[album])
        resource.artist = row[artist] == emptyJSON ? nil : MusicArtistModel(row[artist])
        resource.info = row[info] == emptyJSON ? nil : MusicResouceInfoModel(row[info])
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

private struct PlayList {
    let table: Table
    let id = Expression<String>("id")
    let list = Expression<JSON>("playList")
    
    private(set) var sqlStatement: String = ""
    
    init(table: Table) {
        self.table = table
        
        sqlStatement = self.table.create(ifNotExists: true, block: { (table) in
            table.column(id, primaryKey: true)
            table.column(list)
        })
    }
    
    func save(id: String, json: JSON) -> [Setter] {
        return [self.id <- id,
                list <- json]
    }
}

class MusicDataBaseManager {
    
    static let `default`: MusicDataBaseManager = MusicDataBaseManager()
    
    private let musicDB: Connection?
    
    private let resourceControl = Resource(table: Table("Resources"))
    private let cacheControl = List(table: Table("Cache"))
    private let downloadControl = List(table: Table("Download"))
    private let leastResourcesControl = Resource(table: Table("LeastResources"))
    
    private let collectionListControl = PlayList(table: Table("CollectionList"))
    private let listDetailControl = PlayList(table: Table("ListDetail"))
    
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
            /// Created collection list table
            try musicDB?.run(collectionListControl.sqlStatement)
            /// Created list detail table
            try musicDB?.run(listDetailControl.sqlStatement)
        } catch {
            ConsoleLog.error("Create tables with error: \(error)")
        }
    }
    
    //MARK: - Collection List
    
    func set(_ userId: String, collectionList: JSON) {
        do {
            try musicDB?.run(collectionListControl.table.insert(or: .replace, collectionListControl.save(id: userId, json: collectionList)))
        } catch {
            ConsoleLog.error(error)
        }
    }
    
    func get(userId: String) -> JSON? {
        do {
            return try musicDB?.pluck(collectionListControl.table)?.get(collectionListControl.list)
        } catch {
            ConsoleLog.error(error)
            return nil
        }
    }
    
    //MARK: - List Detail
    
    func set(_ listId: String, listDetail: JSON) {
        do {
            try musicDB?.run(listDetailControl.table.insert(or: .replace, listDetailControl.save(id: listId, json: listDetail)))
        } catch {
            ConsoleLog.error(error)
        }
    }
    
    func get(listId: String) -> JSON? {
        do {
            return try musicDB?.pluck(listDetailControl.table.filter(listDetailControl.id == listId))?.get(listDetailControl.list)
        } catch {
            ConsoleLog.error(error)
            return nil
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
    
    func download(_ resource: MusicResource) {
        do {
            try musicDB?.run(downloadControl.table.insert(downloadControl.id <- resource.id))
            if !save(resource, withStatus: 1) {
                try musicDB?.run(resourceControl.table.filter(resourceControl.id == resource.id).update(resourceControl.status <- 1))
            }
            /// Delete cache with same resource
            try musicDB?.run(cacheControl.table.filter(cacheControl.id == resource.id).delete())
        } catch {
            ConsoleLog.error("Download resource information to DataBase with error: \(error)")
        }
    }
    
    //MARK: - Delete 

    
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
    
    //MARK: - Get Resource
    
    func get(resourceId: MusicResourceIdentifier) -> MusicResource? {
        do {
            guard let row = try musicDB?.pluck(resourceControl.table.filter(cacheControl.id == resourceId)) else { return nil }
            return resourceControl.get(fromRow: row)
        } catch {
            ConsoleLog.error(error)
            return nil
        }
    }
    
    //MARK: - Clear cache resource , delete downloaded
    
    func clear() {
        do {
            try musicDB?.run(cacheControl.table.delete())
            
            try musicDB?.run(resourceControl.table.filter(resourceControl.status == 0).delete())
            
        } catch {
            ConsoleLog.error(error)
        }
    }
    
    func delete(resourceId: String) {
        do {
            try musicDB?.run(downloadControl.table.filter(downloadControl.id == resourceId).delete())
            try musicDB?.run(resourceControl.table.filter(resourceControl.id == resourceId).delete())
        } catch {
            ConsoleLog.error(error)
        }
    }
    
    //MARK: - Private
    @discardableResult
    private func save(_ resource: MusicResource, withStatus status: Int = 0) -> Bool {
        do {
            var setter: [Setter] = resourceControl.save(resource: resource)
            setter.append(resourceControl.status <- status)
            try musicDB?.run(resourceControl.table.insert(setter))
            return true
        } catch {
            ConsoleLog.error("Save resource information to DataBase with error: \(error)")
            return false
        }
    }
}
