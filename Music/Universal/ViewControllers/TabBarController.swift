//
//  ViewController.swift
//  Music
//
//  Created by Jack on 3/1/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let musicPlayerController = MusicNavigationViewController(rootViewController: MainViewController())

        let item = UITabBarItem(title: "", image: nil, selectedImage: nil)
        musicPlayerController.tabBarItem = item
        
        viewControllers = [musicPlayerController]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

