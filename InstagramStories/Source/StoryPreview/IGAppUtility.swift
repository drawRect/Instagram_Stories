//
//  IGAppUtility.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 23/05/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation
import UIKit

struct IGAppUtility {
    static func setOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationSupport = orientation
        }
    }
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func setOrientation(
        _ orientation: UIInterfaceOrientationMask,
        andRotateTo rotateOrientation: UIInterfaceOrientation) {
        self.setOrientation(orientation)
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
}
