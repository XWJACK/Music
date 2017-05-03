//
//  MusicTabBarController.swift
//  Music
//
//  Created by Jack on 4/20/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

final class MusicTabBarController: UITabBarController {
    
//    private let musicTabBar = MusicTabBar(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 113, width: UIScreen.main.bounds.width, height: 49))
//    private var viewControllers: [UIViewController?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .white
        tabBar.backgroundImage = UIImage.image(withColor: .clear)
        tabBar.barStyle = .black
        
        let musicListTabBarItem = UITabBarItem(title: "Music List",
                                               image: #imageLiteral(resourceName: "tabBar_music"),
                                               selectedImage: #imageLiteral(resourceName: "tabBar_music_selected"))
        
        let musicSettingTabBarItem = UITabBarItem(title: "Setting",
                                                  image: #imageLiteral(resourceName: "tabBar_setting"),
                                                  selectedImage: #imageLiteral(resourceName: "tabBar_setting_selected"))
        
        let musicListViewController = MusicNavigationController(rootViewController: MusicListViewController.instanseFromStoryboard()!)
        let musicSettingViewController = MusicNavigationController(rootViewController: MusicSettingViewController.instanseFromStoryboard()!)
        
        musicListViewController.tabBarItem = musicListTabBarItem
        musicSettingViewController.tabBarItem = musicSettingTabBarItem
        
        viewControllers = [musicListViewController, musicSettingViewController]
    }

}
