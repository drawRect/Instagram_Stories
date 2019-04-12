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
    var window: UIWindow? = {
        let window = UIWindow()
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        return window
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        rootSceneSetup()
        return true
    }
}

extension AppDelegate {
    func rootSceneSetup() {
        let navigationController = UINavigationController(rootViewController: IGHomeController())
        navigationController.navigationBar.isTranslucent = false
        window?.rootViewController = navigationController
    }
}
