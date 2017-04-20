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
    /// - Returns: UIVisualEffectView
    func addBlurEffect(style: UIBlurEffectStyle) -> UIVisualEffectView
    
    /// Add new vibarancy effect
    ///
    /// - Parameter style: UIBlurEffectStyle
    /// - Returns: UIVisualEffectView
    func addVibrancyEffect(style: UIBlurEffectStyle) -> UIVisualEffectView
    
    /// Remove Effect from super view if exist
    func removeEffect()
    
    /// Adjust Effective by alpha
    ///
    /// Setting the alpha to less than 1 on the visual effect view
    /// or any of its superviews causes many effects to look incorrect or not show up at all.
    ///
    /// - Parameter alpha: Alpha in the range 0.0 to 1.0
    func adjustEffect(alpha: CGFloat)
}

extension UIView: BlurEffect {
    
    @discardableResult
    func addBlurEffect(style: UIBlurEffectStyle = .dark) -> UIVisualEffectView {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        addSubview(effectView)
        
        return effectView
    }
    
    func addVibrancyEffect(style: UIBlurEffectStyle = .dark) -> UIVisualEffectView {
        
        let effectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: style)))
        addSubview(effectView)
        
        return effectView
    }
    
    func removeEffect() {
        subviews.filter{ $0.isKind(of: UIVisualEffectView.self) }.forEach{ $0.removeFromSuperview() }
    }
    
    func adjustEffect(alpha: CGFloat) {
        subviews.filter{ $0.isKind(of: UIVisualEffectView.self) }.forEach{ $0.alpha = alpha }
    }
}
