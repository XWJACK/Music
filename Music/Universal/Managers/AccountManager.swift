//
//  AccountManager.swift
//  Music
//
//  Created by Jack on 5/10/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

class AccountManager {
    
    static let `default` = AccountManager()
    
    var account: MusicAccount?
    var profile: MusicProfile?
}
