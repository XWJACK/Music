//
//  MusicCenterViewController.swift
//  Music
//
//  Created by Jack on 5/3/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit


class MusicCenterViewController: MusicTableViewController {
    
    
    private var dataSources: [(title: String, image: UIImage?, clouse: (() -> ())?)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Center"
        musicNavigationBar.leftButton.isHidden = true
        
        tableView.register(MusicTableViewCell.self, forCellReuseIdentifier: MusicTableViewCell.reuseIdentifier)
        
        dataSources = [("Clear Cache", #imageLiteral(resourceName: "center_delete"), clearCache),
                       ("About", #imageLiteral(resourceName: "center_about"), about),
                       ("Regist Server", #imageLiteral(resourceName: "center_registe"), registe)]
    }
    
    private func clearCache() {
        
    }
    
    private func about() {
        
    }
    
    private func registe() {
        let controller = UIAlertController(title: "Register", message: nil, preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "Your server Address"
            textField.keyboardType = .asciiCapable
        }
        controller.addAction(UIAlertAction(title: "Registe", style: .default, handler: { (action) in
            guard let baseURLString = controller.textFields?.first?.text else { return }
            MusicAPI.default.baseURLString = baseURLString
            self.tableView.reloadData()
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(controller, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count - (MusicAPI.default.baseURLString == nil ? 0 : 1)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        dataSources[indexPath.row].clouse?()
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
