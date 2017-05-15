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
    private var apiDatas: MusicPlayListDetailModel?
    private var viewModels: [MusicPlayListDetailViewModel] = []
    
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
        
        tableView.mj_header = RefreshNormalHeader { [unowned self] in
            self.request()
        }
        
        request()
    }
    
    private func request() {
        guard let listId = listId else { tableView.mj_header.endRefreshing(); return }
        MusicNetwork.send(API.detail(listId: listId))
            .receive { self.tableView.mj_header.endRefreshing() }
            .receive(json: { (json) in
                guard json.isSuccess else { return }
                self.apiDatas = MusicPlayListDetailModel(json["playlist"])
                self.viewModels = self.apiDatas?.musicDetail.map{ $0.musicPlayListDetailViewModel } ?? []
                self.tableView.reloadData()
            })
    }
    
    @objc private func actionButtonClicked(_ sender: MusicButton) {
//        sender.startAnimation()
//        sender.isAnimation = !sender.isAnimation
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
