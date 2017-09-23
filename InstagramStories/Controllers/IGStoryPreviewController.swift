//
//  IGStoryPreviewController.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout

class IGStoryPreviewController: UIViewController {
    
    //MARK: - iVars
    public var stories:IGStories?
    public var storyIndex:Int = 0
    
    var direction: UICollectionViewScrollDirection = .horizontal
    var animator: (LayoutAttributesAnimator, Bool, Int, Int) = (CubeAttributesAnimator(), true, 1, 1)
    
    @IBOutlet var dismissGesture: UISwipeGestureRecognizer!
    @IBOutlet weak var collectionview: UICollectionView! {
        didSet {
            collectionview.delegate = self
            collectionview.dataSource = self
            collectionview.register(IGStoryPreviewCell.nib(), forCellWithReuseIdentifier: IGStoryPreviewCell.reuseIdentifier())
            collectionview?.isPagingEnabled = true
            collectionview.isPrefetchingEnabled = false
            if let layout = collectionview?.collectionViewLayout as? AnimatedCollectionViewLayout {
                layout.scrollDirection = direction
                layout.animator = animator.0
            }
        }
    }
    
    //MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Story"
        dismissGesture.direction = direction == .horizontal ? .down : .left
        /* let nIndexPath = IndexPath.init(row: storyIndex, section: 0)
         collectionview.scrollToItem(at: nIndexPath, at: .centeredHorizontally, animated: true)*/
        print("Story\(storyIndex)")
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    //MARK: - Selectors
    @IBAction func didSwipeDown(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension IGStoryPreviewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //@Note:Story->ScrollView->NumberOfSnaps
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = stories?.count {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryPreviewCell.reuseIdentifier(), for: indexPath) as? IGStoryPreviewCell else{return UICollectionViewCell()}
        cell.storyHeaderView?.delegate = self
        
        let story = stories?.stories?[indexPath.row]
        cell.story = story
        cell.delegate = self
        cell.snapIndex = 0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
}

extension IGStoryPreviewController:StoryPreviewHeaderTapper {
    func didTapCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
extension IGStoryPreviewController:StoryPreviewProtocol {
    func didCompletePreview() {
        let n = storyIndex+1
        if let count = stories?.count {
            if n < count {
                //Move to next story
                storyIndex = storyIndex + 1
                print("Story\(storyIndex)")
                let nIndexPath = IndexPath.init(row: self.storyIndex, section: 0)
                self.collectionview.scrollToItem(at: nIndexPath, at: .right, animated: true)
                
            }else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

