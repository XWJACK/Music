//
//  UIViewSkin.swift
//  Music
//
//  Created by Jack on 3/17/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

open class UIKitSkin<T: AnyObject> {
    
    open internal(set) weak var retain: T?
    
    init(_ value: T) {
        retain = value
    }
}

open class UIViewSkin: UIKitSkin<UIView> {
    
    public var backgroundColor: UIColorPicker?
    
    public func makeSkin(_ type: (UIViewSkin) -> ()) {
        type(self)
    }
}

extension UIView: SkinNameSpace {
    public var skin: UIViewSkin { return UIViewSkin(self) }
}
