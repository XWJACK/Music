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

@objc protocol Skin {
    func addSkin()
    func removeSkin()
    @objc func updateSkin()
}

extension Skin where Self: UIView {
    func addSkin() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateSkin), name: .ChangeSkin, object: nil)
    }
    func removeSkin() {
        NotificationCenter.default.removeObserver(self, name: .ChangeSkin, object: nil)
    }
}

class SkinManager {
    
    var skins: [String: String] = [:]
    
    var currentSkin: String = ""
    
    func searchSkin() {
        
    }
    
    func changeSkin(by index: Int) {
        NotificationCenter.default.post(name: .ChangeSkin, object: nil, userInfo: nil)
    }
}
