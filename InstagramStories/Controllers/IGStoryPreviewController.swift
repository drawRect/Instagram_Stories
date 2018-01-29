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
    var animator: LayoutAttributesAnimator {
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
final class IGStoryPreviewController: UIViewController,UIGestureRecognizerDelegate {
    
    //MARK: - iVars
    private(set) var stories: IGStories
    /** This index will tell you which Story, user has picked*/
    private(set) var handPickedStoryIndex: Int //starts with(i)
    /** This index will help you simply iterate the story one by one*/
    private var nStoryIndex: Int = 0 //iteration(i+1)
    //public weak var storyPreviewHelperDelegate:pastStoryClearer?
    private(set) var layoutType: layoutType
    /**Layout Animate options(ie.choose which kinda animation you want!)*/
    private(set) lazy var layoutAnimator: (LayoutAttributesAnimator, Bool, Int, Int) = (layoutType.animator, true, 1, 1)
    private var story_copy: IGStory?
    private var lastContentOffset: CGFloat?
    private let dismissGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .down
        return gesture
    }()
     lazy var snapsCollectionView: UICollectionView! = {
        let flowLayout = AnimatedCollectionViewLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.animator = layoutAnimator.0
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        let cv = UICollectionView.init(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width,height:  UIScreen.main.bounds.height), collectionViewLayout: flowLayout)
        cv.backgroundColor = .black
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(IGStoryPreviewCell.self, forCellWithReuseIdentifier: IGStoryPreviewCell.reuseIdentifier())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.isPrefetchingEnabled = false
        dismissGesture.addTarget(self, action: #selector(didSwipeDown(_:)))
        cv.addGestureRecognizer(dismissGesture)
        cv.collectionViewLayout = flowLayout
        return cv
    }()
    
    //MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUIElements()
        installLayoutConstraints()
    }
    init(layout:layoutType = .cubic,stories: IGStories,handPickedStoryIndex: Int) {
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
    @objc func didSwipeDown(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Private functions
    private func loadUIElements(){
        view.backgroundColor = .white
        view.addSubview(snapsCollectionView)
    }
    private func installLayoutConstraints(){
        //Setting constraints for snapsCollectionview
        NSLayoutConstraint.activate([
            snapsCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            snapsCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            snapsCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            snapsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
}

//MARK:- Extension|UICollectionViewDataSource
extension IGStoryPreviewController:UICollectionViewDataSource {
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
}

//MARK:- Extension|UICollectionViewDelegate
extension IGStoryPreviewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? IGStoryPreviewCell else {return}
        //Start: Taking Previous(Visible) cell to stop progressors
        let visibleCell = collectionView.visibleCells.first as? IGStoryPreviewCell
        if let cell = visibleCell {
            story_copy = cell.story
            cell.stopPreviousProgressors(with: cell.story?.lastPlayedSnapIndex ?? 0)
        }
        //End:Prepare the setup for first time story launch
        if story_copy == nil {
            cell.isCompletelyVisible = true
            cell.willDisplayCell(with: cell.story?.lastPlayedSnapIndex ?? 0)
            return
        }
        if indexPath.item == nStoryIndex {
            let s = stories.stories?[nStoryIndex+handPickedStoryIndex]
            if let lastPlayedSnapIndex = s?.lastPlayedSnapIndex {
                cell.willDisplayCell(with: lastPlayedSnapIndex)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let visibleCell = self.snapsCollectionView.visibleCells.first
        guard let cell = visibleCell as? IGStoryPreviewCell else {return}
        guard let indexPath = self.snapsCollectionView.indexPath(for: cell) else {return}
        
        cell.isCompletelyVisible = true
        cell.story == story_copy ? cell.resumePreviousSnapProgress(with: (cell.story?.lastPlayedSnapIndex)!) : cell.startProgressors()
        if indexPath.item == nStoryIndex {
            cell.didEndDisplayingCell()
        }
    }
}

//MARK:- Extension|UICollectionViewDelegateFlowLayout
extension IGStoryPreviewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}

//MARK:- Extension|UIScrollViewDelegate<CollectionView>
extension IGStoryPreviewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: snapsCollectionView)
        guard let visibleCell = snapsCollectionView.visibleCells.first as? IGStoryPreviewCell else {return}
        let indexPath = snapsCollectionView.indexPath(for: visibleCell)
        if translation.x >= 0 {
            //Scrolling left side
            if indexPath?.item == 0 {
                visibleCell.stopPreviousProgressors(with: visibleCell.story?.lastPlayedSnapIndex ?? 0)
            }else if indexPath?.item == collectionView(snapsCollectionView, numberOfItemsInSection: 0) {
                visibleCell.stopPreviousProgressors(with: visibleCell.story?.lastPlayedSnapIndex ?? 0)
            }
        } else {
            //Scrolling right side
            let numberOfItems = collectionView(snapsCollectionView, numberOfItemsInSection: 0)-1
            if indexPath?.item == numberOfItems {
                story_copy = visibleCell.story //Need to check this otherwise while scrolling to last cell, didEndDragging method will automatically dismiss the cell.
                visibleCell.stopPreviousProgressors(with: visibleCell.story?.lastPlayedSnapIndex ?? 0)
            }
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let visibleCell = snapsCollectionView.visibleCells.first as? IGStoryPreviewCell else {return}
        let indexPath = snapsCollectionView.indexPath(for: visibleCell)
        if indexPath?.item == 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                self.dismiss(animated: true, completion: nil)
            }
        }else if indexPath?.item == collectionView(snapsCollectionView, numberOfItemsInSection: 0)-1 && visibleCell.story == story_copy {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

//MARK:- StoryPreview Protocol implementation
extension IGStoryPreviewController:StoryPreviewProtocol {
    func didCompletePreview() {
        let n = handPickedStoryIndex+nStoryIndex+1
        if let count = stories.count {
            if n < count {
                //Move to next story
                story_copy = stories.stories?[nStoryIndex+handPickedStoryIndex]
                nStoryIndex = nStoryIndex + 1
                let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
                snapsCollectionView.scrollToItem(at: nIndexPath, at: .right, animated: true)
                /**@Note:
                 Here we are navigating to next snap explictly, So we need to handle the isCompletelyVisible. With help of this Bool variable we are requesting snap. Otherwise cell wont get Image as well as the Progress move :P
                 */
            }else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    func didTapCloseButton() {
        self.dismiss(animated: true, completion:nil)
    }
}
