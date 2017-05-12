//
//  MusicSearchViewController.swift
//  Music
//
//  Created by Jack on 4/19/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

struct MusicSearchViewModel {
    var name: String = ""
    var detail: String = ""
}

final class MusicSearchViewController: MusicTableViewController, UISearchBarDelegate {
    
    private let searchBar = UISearchBar()
    private let cancelButton = UIButton(type: .custom)
    
    private var searchText: String = ""
    private var offSet: Int = 1
    private var apiDatas: [MusicSearchModel] = []
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
    }
    
    private func request(_ isNewSearch: Bool, _ searchText: String) {
//        if searchText.isEmpty {
//            self.tableView.simpleEmptyView(show: false)
//            tableView.endRefreshing(resetToPageZero: false, hasMore: apiDatas.hasMore)
//            return
//        }
        guard !searchText.isEmpty else { return }
        
//        NetworkManager.request(Router.search(searchText, pageStruct))
//            .success{ (datas: LPArray<Account>) in
//                self.apiDatas = datas
//            }.fail {
//                self.tableView.mj_footer.endRefreshing()
//                self.tableView.simpleEmptyView()
//            }.response {
//                self.tableView.endRefreshing(resetToPageZero: false, hasMore: self.apiDatas.hasMore)
//        }
        MusicNetwork.default.request(MusicAPI.default.search(keyWords: searchText, offset: offSet - 1), success: {
            let results = $0.result["songs"].arrayValue.map{ MusicSearchModel($0) }
            
            if isNewSearch { self.apiDatas = results }
            else { results.forEach{ self.apiDatas.append($0) } }
            
            self.searchViewModels = self.apiDatas.map{ $0.musicSearchViewMode }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    @objc private func cancelButtonClicked() {
        musicNavigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard self.searchText != searchText else { return }
        self.searchText = searchText
        request(true, searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar(searchBar, textDidChange: searchText)
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
        MusicResourceManager.default.reset(resources, resourceIndex: indexPath.row)
        musicPlayerViewController.play(withResourceId: MusicResourceManager.default.current())
        musicNavigationController?.push(musicPlayerViewController)
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

