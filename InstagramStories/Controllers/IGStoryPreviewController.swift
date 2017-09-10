//
//  IGStoryPreviewController.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout

struct StoryConstants {
    static let snapTime:Double = 1.0
}

class IGStoryPreviewController: UIViewController {

    public var stories:IGStories?
    public var storiesIndex:Int = 0
    public var storyIndex:Int = 0
    private var snapTimer:Timer?
    
    override var prefersStatusBarHidden: Bool { return true }
    var direction: UICollectionViewScrollDirection = .horizontal
    var animator: (LayoutAttributesAnimator, Bool, Int, Int) = (CubeAttributesAnimator(), true, 1, 1)

    @IBOutlet var dismissGesture: UISwipeGestureRecognizer!
    @IBOutlet weak var collectionview: UICollectionView! {
        didSet {
            collectionview.delegate = self
            collectionview.dataSource = self
            let storyNib = UINib.init(nibName: IGStoryPreviewCell.reuseIdentifier(), bundle: nil)
            collectionview.register(storyNib, forCellWithReuseIdentifier: IGStoryPreviewCell.reuseIdentifier())
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
        
//        snapTimer = Timer.scheduledTimer(timeInterval: StoryConstants.snapTime, target: self, selector: #selector(IGStoryPreviewController.didMoveNextSnap), userInfo: nil, repeats: true)
    }
    
    //MARK: - Selectors
    func didMoveNextSnap(){
        guard let count = stories?.count else {
            return
        }
        storiesIndex = storiesIndex+1
        if storiesIndex == count-1 {
            snapTimer?.invalidate()
            return
        }
        if storiesIndex<count{
            let indexPath = IndexPath.init(row: storiesIndex, section: 0)
            collectionview.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    //MARK: -
    deinit {
        snapTimer?.invalidate()
    }
    
    @IBAction func didSwipeDown(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

extension IGStoryPreviewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return (stories?.count)!
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Start with handpicked story from Home.
       // return (stories?.count)!-storyIndex
        
        //return ((stories?.stories?[section])!.snapsCount)!
        return 1

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryPreviewCell.reuseIdentifier(), for: indexPath) as! IGStoryPreviewCell
        cell.storyHeaderView?.delegate = self
        //Start with handpicked story from Home.
        let story = stories?.stories?[indexPath.section+storyIndex]
        cell.storyHeaderView?.story = story
        cell.storyHeaderView?.generateSnappers()
        cell.storyHeaderView?.snaperImageView.RK_setImage(urlString: story?.user?.picture ?? "")
        
        for snapcount in 0..<((stories?.stories?[indexPath.section])!.snapsCount)!
        {
            let snap = story?.snaps?[snapcount]
            let xOrigin:CGFloat = CGFloat(snapcount) * cell.scrollview.frame.size.width
            let imageView:UIImageView = UIImageView(frame: CGRect(x: xOrigin, y: 0, width: cell.scrollview.frame.size.width, height: cell.scrollview.frame.size.height))
            imageView.RK_setImage(urlString: snap?.mediaURL ?? "",imageStyle: .squared)
            cell.scrollview.addSubview(imageView)
        }
        cell.scrollview.contentSize = CGSize(width: cell.scrollview.frame.size.width * CGFloat(((stories?.stories?[indexPath.section])!.snapsCount)!) , height: cell.scrollview.frame.size.height)
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
