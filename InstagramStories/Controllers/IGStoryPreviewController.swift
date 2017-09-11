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
    public var storiesIndex:Int = 0
    public var storyIndex:Int = 0
    
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
        self.automaticallyAdjustsScrollViewInsets = false
        dismissGesture.direction = direction == .horizontal ? .down : .left
    }
    
    @IBAction func didSwipeDown(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

extension IGStoryPreviewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //@Note:Story->ScrollView->NumberOfSnaps
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (stories?.count)!-storyIndex
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryPreviewCell.reuseIdentifier(), for: indexPath) as! IGStoryPreviewCell
        cell.storyHeaderView?.delegate = self
        
        //Start with handpicked story from Home.
        let story = stories?.stories?[indexPath.section+storyIndex]
        cell.storyHeaderView?.story = story
       

        for snapcount in 0..<((stories?.stories?[indexPath.section+storyIndex])!.snapsCount)!
        {
//            let snap = story?.snaps?[snapcount]

            let xOrigin:CGFloat = CGFloat(snapcount) * cell.scrollview.frame.size.width
            let imageView:UIImageView = UIImageView(frame: CGRect(x: xOrigin, y: 0, width: cell.scrollview.frame.size.width, height: cell.scrollview.frame.size.height))
            cell.scrollview.addSubview(imageView)
        }
        cell.scrollview.contentSize = CGSize(width: cell.scrollview.frame.size.width * CGFloat(((stories?.stories?[indexPath.section])!.snapsCount)!) , height: cell.scrollview.frame.size.height)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//
//        let currentSection = (self.collectionview.contentOffset.x / self.collectionview.frame.size.width)
//        let cell = self.collectionview!.cellForItem(at: IndexPath(item: 0, section: Int(currentSection))) as! IGStoryPreviewCell
//        if currentSection != 0
//        {
//            cell.nextSnap(maxContentSize: cell.scrollview.contentSize.width)
//        }
//    }
    //    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    //        print("Will diplay cell")
    //        let cell = cell as! IGStoryPreviewCell
    //        if indexPath.section == 0
    //        {
    //            cell.nextSnap(maxContentSize: cell.scrollview.frame.size.width * CGFloat(((stories?.stories?[0])!.snapsCount)!))
    //        }
    //    }

    
}

extension IGStoryPreviewController:StoryPreviewHeaderTapper {
    func didTapCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
