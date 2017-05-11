//
//  MusicCenterViewController.swift
//  Music
//
//  Created by Jack on 5/3/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit


class MusicCenterViewController: MusicTableViewController {
    
    private var dataSources: [(title: String, image: UIImage?, clouse: ((IndexPath) -> ())?)] = []
    private var isCalculating: Bool = false
    private var cache: String = ""
    private let cacheIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Center"
        musicNavigationBar.leftButton.isHidden = true
        
        tableView.register(MusicTableViewCell.self, forCellReuseIdentifier: MusicTableViewCell.reuseIdentifier)
        tableView.register(MusicCenterClearCacheTableViewCell.self, forCellReuseIdentifier: MusicCenterClearCacheTableViewCell.reuseIdentifier)
        
        dataSources = [("Clear Cache", #imageLiteral(resourceName: "center_delete"), clearCache),
                       ("About", #imageLiteral(resourceName: "center_about"), about),
                       ("Regist Server", #imageLiteral(resourceName: "center_registe"), registe)]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !isCalculating else { return }
        isCalculating = true
        tableView.reloadRows(at: [cacheIndexPath], with: .none)
        
        MusicFileManager.default.calculateCache {
            self.isCalculating = false
            self.cache = ByteCountFormatter.string(fromByteCount: $0, countStyle: .binary)
            self.tableView.reloadRows(at: [self.cacheIndexPath], with: .none)
        }
    }
    
    private func clearCache(_ indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) as? MusicCenterClearCacheTableViewCell else { return }
        cell.indicator.isHidden = false
        MusicFileManager.default.clearCache { 
            cell.indicator.isHidden = true
            cell.cacheLabel.text = "Zero KB"
        }
    }
    
    private func about(_ indexPath: IndexPath) {
        
    }
    
    private func registe(_ indexPath: IndexPath) {
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
        dataSources[indexPath.row].clouse?(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let block: (MusicTableViewCell) -> () = {
            $0.indexPath = indexPath
            $0.leftPadding = 50
            $0.textLabel?.text = self.dataSources[indexPath.row].title
            $0.textLabel?.textColor = .white
            $0.imageView?.image = self.dataSources[indexPath.row].image
            $0.imageView?.tintColor = .black
        }
        
        if indexPath == cacheIndexPath {
            let cell = tableView.dequeueReusableCell(withIdentifier: MusicCenterClearCacheTableViewCell.reuseIdentifier, for: indexPath) as! MusicCenterClearCacheTableViewCell
            block(cell)
            cell.indicator.isHidden = !isCalculating
            if isCalculating { cell.indicator.startAnimating() }
            else { cell.indicator.stopAnimating() }
            cell.cacheLabel.text = cache
            cell.cacheLabel.isHidden = isCalculating
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MusicTableViewCell.reuseIdentifier, for: indexPath) as! MusicTableViewCell
            block(cell)
            return cell
        }
    }
}
