//
//  UIViewControllerExtension.swift
//  Music
//
//  Created by Jack on 29/04/2017.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

extension UIViewController {
    func networkBusy(_ error: Error) -> () {
        DispatchQueue.main.async {
            self.view.makeToast(networkBusyString)
        }
        ConsoleLog.error(error)
    }
}
