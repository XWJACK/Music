//
//  ThirdFramework.swift
//  Music
//
//  Created by Jack on 5/10/17.
//  Copyright © 2017 Jack. All rights reserved.
//

//MARK: - Alamofire
import Alamofire

//MARK: - Kingfisher
import Kingfisher

//MARK: - SwiftyJSON
import SwiftyJSON
public typealias JSON = SwiftyJSON.JSON

//MARK: - MJRefresh
import MJRefresh
typealias RefreshNormalHeader = MJRefresh.MJRefreshNormalHeader
typealias RefreshBackNormalFooter = MJRefresh.MJRefreshBackNormalFooter

extension UIScrollView {
    
    func endRefreshing(hasMore: Bool) {
        guard self.mj_footer != nil else { return }
        
        if hasMore  {
            self.mj_footer.endRefreshing()
            self.mj_footer.isHidden = false
        } else {
            self.mj_footer.endRefreshingWithNoMoreData()
            self.mj_footer.isHidden = true
        }
    }
}

//MARK: - SnapKit
import SnapKit

//MARK: - Toast_Swift
import Toast_Swift

//MARK: - SQLite
import SQLite

/// Extension json for supporting saveing into SQLite
extension JSON: Value {
    
    public static var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    
    public static func fromDatatypeValue(_ datatypeValue: Blob) -> JSON {
        return JSON(data: Data.fromDatatypeValue(datatypeValue))
    }
    
    public var datatypeValue: Blob {
        do {
            return try self.rawData().datatypeValue
        } catch {
            ConsoleLog.error("JSON to Blob Error: \(error)")
            return emptyData.datatypeValue
        }
    }
}
/// Extension json for decoding from row
extension Row {
    subscript(column: Expression<JSON>) -> JSON {
        return get(column)
    }
    subscript(column: Expression<JSON?>) -> JSON? {
        return get(column)
    }
}


//MARK: - Log
import Log
typealias ConsoleLog = Log.ConsoleLog

//MARK: - Wave
import Wave

//MARK: - PageKit
import PageKit
typealias Container = PageKit.Container
typealias ReuseContainer = PageKit.ReuseContainer
typealias CycleContainer = PageKit.CycleContainer

//MARK: - Music API

import MusicAPI
let API = MusicAPI.default

//MARK: - Lotus
import Lotus
let MusicNetwork = Lotus.Session.default
typealias Client = Lotus.Client

extension JSON {
    /// Parse Code
    var code: Int { return self["code"].intValue }
    /// Parse Data
    var result: JSON { return self["result"] }
    /// Is Success for response
    var isSuccess: Bool { return code == 200 }
}

/// Extension with json decoding
extension Client {
    
    @discardableResult
    func receive(queue: DispatchQueue = .main, json block: ((JSON) -> ())? = nil) -> Self {
        return receive(queue: queue, success: { block?(JSON(data: $0)) })
    }
}
