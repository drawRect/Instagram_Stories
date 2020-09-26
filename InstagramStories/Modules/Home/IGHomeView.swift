//
//  IGHomeView.swift
//  InstagramStories
//
//  Created by  Boominadha Prakash on 01/11/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

class IGHomeView: UIView {
    
    //MARK: - iVars
    lazy var layout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 100, height: 100)
        return flowLayout
    }()
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    //MARK: - Overridden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.rgb(from: 0xEFEFF4)
        createUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private functions
    private func createUIElements() {
        addSubview(collectionView)
    }
    private func installLayoutConstraints() {
        let top = igTopAnchor.constraint(equalTo: collectionView.igTopAnchor)
        let left = igLeftAnchor.constraint(equalTo: collectionView.igLeftAnchor)
        let right = collectionView.igRightAnchor.constraint(equalTo: igRightAnchor)
        let height = collectionView.heightAnchor.constraint(equalToConstant: 100)
        NSLayoutConstraint.activate([top,left,right,height])
    }
}
