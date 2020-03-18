//
//  IGCommon.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/12/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import Foundation
import UIKit

/******** UICollectionViewCell<Extension> **************/
protocol CellConfigurer: class {
    static var nib: UINib {get}
    static var reuseIdentifier: String {get}
}

extension CellConfigurer {
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: CellConfigurer {}
