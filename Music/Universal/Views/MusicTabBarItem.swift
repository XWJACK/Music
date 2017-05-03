//
//  MusicTabBarItem.swift
//  Music
//
//  Created by Jack on 5/2/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicTabBarItem: UIControl {
    
    var tabBarID = 0
    override var isSelected: Bool {
        didSet {
            imageView.image = isSelected ? selectedImage : image
        }
    }
    private var imageView = UIImageView()
    private var titleLabel = UILabel()
    
    private var image: UIImage?
    private var selectedImage: UIImage?
    
    init(title: String?, image: UIImage?, selectedImage: UIImage?) {
        super.init(frame: .zero)
        
        self.image = image
        self.selectedImage = selectedImage
        
        addSubview(imageView)
        addSubview(titleLabel)
        
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(3)
            make.bottom.equalToSuperview().offset(-2)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
