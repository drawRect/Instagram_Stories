//
//  IGSnap+Additions.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 07/10/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import Foundation
import ObjectiveC

fileprivate var kProgress: String = "snap.progress"

extension IGSnap {
    var progress:Float {
        get {
            return (objc_getAssociatedObject(self, &kProgress) as! Float)
        }
        set {
            objc_setAssociatedObject(self, &kProgress, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
