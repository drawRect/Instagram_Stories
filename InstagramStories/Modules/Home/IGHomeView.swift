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
    private let layout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        return flowLayout
    }()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(IGAddStoryCell.self)
        collectionView.register(IGStoryListCell.self)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    //MARK: - Overridden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = IGTheme.lightGrey
        addChildViews()
        installConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private functions
    private func addChildViews(){
        addSubview(collectionView)
    }
    private func installConstraints(){
        NSLayoutConstraint.activate(
            [
            leftAnchor.constraint(
                equalTo: collectionView.leftAnchor
                ),
            topAnchor.constraint(
                equalTo: collectionView.topAnchor
                ),
            collectionView.rightAnchor.constraint(
                equalTo: rightAnchor
                ),
            collectionView.heightAnchor.constraint(
                equalToConstant: 100
                )
            ]
        )
    }
}
