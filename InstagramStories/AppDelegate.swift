//
//  AppDelegate.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit
import SDWebImage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var window: UIWindow? = { let w =  UIWindow()
        w.backgroundColor = .white
        w.makeKeyAndVisible()
        return w }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        rootSceneSetup()
        //clearSDWebCache()
        return true
    }
}

extension AppDelegate {
     func rootSceneSetup() {
        let nc = UINavigationController.init(rootViewController: IGHomeController())
        self.window?.rootViewController = nc
    }
    func clearSDWebCache() {
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
}
