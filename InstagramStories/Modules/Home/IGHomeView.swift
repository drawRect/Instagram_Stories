//
//  IGHomeView.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 01/11/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import Foundation
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
        let cv = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(IGStoryListCell.self, forCellWithReuseIdentifier: IGStoryListCell.reuseIdentifier)
        cv.register(IGAddStoryCell.self, forCellWithReuseIdentifier: IGAddStoryCell.reuseIdentifier)
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
    private func createUIElements(){
        addSubview(collectionView)
    }
    private func installLayoutConstraints(){
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 100)])
    }
}
