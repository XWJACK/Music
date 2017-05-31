//
//  MusicCollectionListTableViewCell.swift
//  Music
//
//  Created by Jack on 5/3/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicCollectionListTableViewCell: MusicTableViewCell {

    let coverImageView = UIImageView()
    let titleLabel = UILabel()
    let detailLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        leftPadding = 55
        
        titleLabel.textColor = .white
        titleLabel.text = ""
        titleLabel.font = .font14
        
        detailLabel.textColor = .darkGray
        detailLabel.font = .font10
        detailLabel.text = ""
        
        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        
        coverImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.top.equalToSuperview().offset(3)
            make.bottom.equalToSuperview().offset(-3)
            make.width.equalTo(coverImageView.snp.height)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coverImageView.snp.right).offset(10)
            make.top.equalToSuperview().offset(8)
            make.right.greaterThanOrEqualToSuperview().offset(-50)
        }
        
        detailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    func update(_ viewModel: MusicCollectionListViewModel) {
        titleLabel.text = viewModel.name
        detailLabel.text = viewModel.detail
        coverImageView.kf.setImage(with: viewModel.coverImageUrl,
                                   placeholder: coverImageView.image,
                                   options: [.transition(.fade(1))])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
