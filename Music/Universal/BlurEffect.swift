//
//  BlurEffect.swift
//  Music
//
//  Created by Jack on 3/15/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

/// BlurEffect for UIView
protocol BlurEffect {
    func addBlur(style: UIBlurEffectStyle)
    func removeBlur()
    /// Setting the alpha to less than 1 on the visual effect view or any of its superviews causes many effects to look incorrect or not show up at all.
    func adjustBlur(alpha: CGFloat)
}

extension BlurEffect where Self: UIView {
    
    func addBlur(style: UIBlurEffectStyle = .dark) {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        addSubview(effectView)
    }
    
    func removeBlur() {
        subviews.filter{ $0.isKind(of: UIVisualEffectView.self) }.forEach{ $0.removeFromSuperview() }
    }
    
    func adjustBlur(alpha: CGFloat) {
        subviews.filter{ $0.isKind(of: UIVisualEffectView.self) }.forEach{ $0.alpha = alpha }
    }
}
