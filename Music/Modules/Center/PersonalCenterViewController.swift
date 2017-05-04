//
//  PersonalCenterViewController.swift
//  Music
//
//  Created by Jack on 5/3/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit


class PersonalCenterViewController: MusicViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var dataSources: [(title: String, image: UIImage)] = [("Clear Cache", #imageLiteral(resourceName: "tabBar_center_delete")), ("About", #imageLiteral(resourceName: "tabBar_center_about"))]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Center"
        musicNavigationBar.backButton.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MusicTableViewCell.self, forCellReuseIdentifier: MusicTableViewCell.reuseIdentifier)
        tableView.backgroundColor = .clear
    }
}

extension PersonalCenterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MusicTableViewCell.reuseIdentifier, for: indexPath) as? MusicTableViewCell else { return MusicTableViewCell() }
        
        cell.indexPath = indexPath
        cell.textLabel?.text = dataSources[indexPath.row].title
        cell.textLabel?.textColor = .white
        cell.imageView?.image = dataSources[indexPath.row].image
        cell.imageView?.tintColor = .black
        
        return cell
    }
}
