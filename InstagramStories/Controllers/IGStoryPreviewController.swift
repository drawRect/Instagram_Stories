//
//  IGStoryPreviewController.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout

public enum layoutType {
    case crossFade,cubic,linearCard,page,parallax,rotateInOut,snapIn,zoomInOut
    var animator:LayoutAttributesAnimator {
        switch self {
        case .crossFade:return CrossFadeAttributesAnimator()
        case .cubic:return CubeAttributesAnimator()
        case .linearCard:return LinearCardAttributesAnimator()
        case .page:return PageAttributesAnimator()
        case .parallax:return ParallaxAttributesAnimator()
        case .rotateInOut:return RotateInOutAttributesAnimator()
        case .snapIn:return SnapInAttributesAnimator()
        case .zoomInOut:return ZoomInOutAttributesAnimator()
        }
    }
}

/**Road-Map: Story(CollectionView)->Cell(ScrollView(nImageViews:Snaps))
 If Story.Starts -> Snap.Index(Captured|StartsWith.0)
 While Snap.done->Next.snap(continues)->done
 then Story Completed
 */
class IGStoryPreviewController: UIViewController {
    
    //MARK: - iVars
    public var stories:IGStories?
    /** This index will tell you which Story, user has picked*/
    public var handPickedStoryIndex:Int = 0 //starts with(i)
    /** This index will help you simply iterate the story one by one*/
    fileprivate var nStoryIndex:Int = 0 //iteration(i+1)
    //public weak var storyPreviewHelperDelegate:pastStoryClearer?
    private var layoutType:layoutType = .cubic
    
    /**Layout Animate options(ie.choose which kinda animation you want!)*/
    private lazy var layoutAnimator: (LayoutAttributesAnimator, Bool, Int, Int) = (layoutType.animator, true, 1, 1)
    
    @IBOutlet private var dismissGesture: UISwipeGestureRecognizer! {
        didSet { dismissGesture.direction = .down }
    }
    
    @IBOutlet private weak var collectionview: UICollectionView! {
        didSet {
            collectionview.delegate = self
            collectionview.dataSource = self
            collectionview.register(IGStoryPreviewCell.nib(), forCellWithReuseIdentifier: IGStoryPreviewCell.reuseIdentifier())
            collectionview?.isPagingEnabled = true
            collectionview.isPrefetchingEnabled = false
            if let layout = collectionview?.collectionViewLayout as? AnimatedCollectionViewLayout {
                layout.scrollDirection = .horizontal
                layout.animator = layoutAnimator.0
            }
        }
    }
    
    //MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    convenience init(kindOfLayout:layoutType = .cubic) {
        self.init()
        layoutType = kindOfLayout
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    //MARK: - Selectors
    @IBAction func didSwipeDown(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension IGStoryPreviewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = stories?.count {
            return count-handPickedStoryIndex
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryPreviewCell.reuseIdentifier(), for: indexPath) as? IGStoryPreviewCell else{return UICollectionViewCell()}
        cell.storyHeaderView?.delegate = self
        let counted = handPickedStoryIndex+indexPath.item
        if let count = stories?.count {
            if counted < count {
                let story = stories?.stories?[counted]
                cell.story = story
                cell.delegate = self
            }else {
                fatalError("Stories Index mis-matched :(")
            }
        }
        
        nStoryIndex = indexPath.item
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? IGStoryPreviewCell
        cell?.storyHeaderView?.generateSnappers()
        cell?.snapIndex = 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        collectionView.isScrollEnabled = true
        let cell = cell as? IGStoryPreviewCell
        cell?.storyHeaderView?.cancelTimers(snapIndex: (cell?.snapIndex)!)
    }
}

extension IGStoryPreviewController:StoryPreviewHeaderTapper {
    func didTapCloseButton() {
        self.dismiss(animated: true, completion:nil)
    }
}
extension IGStoryPreviewController:StoryPreviewProtocol {
    func didCompletePreview() {
        let n = handPickedStoryIndex+nStoryIndex+1
        if let count = stories?.count {
            if n < count {
                //Move to next story
                nStoryIndex = nStoryIndex + 1
                let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
                collectionview.scrollToItem(at: nIndexPath, at: .right, animated: true)
            }else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
