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
    
    public var stories:IGStories?
    var storyIndex:Int = 0
    public var handPickedIndex:Int = 0
    
    override var prefersStatusBarHidden: Bool { return true }
    var direction: UICollectionViewScrollDirection = .horizontal
    var animator: (LayoutAttributesAnimator, Bool, Int, Int) = (CubeAttributesAnimator(), true, 1, 1)
    
    @IBOutlet var dismissGesture: UISwipeGestureRecognizer!
    @IBOutlet weak var collectionview: UICollectionView! {
        didSet {
            collectionview.delegate = self
            collectionview.dataSource = self
            collectionview.register(IGStoryPreviewCell.nib(), forCellWithReuseIdentifier: IGStoryPreviewCell.reuseIdentifier())
            collectionview?.isPagingEnabled = true
            
            if let layout = collectionview?.collectionViewLayout as? AnimatedCollectionViewLayout {
                layout.scrollDirection = direction
                layout.animator = animator.0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Story"
        dismissGesture.direction = direction == .horizontal ? .down : .left
    }
    
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
        return (stories?.count)!-handPickedIndex
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryPreviewCell.reuseIdentifier(), for: indexPath) as! IGStoryPreviewCell
        cell.storyHeaderView?.delegate = self
        
        //Start with handpicked story from Home.
        let story = stories?.stories?[indexPath.row+handPickedIndex]
        cell.story = story
        cell.generateImageViews()
        cell.delegate = self
        cell.scrollview.contentSize = CGSize(width:cell.scrollview.frame.size.width * CGFloat((story?.snapsCount)!), height:cell.scrollview.frame.size.height)
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
                let nIndexPath = IndexPath.init(row: storyIndex, section: 0)
                collectionview.scrollToItem(at: nIndexPath, at: .centeredHorizontally, animated: true)
            }else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

