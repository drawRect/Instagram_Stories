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
         let cv = UICollectionView.init(frame:
            CGRect(x: 0,y:0,
                   width: UIScreen.main.bounds.width,
                   height: UIScreen.main.bounds.height),
                    collectionViewLayout: flowLayout)
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
    init(layout: layoutType = .cubic, stories: IGStories, handPickedStoryIndex: Int) {
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
    private func loadUIElements() {
        view.backgroundColor = .white
        view.addSubview(snapsCollectionView)
    }
    private func installLayoutConstraints() {
        //Setting constraints for snapsCollectionview
        NSLayoutConstraint.activate([snapsCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
        snapsCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
        snapsCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
        snapsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
    
}

//MARK: - Extension|CollectionViewProtocols
extension IGStoryPreviewController:CollectionViewProtocols {
    
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
        guard let cell = cell as? IGStoryPreviewCell else {return}
        if story_copy == nil {
            cell.willDisplayAtZerothIndex()
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
        if indexPath.item == nStoryIndex {
            cell.didEndDisplayingCell()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2, execute: {
                self._scrollViewDidEndDecelerating()
            })
        }
    }
    
    //MARK: - UIScrollView Delegates
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.x
        guard let visibleCell = snapsCollectionView.visibleCells.first as? IGStoryPreviewCell else{return}
        story_copy = stories.stories?[nStoryIndex+handPickedStoryIndex]
        visibleCell.willBeginDragging(with: visibleCell.snapIndex)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = snapsCollectionView.frame.width;
        let currentPage = snapsCollectionView.contentOffset.x / pageWidth;
        if lastContentOffset! == scrollView.contentOffset.x && (currentPage == 0 || currentPage+CGFloat(handPickedStoryIndex) == CGFloat((stories.stories?.count)!)-1) {
            self.dismiss(animated: true, completion: nil)
            return
        }
    }
    private func _scrollViewDidEndDecelerating() {
        let cell = self.snapsCollectionView.visibleCells.first as? IGStoryPreviewCell
        if let story_copy = story_copy {
            if story_copy == cell?.story{
                if let index = stories.stories?.index(of: story_copy) {
                    cell?.startPlayBlindly(with: cell?.story?.lastPlayedSnapIndex ?? 0)
                    nStoryIndex = index - handPickedStoryIndex
                }
            }else {
                DispatchQueue.main.async{
                    cell?.isCompletelyVisible = true
                    cell?.startProgressors()
                }
            }
        }
    }
}

//MARK: - Extension|StoryPreviewProtocol
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
            }else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    func didTapCloseButton() {
        self.dismiss(animated: true, completion:nil)
    }
}
