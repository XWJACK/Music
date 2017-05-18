//
//  ThirdFramework.swift
//  Music
//
//  Created by Jack on 5/10/17.
//  Copyright © 2017 Jack. All rights reserved.
//

//MARK: - Alamofire
import Alamofire
typealias Parameters = Alamofire.Parameters
typealias HTTPMethod = Alamofire.HTTPMethod
typealias URLEncoding = Alamofire.URLEncoding

//MARK: - Kingfisher
import Kingfisher
typealias ThirdFileManager = KingfisherManager

//MARK: - SwiftyJSON
import SwiftyJSON
typealias JSON = SwiftyJSON.JSON

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



//MARK: - Log
import Log
typealias ConsoleLog = Log.ConsoleLog

//MARK: - Wave
import Wave
typealias AudioPlayer = Wave.StreamAudioPlayer
typealias AudioPlayerDelegate = Wave.StreamAudioPlayerDelegate
typealias AudioQueueStatus = Wave.StreamAudioQueueStatus

//MARK: - PageKit
import PageKit

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

extension Client {
    
    @discardableResult
    func receive(queue: DispatchQueue = .main, json block: ((JSON) -> ())? = nil) -> Self {
        return receive(queue: queue, success: { block?(JSON(data: $0)) })
    }
}
