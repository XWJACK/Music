//
//  SkinNameSpace.swift
//  Music
//
//  Created by Jack on 3/17/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

public protocol SkinNameSpace {
    associatedtype T
    var skin: T { get }
}

//struct BaseSkin<T> {
//    var type: T
//    init(_ type: T) {
//        self.type = type
//    }
//}
