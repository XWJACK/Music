//
//  MainViewController.swift
//  Music
//
//  Created by Jack on 3/26/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.pushViewController(MusicPlayerViewController(), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
