//
//  MusicSettingViewController.swift
//  Music
//
//  Created by Jack on 5/3/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicSettingViewController: MusicViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Setting"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MusicListTableViewCell.self, forCellReuseIdentifier: MusicListTableViewCell.reuseIdentifier)
        tableView.backgroundColor = .clear
    }
}

extension MusicSettingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MusicListTableViewCell.reuseIdentifier, for: indexPath) as? MusicListTableViewCell else { return MusicListTableViewCell() }
        
        cell.indexPath = indexPath
        
        return cell
    }
}
