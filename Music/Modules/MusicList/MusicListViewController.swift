//
//  MusicListViewController.swift
//  Music
//
//  Created by Jack on 4/28/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

struct MusicPlayListDetailViewModel {
    var name: String = ""
    var detail: String = ""
}

final class MusicListViewController: MusicTableViewController {
    
    var listId: String?
    
    var apiDatas: MusicPlayListDetailModel? {
        didSet {
            guard let apiDatas = apiDatas else { return }
            resources = apiDatas.tracks.map({ $0.resource })
            viewModels = apiDatas.tracks.map{ $0.musicPlayListDetailViewModel }
        }
    }
    var resources: [MusicResource] = []
    
    var viewModels: [MusicPlayListDetailViewModel] = []
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        musicNavigationBar.rightButton.isHidden = musicPlayerViewController.isHiddenInput
    }
    
    @objc private func actionButtonClicked(_ sender: MusicButton) {
        musicNavigationController?.push(musicPlayerViewController)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        MusicResourceManager.default.reset(resources,
                                           withIdentifier: "MusicList" + listId! + resources.count.description,
                                           currentResourceIndex: indexPath.row)
        musicNavigationController?.push(musicPlayerViewController)
        musicPlayerViewController.playResource()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MusicListTableViewCell.reuseIdentifier, for: indexPath) as? MusicListTableViewCell else { return MusicListTableViewCell() }
        cell.delegate = self
        cell.indexPath = indexPath
        
        cell.musicLabel.text = viewModels[indexPath.row].name
        cell.detailLabel.text = viewModels[indexPath.row].detail
        return cell
    }
}


extension MusicListViewController: MusicListTableViewCellDelegate {
    
    func moreButtonClicked(withIndexPath indexPath: IndexPath) {
        
    }
}
