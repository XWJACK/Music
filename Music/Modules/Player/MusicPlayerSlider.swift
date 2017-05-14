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
    private let progressView = UIProgressView(progressViewStyle: .default)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        progressView.trackTintColor = .clear
        progressView.progressTintColor = UIColor.white.withAlphaComponent(0.25)
        addSubview(progressView)
        
//        indicator.isHidden = true
//        addSubview(indicator)
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.trackRect(forBounds: bounds)
        progressView.frame = superRect
        return superRect
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let superRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
//        indicator.frame = superRect
        return superRect
    }
    
    func buffProgress(_ progress: Progress) {
        progressView.setProgress(progress.fractionCompleted.float, animated: true)
    }
    
    func resetProgress() {
        progressView.setProgress(0, animated: false)
    }
}
