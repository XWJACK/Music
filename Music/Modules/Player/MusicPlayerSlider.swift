//
//  MusicPlayerSlider.swift
//  Music
//
//  Created by Jack on 4/28/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicPlayerSlider: UISlider {
    
    let thumbImageSize = CGSize(width: 20, height: 20)
//    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
//        indicator.isHidden = true
//        addSubview(indicator)
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let superRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
//        indicator.frame = superRect
        return superRect
    }
}
