//
//  Gesture.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

/// Gesture
protocol Gesture {
    
    /// Add Swip Gesture into current view
    ///
    /// - Parameters:
    ///   - target: Target
    ///   - action: Action
    ///   - direction: Direction
    func addSwipGesture(target: Any?, action: Selector, direction: UISwipeGestureRecognizerDirection)
}

extension Gesture where Self: UIView {
    
    func addSwipGesture(target: Any?, action: Selector, direction: UISwipeGestureRecognizerDirection) {
        let gesture = UISwipeGestureRecognizer(target: target, action: action)
        gesture.direction = direction
        addGestureRecognizer(gesture)
    }
}
