//
//  IGCommon.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/12/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import Foundation
import UIKit

/******** UITableViewCell&UICollectionViewCell<Extension> *******************************/
protocol CellConfigurer:class {
    static func nib()->UINib
    static func reuseIdentifier()->String
}

extension CellConfigurer {
    static func nib() -> UINib {
        return UINib.init(nibName: self.reuseIdentifier(), bundle: nil)
    }
    static func reuseIdentifier() -> String{
        return String(describing: self)
    }
}

extension UICollectionViewCell:CellConfigurer {}
extension UITableViewCell:CellConfigurer {}

/*************************** UINIB<Extension> ************************************************/
extension UINib {
    class func nib(with name:String) -> UINib {
        return UINib.init(nibName: name, bundle: nil)
    }
}

/*************************** Bundle<Extension> ************************************************/
extension Bundle {
    static func loadView<T>(with type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)?.first as? T {
            return view
        }
        fatalError("Could not load view with type " + String(describing: type))
    }
}
