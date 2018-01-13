//
//  IGCommon.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/12/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import Foundation
import UIKit

protocol CellConfigurer: class {
    static func nib() -> UINib
    static func reuseIdentifier() -> String
}

extension CellConfigurer {
    static func nib() -> UINib {
        return UINib.init(nibName: self.reuseIdentifier(), bundle: nil)
    }
    static func reuseIdentifier() -> String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: CellConfigurer {}

extension UITableViewCell: CellConfigurer {}

