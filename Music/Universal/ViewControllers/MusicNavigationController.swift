//
//  MusicNavigationController.swift
//  Music
//
//  Created by Jack on 4/30/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        navigationBar.isHidden = true
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func push(_ viewController: MusicViewController,
              animated: Bool = true,
              hiddenTabBar: Bool = true,
              hiddenTopBar: Bool = false,
              hiddenTopBarLeftButton: Bool = false) {
        
        viewController.hidesBottomBarWhenPushed = hiddenTabBar
        
        if hiddenTopBar {
            viewController.isHiddenNavigationBar = true
        } else {
            viewController.musicNavigationBar.leftButton.isHidden = hiddenTopBarLeftButton
        }
        
        pushViewController(viewController, animated: animated)
    }
}
