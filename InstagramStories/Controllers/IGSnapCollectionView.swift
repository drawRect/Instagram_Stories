//
//  IGSnapCollectionView.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 09/12/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout

class IGSnapCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
