//
//  MusicCollectionListViewController.swift
//  Music
//
//  Created by Jack on 5/3/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

final class MusicCollectionListViewController: MusicTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Music"
        
        let searchButton = UIButton(type: .custom)
        searchButton.setImage(#imageLiteral(resourceName: "topBar_search"), for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonClicked(_:)), for: .touchUpInside)
        musicNavigationBar.leftButton = searchButton
        
        let actionButton = MusicButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        actionButton.addTarget(self, action: #selector(actionButtonClicked(_:)), for: .touchUpInside)
        musicNavigationBar.rightButton = actionButton
        
        tableView.register(MusicCollectionListTableViewCell.self, forCellReuseIdentifier: MusicCollectionListTableViewCell.reuseIdentifier)
        
        actionButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(28)
        }
    }
    
    @objc private func actionButtonClicked(_ sender: MusicButton) {
        musicNavigationController?.push(musicPlayerViewController)
    }
    
    @objc private func searchButtonClicked(_ sender: UIButton) {
//        musicNavigationController?.push(MusicSearchViewController())
        present(MusicSearchViewController(), animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        musicNavigationController?.push(MusicListViewController(), hiddenTabBar: false)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MusicCollectionListTableViewCell.reuseIdentifier, for: indexPath) as? MusicCollectionListTableViewCell else { return MusicCollectionListTableViewCell() }
        cell.indexPath = indexPath
        return cell
    }
}
