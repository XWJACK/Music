//
//  UIViewExtension.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

extension UIView {
    
    /// make edges equal to super view
    func snpEdges() {
        self.snp.makeConstraints { (make) in make.edges.equalToSuperview() }
    }
    
    func showToast(_ message: String) {
        DispatchManager.default.main.async {
            self.makeToast(message, duration: 1, position: .center)
        }
    }
}
