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
    
    var progressDelay:Double = 0.0
    var progressBarIndex:Int = 1
    var animateDelay:Double = 5.0
    
    var snapTimer: Timer?
    var headerview:IGStoryPreviewHeaderView?
    
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
    }
    
    @IBAction func didSwipeDown(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func nextSnap(maxContentSize:CGFloat, scrollview:UIScrollView, headerView:IGStoryPreviewHeaderView)
    {
        if (scrollview.contentOffset.x + self.view.frame.size.width) < maxContentSize
        {
            headerview = headerView
            print("HeaderView:\(headerView)")
            print("Progress bar index:\(self.progressBarIndex)")
            self.progressDelay = self.animateDelay/(self.animateDelay * self.animateDelay)
            DispatchQueue.main.asyncAfter(deadline: .now() + animateDelay) {
                scrollview.contentOffset.x += self.view.frame.size.width
                self.nextProgressView()
                self.nextSnap(maxContentSize: maxContentSize, scrollview: scrollview, headerView: headerView)
            }
        }
    }
    
    func runprogress()
    {
        headerview?.progressView(with: self.progressBarIndex, progress: self.progressDelay)
    }
    
    func nextProgressView()
    {
        self.snapTimer?.invalidate()
        self.progressBarIndex = self.progressBarIndex + 1
        self.snapTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.runprogress), userInfo: nil, repeats: true)
    }

}

extension IGStoryPreviewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("Will diplay cell")
        let cell = cell as! IGStoryPreviewCell
        if((snapTimer) != nil)
        {
            self.snapTimer?.invalidate()
        }
        self.collectionview.layer.removeAllAnimations()
        self.progressBarIndex = 1
        self.nextSnap(maxContentSize: cell.scrollview.frame.size.width * CGFloat(((stories?.stories?[indexPath.section+storyIndex])!.snapsCount)!), scrollview: cell.scrollview, headerView: cell.storyHeaderView!)
        snapTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(runprogress), userInfo: nil, repeats: true)
    }
    
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
        cell.storyHeaderView?.generateSnappers()
        cell.storyHeaderView?.snaperImageView.RK_setImage(urlString: story?.user?.picture ?? "", completion: {_,error in
            // leave it its a profile
        })
        
        for snapcount in 0..<((stories?.stories?[indexPath.section+storyIndex])!.snapsCount)!
        {
            let snap = story?.snaps?[snapcount]
            let xOrigin:CGFloat = CGFloat(snapcount) * cell.scrollview.frame.size.width
            let imageView:UIImageView = UIImageView(frame: CGRect(x: xOrigin, y: 0, width: cell.scrollview.frame.size.width, height: cell.scrollview.frame.size.height))
            imageView.RK_setImage(urlString: snap?.mediaURL ?? "",imageStyle: .squared,completion: {_,error in
                // start the timer
            })
            cell.scrollview.addSubview(imageView)
        }
        cell.scrollview.contentSize = CGSize(width: cell.scrollview.frame.size.width * CGFloat(((stories?.stories?[indexPath.section+storyIndex])!.snapsCount)!) , height: cell.scrollview.frame.size.height)
        cell.scrollview.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
}

extension IGStoryPreviewController:StoryPreviewHeaderTapper {
    func didTapCloseButton() {
        self.snapTimer?.invalidate()
        self.progressBarIndex = 1
        self.dismiss(animated: true, completion: nil)
    }
}
