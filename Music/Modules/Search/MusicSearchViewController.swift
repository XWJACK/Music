//
//  MusicSearchViewController.swift
//  Music
//
//  Created by Jack on 4/19/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

struct MusicSearchViewModel {
    var name: String = ""
    var detail: String = ""
}

final class MusicSearchViewController: MusicTableViewController, UISearchBarDelegate {
    
    private let searchBar = UISearchBar()
    private let cancelButton = UIButton(type: .custom)
    
    private var searchText: String = ""
    private var offSet: Int = 0
    private var apiDatas: [MusicDetailModel] = []
    private var searchViewModels: [MusicSearchViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        musicNavigationBar.leftButton.isHidden = true
        
        tableView.register(MusicSearchTableViewCell.self, forCellReuseIdentifier: MusicSearchTableViewCell.reuseIdentifier)
        tableView.keyboardDismissMode = .onDrag
        
        cancelButton.titleLabel?.font = .font16
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        
        searchBar.tintColor = .white
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.layer.cornerRadius = 14
            searchField.layer.masksToBounds = true
            searchField.textColor = .white
        }
        
        musicNavigationBar.addSubview(searchBar)
        musicNavigationBar.addSubview(cancelButton)
        
        searchBar.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(7)
            make.top.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalTo(searchBar.snp.right).offset(2)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(searchBar)
        }
        
        tableView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(64)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        tableView.mj_footer = RefreshBackNormalFooter {[unowned self] in
            self.offSet += 1
            self.request(false, self.searchText)
        }
    }
    
    private func request(_ isNewSearch: Bool, _ searchText: String) {
        if isNewSearch { offSet = 0 }
        guard !searchText.isEmpty else { return }
        
        MusicNetwork.send(API.search(keyWords: searchText, offset: offSet))
            .receive(json: {[weak self] (json) in
                guard let strongSelf = self,
                    json.isSuccess else { return }
                
                let results = json.result["songs"].arrayValue.map{ MusicDetailModel(searchJSON: $0) }
                
                if isNewSearch {
                    strongSelf.apiDatas = results
                    strongSelf.searchViewModels = results.map{ $0.musicSearchViewModel }
                } else {
                    strongSelf.apiDatas.append(contentsOf: results)
                    strongSelf.searchViewModels.append(contentsOf: results.map{ $0.musicSearchViewModel })
                }
                strongSelf.tableView.endRefreshing(hasMore: json.result["songCount"].intValue > strongSelf.apiDatas.count )
                strongSelf.tableView.reloadData()
            }).receive(response: {[weak self] (json) in
                self?.tableView.mj_footer.endRefreshing()
            })
    }
    
    @objc private func cancelButtonClicked() {
        musicNavigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard self.searchText != searchText else { return }
        self.searchText = searchText
        
        if searchText.isEmpty {
            apiDatas = []
            searchViewModels = []
            tableView.reloadData()
            return
        }
        
        request(true, searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        request(true, searchText)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let resources = apiDatas.map{ $0.resource }
        MusicResourceManager.default.reset(resources,
                                           withIdentifier: "Search" + searchText + resources.count.description,
                                           currentResourceIndex: indexPath.row)
        musicNavigationController?.push(musicPlayerViewController)
        musicPlayerViewController.playResource()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MusicSearchTableViewCell.reuseIdentifier, for: indexPath) as? MusicSearchTableViewCell else { return MusicSearchTableViewCell() }
        let viewModel = searchViewModels[indexPath.row]
        cell.indexPath = indexPath
        cell.musicLabel.text = viewModel.name
        cell.detailLabel.text = viewModel.detail
        return cell
    }
}

