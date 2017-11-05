//
//  IGStory+Additions.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/28/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import Foundation

//@Note:When it required usecase would go more that one struct. try to use it on your custom protocol, and adopt into your structs. Rather than implementating in each structs. #ProtocolOrientedProgramming
extension IGStory {
    public /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func ==(lhs: IGStory, rhs: IGStory) -> Bool {
        return lhs == rhs
    }
}

import ObjectiveC

fileprivate var kLastPlayedSnapIndex: String = "story.lastPlayedSnapIndex"

extension IGStory {
    var lastPlayedSnapIndex:Int {
        get {
            return (objc_getAssociatedObject(self, &kLastPlayedSnapIndex) as! Int)
        }
        set {
            objc_setAssociatedObject(self, &kLastPlayedSnapIndex, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
