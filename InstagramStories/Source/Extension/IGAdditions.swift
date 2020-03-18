//
//  IGAdditions.swift
//  InstagramStories
//
//  Created by  Boominadha Prakash on 12/11/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

extension Int {
    var `CGFlot`: CGFloat {
        return CGFloat(self)
    }
}

extension Array {
    var sortedByPosition: [Element] {
        return sorted(by: { (elem1: Element, elem2: Element) -> Bool in
            guard let elem1MinX = (elem1 as? UIView)?.frame.minX,
                let elem1MinY = (elem1 as? UIView)?.frame.minY,
                let elem2MinX = (elem2 as? UIView)?.frame.minX,
                let elem2MinY = (elem2 as? UIView)?.frame.minY else {
                    return false
            }
            if elem1MinY != elem2MinY {
                return elem1MinY < elem2MinY
            } else {
                return elem1MinX < elem2MinX
            }
        })
    }
}
