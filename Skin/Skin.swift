//
//  Skin.swift
//  Music
//
//  Created by Jack on 3/17/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let ChangeSkin: Notification.Name = Notification.Name.init("ChangeSkin")
}

public protocol SkinParse {
    func parse() -> SkinPicker
}

public class SkinManager<T: SkinPicker> {
    
    typealias SkinBlock = (T) -> ()
    
//    public static let `default`: SkinManager = SkinManager()
    
    public internal(set) var skins: [String: String] = [:]
    public internal(set) var currentSkin: String = ""
    
    var skinBlocks: [String: SkinBlock] = [:]
    
    public func registerSkin() {
        
    }
    
    public func changeSkin(by index: Int) {
        NotificationCenter.default.post(name: .ChangeSkin, object: nil, userInfo: nil)
    }
    
    func addSkin(_ identifity: String, with objc: @escaping SkinBlock) {
        skinBlocks[identifity] = objc
    }
}
