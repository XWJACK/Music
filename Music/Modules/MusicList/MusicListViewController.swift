//
//  MusicListViewController.swift
//  Music
//
//  Created by Jack on 4/28/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit
import SnapKit

class MusicListViewController: MusicViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Music"
        let actionButton = MusicButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        actionButton.addTarget(self, action: #selector(actionButtonClicked(_:)), for: .touchUpInside)
        navigationBar.actionButton = actionButton
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MusicListTableViewCell.self, forCellReuseIdentifier: MusicListTableViewCell.reuseIdentifier)
        tableView.backgroundColor = .clear
        
        actionButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(28)
        }
    }
    
    @objc private func actionButtonClicked(_ sender: MusicButton) {
//        sender.startAnimation()
        sender.isAnimation = !sender.isAnimation
//        navigationController?.pushViewController(MusicPlayerViewController.instanseFromStoryboard()!, animated: true)
    }
}

extension MusicListViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MusicListTableViewCell.reuseIdentifier, for: indexPath) as? MusicListTableViewCell else { return MusicListTableViewCell() }
        cell.delegate = self
        cell.indexPath = indexPath
        
        cell.musicLabel.text = "时间煮雨"
        cell.detailLabel.text = "许文杰"
        return cell
    }
}


extension MusicListViewController: MusicListTableViewCellDelegate {
    
    func moreButtonClicked(withIndexPath indexPath: IndexPath) {
        
    }
}
