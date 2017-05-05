//
//  MusicCenterViewController.swift
//  Music
//
//  Created by Jack on 5/3/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit


class MusicCenterViewController: MusicTableViewController {
    
    
    fileprivate var dataSources: [(title: String, image: UIImage)] = [("Clear Cache", #imageLiteral(resourceName: "tabBar_center_delete")), ("About", #imageLiteral(resourceName: "tabBar_center_about"))]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Center"
        musicNavigationBar.leftButton.isHidden = true
        
        tableView.register(MusicTableViewCell.self, forCellReuseIdentifier: MusicTableViewCell.reuseIdentifier)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MusicTableViewCell.reuseIdentifier, for: indexPath) as? MusicTableViewCell else { return MusicTableViewCell() }
        
        cell.indexPath = indexPath
        cell.leftPadding = 50
        cell.textLabel?.text = dataSources[indexPath.row].title
        cell.textLabel?.textColor = .white
        cell.imageView?.image = dataSources[indexPath.row].image
        cell.imageView?.tintColor = .black
        
        return cell
    }
}
