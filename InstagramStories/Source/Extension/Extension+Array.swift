//
//  Extension+Array.swift
//  InstagramStories
//
//  Created by Ranjit on 27/09/20.
//  Copyright © 2020 DrawRect. All rights reserved.
//

import Foundation
import UIKit

extension Array {
    func sortedArrayByPosition() -> [Element] {
        return sorted(by: { (obj1: Element, obj2: Element) -> Bool in
            
            guard let view1 = obj1 as? UIView,
                  let view2 = obj2 as? UIView else {
                fatalError("view1 | view2 kind mismatch")
            }
            
            let x1 = view1.frame.minX
            let y1 = view1.frame.minY
            let x2 = view2.frame.minX
            let y2 = view2.frame.minY
            
            if y1 != y2 {
                return y1 < y2
            } else {
                return x1 < x2
            }
        })
    }
}
