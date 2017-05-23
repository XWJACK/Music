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

    private var localViewModels: [(listId: String, image: UIImage, title: String, detail: String)] = []
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
        
        localViewModels.append(("Download", #imageLiteral(resourceName: "collection_downloaded"), "Local Music", "0 songs"))
        
        request()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        musicNavigationBar.rightButton.isHidden = musicPlayerViewController.isHiddenInput
    }
    
    private func request() {
        guard let userId = AccountManager.default.account?.id else { tableView.mj_header.endRefreshing(); return }
        
        localViewModels[0].detail = MusicDataBaseManager.default.downloadCount().description + " songs"
        
        MusicNetwork.send(API.playList(userId: userId))
            .receive(queue: .global(), json: {
                if self.parseCollectionList($0) {
                    MusicDataBaseManager.default.set(userId, collectionList: $0)
                }
            })
            .receive {
                self.tableView.mj_header.endRefreshing()
                self.tableView.reloadData()
            }
            .receive(queue: .global(), failed: {
                self.networkBusy($0)
                guard let json = MusicDataBaseManager.default.get(userId: userId) else { return }
                self.parseCollectionList(json)
            })
    }
    
    @discardableResult
    private func parseCollectionList(_ json: JSON) -> Bool {
        guard json.isSuccess else { return false }
        apiDatas = json["playlist"].array?.map{ MusicPlayListModel($0) } ?? []
        viewModels = self.apiDatas.map{ $0.musicCollectionListViewModel }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        return true
    }
    
    @discardableResult
    private func parseListDetail(_ controller: MusicListViewController, json: JSON) -> Bool {
        guard json.isSuccess else { return false }
        controller.apiDatas = MusicPlayListDetailModel(json["playlist"])
        DispatchQueue.main.async {
            controller.tableView.reloadData()
        }
        return true
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? localViewModels.count : viewModels.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let controller = MusicListViewController()
        
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            let listId = localViewModels[indexPath.row].listId
            DispatchQueue.global().async {
                controller.listId = listId
                controller.resources = MusicDataBaseManager.default.downloadList().map{ MusicDataBaseManager.default.get(resourceId: $0) }.filter{ $0 != nil }.map{ $0! }
                controller.viewModels = controller.resources.map{
                    var model = MusicPlayListDetailViewModel()
                    model.name = $0.name
                    model.detail = ($0.artist?.name ?? "") + "-" + ($0.album?.name ?? "")
                    return model
                }
                DispatchQueue.main.async {
                    controller.tableView.reloadData()
                }
            }
        case (1, _):
            let listId = apiDatas[indexPath.row].id
            controller.listId = listId
            MusicNetwork.send(API.detail(listId: listId))
                .receive(queue: .global(), json: { (json) in
                    
                    if self.parseListDetail(controller, json: json) {
                        MusicDataBaseManager.default.set(listId, listDetail: json)
                    }
                })
                .receive(queue: .global(), failed: { (error) in
                    guard let json = MusicDataBaseManager.default.get(listId: listId) else { return }
                    self.parseListDetail(controller, json: json)
                })
        default: break
        }
        musicNavigationController?.push(controller, hiddenTabBar: false)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MusicCollectionListTableViewCell.reuseIdentifier, for: indexPath) as? MusicCollectionListTableViewCell else { return MusicCollectionListTableViewCell() }
        cell.indexPath = indexPath
        if indexPath.section == 0 {
            let viewModel = localViewModels[indexPath.row]
            cell.coverImageView.image = viewModel.image
            cell.titleLabel.text = viewModel.title
            cell.detailLabel.text = viewModel.detail
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        cell.update(viewModels[indexPath.row])
        return cell
    }
}
