//
//  IGCommon.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/12/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import Foundation
import UIKit

//Superstar Code :)

protocol Reusable {}

extension Reusable where Self: UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: Reusable {}

extension UICollectionView {

    func register<T: UICollectionViewCell>(_ :T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("could not dequeue cell")
        }
        return cell
    }

}
