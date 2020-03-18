//
//  IGHomeView.swift
//  InstagramStories
//
//  Created by  Boominadha Prakash on 01/11/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import Foundation
import UIKit

class IGHomeView: UIView {
    // MARK: iVars
    lazy var layout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 100, height: 100)
        return flowLayout
    }()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(IGStoryListCell.self, forCellWithReuseIdentifier: IGStoryListCell.reuseIdentifier)
        collectionView.register(IGAddStoryCell.self, forCellWithReuseIdentifier: IGAddStoryCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    // MARK: Overridden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(rgb: 0xEFEFF4)
        createUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: Private functions
    private func createUIElements() {
        addSubview(collectionView)
    }
    private func installLayoutConstraints() {
        NSLayoutConstraint.activate([
            igLeftAnchor.constraint(equalTo: collectionView.igLeftAnchor),
            igTopAnchor.constraint(equalTo: collectionView.igTopAnchor),
            collectionView.igRightAnchor.constraint(equalTo: igRightAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 100)])
    }
}
