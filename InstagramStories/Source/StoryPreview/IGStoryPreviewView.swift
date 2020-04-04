//
//  IGStoryPreviewView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 18/03/18.
//  Copyright © 2018 DrawRect. All rights reserved.
//

import UIKit

public enum IGLayoutType {
    case cubic
    var animator: LayoutAttributesAnimator {
        switch self {
        case .cubic:return CubeAttributesAnimator(perspective: -1/100, totalAngle: .pi/12)
        }
    }
}

class IGStoryPreviewView: UIView {
    // MARK: iVars
    var layoutType: IGLayoutType!
    /**Layout Animate options(ie.choose which kinda animation you want!)*/
    lazy var layoutAnimator: (LayoutAttributesAnimator, Bool) = (layoutType.animator, true)
    lazy var snapsCollectionViewFlowLayout: AnimatedCollectionViewLayout = {
        let flowLayout = AnimatedCollectionViewLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.animator = layoutAnimator.0
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        return flowLayout
    }()
    lazy var snapsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: IGScreen.width,
                height: IGScreen.height
        ), collectionViewLayout: snapsCollectionViewFlowLayout)
        collectionView.backgroundColor = .black
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(IGStoryPreviewCell.self, forCellWithReuseIdentifier: IGStoryPreviewCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        collectionView.isPrefetchingEnabled = false
        collectionView.collectionViewLayout = snapsCollectionViewFlowLayout
        return collectionView
    }()
    // MARK: Overridden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init(layoutType: IGLayoutType) {
        self.init()
        self.layoutType = layoutType
        createUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // MARK: Private functions
    private func createUIElements() {
        backgroundColor = .black
        addSubview(snapsCollectionView)
    }
    private func installLayoutConstraints() {
        //Setting constraints for snapsCollectionview
        NSLayoutConstraint.activate([
            igLeftAnchor.constraint(equalTo: snapsCollectionView.igLeftAnchor),
            igTopAnchor.constraint(equalTo: snapsCollectionView.igTopAnchor),
            snapsCollectionView.igRightAnchor.constraint(equalTo: igRightAnchor),
            snapsCollectionView.igBottomAnchor.constraint(equalTo: igBottomAnchor)])
    }
}
