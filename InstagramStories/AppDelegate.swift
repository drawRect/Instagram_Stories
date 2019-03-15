//
//  AppDelegate.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let window: UIWindow = {
        let w = UIWindow()
        w.backgroundColor = .white
        w.makeKeyAndVisible()
        return w
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        rootSceneSetup()
        return true
    }
}

extension AppDelegate {
     func rootSceneSetup() {
        let nc:UINavigationController = UINavigationController(rootViewController: IGHomeController())
        nc.navigationBar.isTranslucent = false
        window.rootViewController = nc
    }
}
