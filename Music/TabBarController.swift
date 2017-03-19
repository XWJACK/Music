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
        let musicPlayerController = UINavigationController(rootViewController: MusicPlayerViewController<LocalAudioPlayer>())

        let item = UITabBarItem(title: "播放器", image: nil, selectedImage: nil)
        musicPlayerController.tabBarItem = item
        
        viewControllers = [musicPlayerController]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

