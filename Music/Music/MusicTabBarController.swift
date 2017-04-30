//
//  MusicTabBarController.swift
//  Music
//
//  Created by Jack on 4/20/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

final class MusicTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let musicListItem = UITabBarItem(title: "Music List", image: nil, selectedImage: nil)
        
        let musicListTableViewController = MusicNavigationController(rootViewController: MusicListViewController.instanseFromStoryboard()!)
        
        musicListTableViewController.tabBarItem = musicListItem
        
        viewControllers = [musicListTableViewController]
    }
}
