//
//  MusicCollectionListViewController.swift
//  Music
//
//  Created by Jack on 5/3/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicCollectionListViewController: MusicViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Music"
        musicNavigationBar.backButton.isHidden = true
        
        let actionButton = MusicButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        actionButton.addTarget(self, action: #selector(actionButtonClicked(_:)), for: .touchUpInside)
        musicNavigationBar.actionButton = actionButton
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MusicCollectionListTableViewCell.self, forCellReuseIdentifier: MusicCollectionListTableViewCell.reuseIdentifier)
        tableView.backgroundColor = .clear
        
        actionButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(28)
        }
    }
    
    @objc private func actionButtonClicked(_ sender: MusicButton) {
        musicNavigationController?.push(MusicPlayerViewController.instanseFromStoryboard()!)
    }
}

extension MusicCollectionListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        musicNavigationController?.push(MusicListViewController.instanseFromStoryboard()!, hiddenTabBar: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MusicCollectionListTableViewCell.reuseIdentifier, for: indexPath) as? MusicCollectionListTableViewCell else { return MusicCollectionListTableViewCell() }
        cell.indexPath = indexPath
        return cell
    }
}
