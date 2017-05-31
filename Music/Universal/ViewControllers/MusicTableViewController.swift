//
//  MusicTableViewController.swift
//  Music
//
//  Created by Jack on 5/4/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicTableViewController: MusicViewController, UITableViewDataSource, UITableViewDelegate {
    
    let backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "background_default_dark-ip5"))
    var effectView: UIVisualEffectView?
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        
        view.addSubview(backgroundImageView)
        effectView = view.addBlurEffect(style: .light)
        view.addSubview(tableView)
        
        effectView?.alpha = 0.6
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        effectView?.snp.makeConstraints { (make) in
            make.width.height.equalTo(backgroundImageView)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(64)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
        }
        
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return MusicTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
