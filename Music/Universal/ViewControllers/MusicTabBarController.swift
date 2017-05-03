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
        
        let musicListTableViewController = MusicNavigationController(rootViewController: MusicListViewController.instanseFromStoryboard()!)
        musicListTableViewController.tabBarItem = musicListTabBarItem
        
        viewControllers = [musicListTableViewController]
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        super.tabBar(tabBar, didSelect: item)
        
    }
}
