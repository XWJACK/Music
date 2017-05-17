//
//  MusicCollectionListViewController.swift
//  Music
//
//  Created by Jack on 5/3/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

struct MusicCollectionListViewModel {
    var coverImageUrl: URL? = nil
    var name: String = ""
    var detail: String = ""
}

final class MusicCollectionListViewController: MusicTableViewController {

    private var apiDatas: [MusicPlayListModel] = []
    private var viewModels: [MusicCollectionListViewModel] = []
    
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
        
        tableView.mj_header = RefreshNormalHeader { [unowned self] in
            self.request()
        }
        
        searchButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(28)
        }
        
        request()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        musicNavigationBar.rightButton.isHidden = musicPlayerViewController.isHiddenInput
    }
    
    private func request() {
        guard let userId = AccountManager.default.account?.id else { tableView.mj_header.endRefreshing(); return }
        
        MusicNetwork.send(API.playList(userId: userId))
            .receive(json: { (json) in
            guard json.isSuccess else { return }
            self.apiDatas = json["playlist"].array?.map{ MusicPlayListModel($0) } ?? []
            self.viewModels = self.apiDatas.map{ $0.musicCollectionListViewModel }
            self.tableView.reloadData()
            })
            .receive {
                self.tableView.mj_header.endRefreshing()
        }
    }
    
    @objc private func actionButtonClicked(_ sender: MusicButton) {
        musicNavigationController?.push(musicPlayerViewController)
    }
    
    @objc private func searchButtonClicked(_ sender: UIButton) {
        musicNavigationController?.push(MusicSearchViewController(), hiddenTopBarLeftButton: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let controller = MusicListViewController()
        controller.listId = apiDatas[indexPath.row].id
        musicNavigationController?.push(controller, hiddenTabBar: false)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MusicCollectionListTableViewCell.reuseIdentifier, for: indexPath) as? MusicCollectionListTableViewCell else { return MusicCollectionListTableViewCell() }
        cell.indexPath = indexPath
        cell.update(viewModels[indexPath.row])
        return cell
    }
}
