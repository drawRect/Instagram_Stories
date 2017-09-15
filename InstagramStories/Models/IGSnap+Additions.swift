//
//  IGSnap+Additions.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/15/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import Foundation
import ObjectiveC
import UIKit

fileprivate var klastPlayedIndex: Int = -1

extension IGSnap {
    var lastPlayedIndex:Bool {
        get {
            return objc_getAssociatedObject(self, &klastPlayedIndex) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &klastPlayedIndex, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
