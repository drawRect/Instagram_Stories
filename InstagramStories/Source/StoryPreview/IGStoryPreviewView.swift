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
        case .cubic:
            return CubeAttributesAnimator(perspective: -1/100,
                                          totalAngle: .pi/12)
        }
    }
}

class IGStoryPreviewView: UIView {
    
    //MARK:- iVars
    var layoutType: IGLayoutType?
    /**Layout Animate options(ie.choose which kinda animation you want!)*/
    lazy var layoutAnimator: (LayoutAttributesAnimator, Bool, Int, Int) = (layoutType!.animator, true, 1, 1)
    var isDeleteSnap: Bool = false
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
        let cv = UICollectionView(
            frame: CGRect(
                x: 0, y: 0, width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height),
            collectionViewLayout: snapsCollectionViewFlowLayout
        )
        cv.backgroundColor = .black
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.isPrefetchingEnabled = false
        cv.decelerationRate = .fast
        cv.collectionViewLayout = snapsCollectionViewFlowLayout
        cv.addGestureRecognizer(swipeDownGestureRecognizer)
        cv.addGestureRecognizer(swipeUpGestureRecognizer)
        return cv
    }()
    
    let swipeUpGestureRecognizer: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .up
        return gesture
    }()
    
    let swipeDownGestureRecognizer: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .down
        return gesture
    }()
    
    lazy var actionSheet: UIAlertController = {
        let ac = UIAlertController(title: Bundle.main.displayName, message: "More...", preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            #warning("enable this func as delegate or property based block in viewcontroller to communicate further")
//            self?.deleteSnap()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            #warning("enable this func as delegate or property based block in viewcontroller to communicate further")
//            self?.currentCell?.resumeEntireSnap()
        }
        ac.addAction(delete)
        ac.addAction(cancel)
        return ac
    }()
    
    //MARK:- Overridden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init(layoutType: IGLayoutType, isDeleteSnap: Bool) {
        self.init()
        self.layoutType = layoutType
        self.isDeleteSnap = isDeleteSnap
        createUIElements()
        installLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Private functions
    private func createUIElements(){
        backgroundColor = .black
        addSubview(snapsCollectionView)
    }
    
    private func installLayoutConstraints(){
        let top = igTopAnchor.constraint(equalTo: snapsCollectionView.igTopAnchor)
        let left = igLeftAnchor.constraint(equalTo: snapsCollectionView.igLeftAnchor)
        let right = snapsCollectionView.igRightAnchor.constraint(equalTo: igRightAnchor)
        let bottom = snapsCollectionView.igBottomAnchor.constraint(equalTo: igBottomAnchor)
        NSLayoutConstraint.activate([top, left, right, bottom ])
    }
}
