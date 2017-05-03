//
//  MusicViewController.swift
//  Music
//
//  Created by Jack on 4/30/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit
import SnapKit

class MusicViewController: UIViewController {
    
    /// Lazy for music navigation bar
    lazy var musicNavigationBar = MusicNavigationBar(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: 44))
    
    /// Rreplacing `navigationController` to custom.
    var musicNavigationController: MusicNavigationController? { return navigationController as? MusicNavigationController }
    
    var isShowStatusBar = true {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden: Bool { return !isShowStatusBar }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .slide }
    
    override var title: String? {
        get { return musicNavigationBar.titleLabel.text }
        set { musicNavigationBar.titleLabel.text = newValue }
    }
    
    /// Is hidden navigation bar, only useful before push viewController
    var isHiddenNavigationBar: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        if !isHiddenNavigationBar {
            view.addSubview(musicNavigationBar)
            musicNavigationBar.delegate = self
        }
    }
}

extension MusicViewController: MusicNavigationBarDelegate {
    func backButtonClicked(_ sender: UIButton) {
        musicNavigationController?.popViewController(animated: true)
    }
}
