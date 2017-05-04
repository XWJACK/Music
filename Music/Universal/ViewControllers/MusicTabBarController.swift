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
        
        tabBar.tintColor = .white
        tabBar.backgroundImage = UIImage.image(withColor: .clear)
        tabBar.barStyle = .black
        
        let musicListTabBarItem = UITabBarItem(title: "My Music",
                                               image: #imageLiteral(resourceName: "tabBar_music"),
                                               selectedImage: #imageLiteral(resourceName: "tabBar_music_selected"))
        
        let personalCenterTabBarItem = UITabBarItem(title: "Center",
                                                  image: #imageLiteral(resourceName: "tabBar_center"),
                                                  selectedImage: #imageLiteral(resourceName: "tabBar_center_selected"))
        
        let musicCollectionListViewController = MusicNavigationController(rootViewController: MusicCollectionListViewController.instanseFromStoryboard()!)
        let personalCenterViewController = MusicNavigationController(rootViewController: PersonalCenterViewController.instanseFromStoryboard()!)
        
        musicCollectionListViewController.tabBarItem = musicListTabBarItem
        personalCenterViewController.tabBarItem = personalCenterTabBarItem
        
        viewControllers = [musicCollectionListViewController, personalCenterViewController]
    }

}
