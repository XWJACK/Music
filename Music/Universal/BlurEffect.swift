//
//  BlurEffect.swift
//  Music
//
//  Created by Jack on 3/15/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit
import SnapKit

/// BlurEffect for UIView
protocol BlurEffect {
    
    /// Add New Blur Effect
    ///
    /// - Parameter style: UIBlurEffectStyle
    func addBlur(style: UIBlurEffectStyle) -> UIVisualEffectView
    
    /// Remove Blur from super view
    func removeBlur()
    
    /// Adjust Blur Effective by alpha
    ///
    /// Setting the alpha to less than 1 on the visual effect view
    /// or any of its superviews causes many effects to look incorrect or not show up at all.
    ///
    /// - Parameter alpha: Alpha in the range 0.0 to 1.0
    func adjustBlur(alpha: CGFloat)
}

extension BlurEffect where Self: UIView {
    
    @discardableResult
    func addBlur(style: UIBlurEffectStyle = .dark) -> UIVisualEffectView {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        addSubview(effectView)
        
//        effectView.snpEdges()
        return effectView
    }
    
    func removeBlur() {
        subviews.filter{ $0.isKind(of: UIVisualEffectView.self) }.forEach{ $0.removeFromSuperview() }
    }
    
    func adjustBlur(alpha: CGFloat) {
        subviews.filter{ $0.isKind(of: UIVisualEffectView.self) }.forEach{ $0.alpha = alpha }
    }
}
