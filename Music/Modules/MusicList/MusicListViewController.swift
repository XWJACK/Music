//
//  MusicListViewController.swift
//  Music
//
//  Created by Jack on 4/28/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit
import SnapKit

final class MusicListViewController: MusicTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Music List"
        
        let rightButton = MusicButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        rightButton.addTarget(self, action: #selector(actionButtonClicked(_:)), for: .touchUpInside)
        musicNavigationBar.rightButton = rightButton
        
        tableView.register(MusicListTableViewCell.self, forCellReuseIdentifier: MusicListTableViewCell.reuseIdentifier)
        
        rightButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(28)
        }
    }
    
    @objc private func actionButtonClicked(_ sender: MusicButton) {
//        sender.startAnimation()
//        sender.isAnimation = !sender.isAnimation
        musicNavigationController?.push(MusicPlayerViewController.instanseFromStoryboard()!)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MusicListTableViewCell.reuseIdentifier, for: indexPath) as? MusicListTableViewCell else { return MusicListTableViewCell() }
        cell.delegate = self
        cell.indexPath = indexPath
        
        cell.musicLabel.text = "一生所爱"
        cell.detailLabel.text = "Jack Sparrow"
        return cell
    }
}


extension MusicListViewController: MusicListTableViewCellDelegate {
    
    func moreButtonClicked(withIndexPath indexPath: IndexPath) {
        
    }
}
