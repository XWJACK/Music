//
//  Skin.swift
//  Music
//
//  Created by Jack on 3/15/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let ChangeSkin: Notification.Name = Notification.Name.init("ChangeSkin")
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

struct Skin {
    static var tab1Image: UIImage? { return UIImage(contentsOfFile: "") }
}
