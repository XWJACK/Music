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
        
        let musicSettingTabBarItem = UITabBarItem(title: "Setting",
                                                  image: #imageLiteral(resourceName: "tabBar_setting"),
                                                  selectedImage: #imageLiteral(resourceName: "tabBar_setting_selected"))
        
        let musicCollectionListViewController = MusicNavigationController(rootViewController: MusicCollectionListViewController.instanseFromStoryboard()!)
        let musicSettingViewController = MusicNavigationController(rootViewController: MusicSettingViewController.instanseFromStoryboard()!)
        
        musicCollectionListViewController.tabBarItem = musicListTabBarItem
        musicSettingViewController.tabBarItem = musicSettingTabBarItem
        
        viewControllers = [musicCollectionListViewController, musicSettingViewController]
    }

}
