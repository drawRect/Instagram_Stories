//
//  IGStoryPreviewController.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

enum FlowLayoutType {
    case cubic
}

extension FlowLayoutType {
    var animator: LayoutAttributesAnimator {
        switch self {
        case .cubic: return CubeAttributesAnimator(perspective: -1/100, totalAngle: .pi/12)
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
    private var storyPreview: IGStoryPreviewView {return view as! IGStoryPreviewView}
    private let viewModel: IGStoryPreviewModel
    
    private(set) var stories: IGStories
    /** This index will tell you which Story, user has picked*/
    private(set) var handPickedStoryIndex: Int //starts with(i)
    /** This index will help you simply iterate the story one by one*/
    private var nStoryIndex: Int = 0 //iteration(i+1)
    private var story_copy: IGStory?
    private(set) var layoutType: FlowLayoutType
    
    private let dismissGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .down
        return gesture
    }()
    
    //MARK: - Overriden functions
    override func loadView() {
        super.loadView()
        view = IGStoryPreviewView(layoutType: layoutType)
        storyPreview.snapsCollectionView.delegate = self
        storyPreview.snapsCollectionView.dataSource = self
        storyPreview.snapsCollectionView.decelerationRate = .fast
        dismissGesture.addTarget(self, action: #selector(didSwipeDown(_:)))
        storyPreview.snapsCollectionView.addGestureRecognizer(dismissGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    init(layout:FlowLayoutType = .cubic,stories: IGStories,handPickedStoryIndex: Int) {
        self.layoutType = layout
        self.stories = stories
        self.handPickedStoryIndex = handPickedStoryIndex
        viewModel = IGStoryPreviewModel(stories, handPickedStoryIndex)
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
}

//MARK:- Extension|UICollectionViewDataSource
extension IGStoryPreviewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        guard let model = viewModel else {return 0}
        return viewModel.numberOfItemsInSection(section)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: IGStoryPreviewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryPreviewCell.reuseIdentifier, for: indexPath) as? IGStoryPreviewCell else {
//            fatalError()
//        }
        let story = viewModel.cellForItemAtIndexPath(indexPath)
        cell.story = story
        cell.delegate = self
        nStoryIndex = indexPath.item
        return cell
    }
}

//MARK:- Extension|UICollectionViewDelegate
extension IGStoryPreviewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! IGStoryPreviewCell
        
        //Taking Previous(Visible) cell to store previous story
        let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
        let visibleCell = visibleCells.first as? IGStoryPreviewCell
        if let vCell = visibleCell {
            vCell.story?.isCompletelyVisible = false
            vCell.pauseSnapProgressors(with: (vCell.story?.lastPlayedSnapIndex)!)
            story_copy = vCell.story
        }
        
        //Prepare the setup for first time story launch
        if story_copy == nil {
            cell.willDisplayCellForZerothIndex(with: cell.story?.lastPlayedSnapIndex ?? 0)
            return
        }
        if indexPath.item == nStoryIndex {
            let s = stories.stories[nStoryIndex+handPickedStoryIndex]
            cell.willDisplayCell(with: s.lastPlayedSnapIndex)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
        let visibleCell = visibleCells.first as! IGStoryPreviewCell
        guard let vCellIndexPath = storyPreview.snapsCollectionView.indexPath(for: visibleCell) else {
            return
        }
        visibleCell.story?.isCompletelyVisible = true
        if visibleCell.story == story_copy {
            nStoryIndex = vCellIndexPath.item
            visibleCell.resumePreviousSnapProgress(with: (visibleCell.story?.lastPlayedSnapIndex)!)
            if (visibleCell.story?.snaps[visibleCell.story?.lastPlayedSnapIndex ?? 0])?.kind == .video {
                visibleCell.resumePlayer(with: visibleCell.story?.lastPlayedSnapIndex ?? 0)
            }
        }else {
            if let cell = cell as? IGStoryPreviewCell {
                cell.stopPlayer()
            }
            visibleCell.startProgressors()
        }
        if vCellIndexPath.item == nStoryIndex {
            visibleCell.didEndDisplayingCell()
        }
    }
}

//MARK:- Extension|UICollectionViewDelegateFlowLayout
extension IGStoryPreviewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: storyPreview.width, height: storyPreview.height)
    }
}

//MARK:- Extension|UIScrollViewDelegate<CollectionView>
extension IGStoryPreviewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let vCell = storyPreview.snapsCollectionView.visibleCells.first as? IGStoryPreviewCell else {return}
        vCell.pauseSnapProgressors(with: (vCell.story?.lastPlayedSnapIndex)!)
        vCell.pausePlayer(with: (vCell.story?.lastPlayedSnapIndex)!)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let sortedVisibleCells = storyPreview.snapsCollectionView.visibleCells.sortedArrayByPosition()
        guard let firstVisibleCell = sortedVisibleCells.first as? IGStoryPreviewCell else {return}
        guard let lastVisibleCell = sortedVisibleCells.last as? IGStoryPreviewCell else {return}
        let firstVisibleCellIndexPath = storyPreview.snapsCollectionView.indexPath(for: firstVisibleCell)
        let lastVisibleCellIndexPath = storyPreview.snapsCollectionView.indexPath(for: lastVisibleCell)
        let numberOfItems = collectionView(storyPreview.snapsCollectionView, numberOfItemsInSection: 0)-1
        if lastVisibleCellIndexPath!.isFirstRow || firstVisibleCellIndexPath?.item == numberOfItems {
            dismissAfterTwoSeconds()
        }
    }
    
    private func dismissAfterTwoSeconds() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK:- StoryPreview Protocol implementation
extension IGStoryPreviewController: StoryPreviewProtocol {
    func didCompletePreview() {
        let n = handPickedStoryIndex+nStoryIndex+1
        if n < stories.count {
            //Move to next story
            story_copy = stories.stories[nStoryIndex+handPickedStoryIndex]
            nStoryIndex = nStoryIndex + 1
            let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
            //_view.snapsCollectionView.layer.speed = 0;
            storyPreview.snapsCollectionView.scrollToItem(at: nIndexPath, at: .right, animated: true)
            /**@Note:
             Here we are navigating to next snap explictly, So we need to handle the isCompletelyVisible. With help of this Bool variable we are requesting snap. Otherwise cell wont get Image as well as the Progress move :P
             */
        }else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func moveToPreviousStory() {
        let n = handPickedStoryIndex+nStoryIndex+1
        if n <= stories.count && n > 1 {
            story_copy = stories.stories[nStoryIndex+handPickedStoryIndex]
            nStoryIndex = nStoryIndex - 1
            let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
            storyPreview.snapsCollectionView.scrollToItem(at: nIndexPath, at: .left, animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func didTapCloseButton() {
        self.dismiss(animated: true, completion:nil)
    }
}
