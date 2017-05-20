//
//  AppDelegate.swift
//  Music
//
//  Created by Jack on 3/1/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MusicTabBarController()
        window?.makeKeyAndVisible()
        
        let attributesTabBarNormal = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.font10]
        let attributesTabBarSelected = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.font10]
        UITabBarItem.appearance().setTitleTextAttributes(attributesTabBarNormal, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attributesTabBarSelected, for: .selected)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            
        }
        
        #if DEBUG
            ConsoleLog.isDebug = true
        #endif
        
        MusicNetwork.globalFailCallBack.block = { ConsoleLog.error($0) }
        
        MPRemoteCommandCenter.shared().playCommand.addTarget(musicPlayerViewController, action: #selector(musicPlayerViewController.playCommand))
        MPRemoteCommandCenter.shared().pauseCommand.addTarget(musicPlayerViewController, action: #selector(musicPlayerViewController.pauseCommand))
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(musicPlayerViewController, action: #selector(musicPlayerViewController.nextTrack))
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(musicPlayerViewController, action: #selector(musicPlayerViewController.lastTrack))
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

