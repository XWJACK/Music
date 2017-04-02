//
//  MusicNavigationViewController.swift
//  Music
//
//  Created by Jack on 3/26/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if !self.viewControllers.isEmpty {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}
