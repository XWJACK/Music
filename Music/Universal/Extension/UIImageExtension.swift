//
//  UIImageExtension.swift
//  Music
//
//  Created by Jack on 5/2/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func image(withColor color: UIColor = .clear, rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()!
        color.setFill()
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
