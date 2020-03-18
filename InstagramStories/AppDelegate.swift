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
        let wndow = UIWindow()
        wndow.backgroundColor = .white
        wndow.makeKeyAndVisible()
        return wndow
    }()
    /// set orientations you want to be allowed in this property by default
    var orientationSupport = UIInterfaceOrientationMask.all
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        rootSceneSetup()
        return true
    }
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return self.orientationSupport
    }
}

extension AppDelegate {
     func rootSceneSetup() {
        let navController = UINavigationController(rootViewController: IGHomeController())
        navController.navigationBar.isTranslucent = false
        window.rootViewController = navController
    }
}
