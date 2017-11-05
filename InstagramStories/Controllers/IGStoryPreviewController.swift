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
final class IGStoryPreviewController: UIViewController {
    
    //MARK: - iVars
    private(set) var stories:IGStories
    /** This index will tell you which Story, user has picked*/
    private(set) var handPickedStoryIndex:Int //starts with(i)
    /** This index will help you simply iterate the story one by one*/
    private var nStoryIndex:Int = 0 //iteration(i++)
    //public weak var storyPreviewHelperDelegate:pastStoryClearer?
    private(set) var layoutType:layoutType
    
    /**Layout Animate options(ie.choose which kinda animation you want!)*/
    private(set) lazy var layoutAnimator: (LayoutAttributesAnimator, Bool, Int, Int) = (layoutType.animator, true, 1, 1)
    
    @IBOutlet private var dismissGesture: UISwipeGestureRecognizer! {
        didSet { dismissGesture.direction = .down }
    }
    
    @IBOutlet private weak var snapsCollectionView: UICollectionView! {
        didSet {
            snapsCollectionView.delegate = self
            snapsCollectionView.dataSource = self
            snapsCollectionView.register(IGStoryPreviewCell.nib(), forCellWithReuseIdentifier: IGStoryPreviewCell.reuseIdentifier())
            snapsCollectionView?.isPagingEnabled = true
            snapsCollectionView.isPrefetchingEnabled = false
            if let layout = snapsCollectionView?.collectionViewLayout as? AnimatedCollectionViewLayout {
                layout.scrollDirection = .horizontal
                layout.animator = layoutAnimator.0
            }
        }
    }
    var tempStory:IGStory?
    
    //MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    init(layout:layoutType = .cubic,stories:IGStories,handPickedStoryIndex:Int) {
        self.layoutType = layout
        self.stories = stories
        self.handPickedStoryIndex = handPickedStoryIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    //MARK: - Selectors
    @IBAction func didSwipeDown(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension IGStoryPreviewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = stories.count {
            return count-handPickedStoryIndex
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryPreviewCell.reuseIdentifier(), for: indexPath) as? IGStoryPreviewCell else{return UICollectionViewCell()}
        let counted = handPickedStoryIndex+indexPath.item
        if let count = stories.count {
            if counted < count {
                let story = stories.stories?[counted]
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
        if let cell = cell as? IGStoryPreviewCell {
            if tempStory == nil {
                cell.displayingAtZerothStory()
            }else {
                guard let visibleCell = snapsCollectionView.visibleCells.first as? IGStoryPreviewCell else{return}
                tempStory?.lastPlayedSnapIndex = visibleCell.snapIndex
                cell.isCompletelyVisible = false
                cell.willDisplayCell()
            }
        }else {fatalError()}
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? IGStoryPreviewCell {
            cell.didEndDisplayingCell()
        }else {fatalError()}
    }
    
    //MARK: - UIScrollView Delegates
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let visibleCell = snapsCollectionView.visibleCells.first as? IGStoryPreviewCell else{return}
        tempStory = stories.stories?[nStoryIndex]
        tempStory?.lastPlayedSnapIndex = visibleCell.snapIndex
        visibleCell.willBeginDragging(with: tempStory?.lastPlayedSnapIndex ?? 0)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let tempStory = tempStory {
            if let index = stories.stories?.index(of: tempStory) {
                let story = stories.stories?[index+handPickedStoryIndex]
                guard let visibleCell = snapsCollectionView.visibleCells.first as? IGStoryPreviewCell else{return}
                if tempStory == story {
                    visibleCell.didEndDecelerating(with: visibleCell.snapIndex)
                }else {
                    let visibleCell = snapsCollectionView.visibleCells.first as! IGStoryPreviewCell
                    visibleCell.didEndDecelerating(with: tempStory.lastPlayedSnapIndex)
                }
            }
        }else {
            guard let visibleCell = snapsCollectionView.visibleCells.first as? IGStoryPreviewCell else{return}
            visibleCell.isCompletelyVisible = true
        }
    }
    //MARK: -
}

extension IGStoryPreviewController:StoryPreviewProtocol {
    func didCompletePreview() {
        let n = handPickedStoryIndex+nStoryIndex+1
        if let count = stories.count {
            if n < count {
                tempStory = stories.stories?[nStoryIndex]
                //Move to next story
                nStoryIndex = nStoryIndex + 1
                let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
                snapsCollectionView.scrollToItem(at: nIndexPath, at: .right, animated: true)
            }else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    func didTapCloseButton() {
        self.dismiss(animated: true, completion:nil)
    }
}
