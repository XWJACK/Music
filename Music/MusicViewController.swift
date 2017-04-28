//
//  MusicViewController.swift
//  Music
//
//  Created by Jack on 4/20/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit
import PageKit

final class MusicViewController: UIViewController {
    
    private var container: Container!
    private var backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "music_background"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container = Container(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        container.dataSource = self
        container.register(SearchViewController.self)
        container.register(MusicPlayerViewController.self)
        container.isReuseEnable = false
        container.parentViewController = self
        view.addSubview(container)
        container.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { (make) in
            make.width.height.equalToSuperview()
        }
        container.reloadPage()
    }
}

extension MusicViewController: ContainerDataSource {
    
    func numberOfPages() -> Int {
        return 2
    }
    
    func container(_ container: Container, pageForIndexAt index: Int) -> Page {
        
        switch index {
        case 0:
            guard let page = container.dequeueReusablePage(withIdentifier: SearchViewController.reuseIdentifier) as? SearchViewController else { return SearchViewController() }
            return page
        case 1:
            guard let page = container.dequeueReusablePage(withIdentifier: MusicPlayerViewController.reuseIdentifier) as? MusicPlayerViewController else { return MusicPlayerViewController() }
            return page
        default: return UIView()
        }
    }
}
