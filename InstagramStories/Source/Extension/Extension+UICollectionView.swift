//
//  Extension+UICollectionView.swift
//  InstagramStories
//
//  Created by Ranjit on 27/09/20.
//  Copyright © 2020 DrawRect. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_: T.Type, indexPath: IndexPath) -> T {
        self.register(T.self, forCellWithReuseIdentifier: String(describing: T.self))
        return self.dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as! T
    }

}
