//
//  MusicSearchViewController.swift
//  Music
//
//  Created by Jack on 4/19/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit
import SnapKit

final class MusicSearchViewController: MusicTableViewController, UISearchBarDelegate {
    
    private let searchBar = UISearchBar()
    private let cancelButton = UIButton(type: .custom)
    
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
    
    @objc private func cancelButtonClicked() {
//        musicNavigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MusicSearchTableViewCell.reuseIdentifier, for: indexPath) as? MusicSearchTableViewCell else { return MusicSearchTableViewCell() }
        cell.indexPath = indexPath
        cell.musicLabel.text = "Jack 时间"
        cell.detailLabel.text = "jack-aksjdfl;a"
        return cell
    }
}

