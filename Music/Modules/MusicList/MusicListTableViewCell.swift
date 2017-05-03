//
//  MusicListTableViewCell.swift
//  Music
//
//  Created by Jack on 5/1/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

protocol MusicListTableViewCellDelegate: class {
    func moreButtonClicked(withIndexPath indexPath: IndexPath)
}

class MusicListTableViewCell: MusicTableViewCell {
    
    var delegate: MusicListTableViewCellDelegate?
    
    override var indexPath: IndexPath {
        didSet {
            numberLabel.text = indexPath.row.description
        }
    }
    
    let numberLabel = UILabel()
    let musicLabel = UILabel()
    let detailLabel = UILabel()
    
    private let moreButton = UIButton(type: .custom)
    private let leftContentView = UIView()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        leftPadding = 40
        
        numberLabel.textColor = .black
        numberLabel.font = .font16
        
        musicLabel.font = .font18
        musicLabel.textColor = .white
        
        detailLabel.font = .font10
        detailLabel.textColor = .darkGray
        
        moreButton.setImage(UIImage(cgImage: #imageLiteral(resourceName: "list_cell_more").cgImage!, scale: UIScreen.main.scale, orientation: .left), for: .normal)
        moreButton.setImage(UIImage(cgImage: #imageLiteral(resourceName: "list_cell_more_press").cgImage!, scale: UIScreen.main.scale, orientation: .left), for: .highlighted)
        moreButton.addTarget(self, action: #selector(moreButtonClicked), for: .touchUpInside)
        
        leftContentView.addSubview(numberLabel)
        contentView.addSubview(leftContentView)
        contentView.addSubview(musicLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(moreButton)
        
        leftContentView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(leftPadding)
            make.height.equalToSuperview()
        }
        
        numberLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        moreButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
        
        musicLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftPadding)
            make.top.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-70)
        }
        
        detailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(musicLabel)
            make.bottom.equalToSuperview().offset(-5)
            make.right.equalTo(musicLabel).offset(-20)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func moreButtonClicked() {
        delegate?.moreButtonClicked(withIndexPath: indexPath)
    }
}
