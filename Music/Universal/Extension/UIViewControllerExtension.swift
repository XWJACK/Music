//
//  UIViewControllerExtension.swift
//  Music
//
//  Created by Jack on 29/04/2017.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit
import PageKit

extension UIViewController {
    static func instanseFromStoryboard<T: UIViewController>() -> T? {
        return UIStoryboard(name: self.reuseIdentifier, bundle: nil).instantiateViewController(withIdentifier: self.reuseIdentifier) as? T
    }
}
