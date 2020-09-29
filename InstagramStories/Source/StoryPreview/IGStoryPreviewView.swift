//
//  IGStoryPreviewView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 18/03/18.
//  Copyright © 2018 DrawRect. All rights reserved.
//

import UIKit

///This class is override the preview controller view on load method
final class IGStoryPreviewView: UIView {
    
    let collectionView: UICollectionView = {
        let viewLayout = AnimatedCollectionViewLayout()
        viewLayout.scrollDirection = .horizontal
        viewLayout.animator = CubeAttributesAnimator(perspective: -1/100, totalAngle: .pi/12)
        viewLayout.minimumLineSpacing = 0.0
        viewLayout.minimumInteritemSpacing = 0.0
        viewLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: viewLayout)
        collectionView.backgroundColor = .black
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        collectionView.isPrefetchingEnabled = false
        collectionView.decelerationRate = .fast
        return collectionView
    }()
    
    let swipeUpGestureRecognizer: UISwipeGestureRecognizer = {
        let swipeGestureRecognizer = UISwipeGestureRecognizer()
        swipeGestureRecognizer.direction = .up
        return swipeGestureRecognizer
    }()
    
    let swipeDownGestureRecognizer: UISwipeGestureRecognizer = {
        let swipeGestureRecognizer = UISwipeGestureRecognizer()
        swipeGestureRecognizer.direction = .down
        return swipeGestureRecognizer
    }()
        
    //MARK:- Overridden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUIElements()
        installLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Private functions
    private func createUIElements(){
        backgroundColor = .black
        collectionView.addGestureRecognizer(swipeUpGestureRecognizer)
        collectionView.addGestureRecognizer(swipeDownGestureRecognizer)
        addSubview(collectionView)
    }
    
    private func installLayoutConstraints(){
        let top = igTopAnchor.constraint(equalTo: collectionView.igTopAnchor)
        let left = igLeftAnchor.constraint(equalTo: collectionView.igLeftAnchor)
        let right = collectionView.igRightAnchor.constraint(equalTo: igRightAnchor)
        let bottom = collectionView.igBottomAnchor.constraint(equalTo: igBottomAnchor)
        NSLayoutConstraint.activate([top, left, right, bottom])
    }
}
