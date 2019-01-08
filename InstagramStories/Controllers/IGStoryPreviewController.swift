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
    private var _view: IGStoryPreviewView {return view as! IGStoryPreviewView}
    private var viewModel: IGStoryPreviewModel?
    
    private(set) var stories: IGStories
    /** This index will tell you which Story, user has picked*/
    private(set) var handPickedStoryIndex: Int //starts with(i)
    /** This index will help you simply iterate the story one by one*/
    private var nStoryIndex: Int = 0 //iteration(i+1)
    private var story_copy: IGStory?
    private(set) var layoutType: layoutType
    
    private let dismissGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .down
        return gesture
    }()

    //MARK: - Overriden functions
    override func loadView() {
        super.loadView()
        view = IGStoryPreviewView.init(layoutType: self.layoutType)
        viewModel = IGStoryPreviewModel.init(self.stories, self.handPickedStoryIndex)
        _view.snapsCollectionView.delegate = self
        _view.snapsCollectionView.dataSource = self
        dismissGesture.addTarget(self, action: #selector(didSwipeDown(_:)))
        _view.snapsCollectionView.addGestureRecognizer(dismissGesture)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
}

//MARK:- Extension|UICollectionViewDataSource
extension IGStoryPreviewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = viewModel else {return 0}
        return model.numberOfItemsInSection(section)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryPreviewCell.reuseIdentifier(), for: indexPath) as? IGStoryPreviewCell else{return UICollectionViewCell()}
        let story = viewModel?.cellForItemAtIndexPath(indexPath)
        cell.story = story
        cell.delegate = self
        nStoryIndex = indexPath.item
        return cell
    }
}

//MARK:- Extension|UICollectionViewDelegate
extension IGStoryPreviewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? IGStoryPreviewCell else {return}
        
        //Taking Previous(Visible) cell to store previous story
        let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
        let visibleCell = visibleCells.first as? IGStoryPreviewCell
        if let vCell = visibleCell {
            debugPrint(#function + "Visible Cell" + "\(visibleCell!.story!.user!.name.debugDescription)")
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
            let s = stories.stories?[nStoryIndex+handPickedStoryIndex]
            cell.willDisplayCell(with: (s?.lastPlayedSnapIndex)!)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
        let visibleCell = visibleCells.first as? IGStoryPreviewCell
        guard let vCell = visibleCell else {return}
        guard let vCellIndexPath = _view.snapsCollectionView.indexPath(for: vCell) else {return}
        vCell.story?.isCompletelyVisible = true
        if vCell.story == story_copy {
            nStoryIndex = vCellIndexPath.item
            vCell.resumePreviousSnapProgress(with: (vCell.story?.lastPlayedSnapIndex)!)
        }else {
            vCell.startProgressors()
        }
        if vCellIndexPath.item == nStoryIndex {
            vCell.didEndDisplayingCell()
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
        guard let vCell = _view.snapsCollectionView.visibleCells.first as? IGStoryPreviewCell else {return}
        vCell.pauseSnapProgressors(with: (vCell.story?.lastPlayedSnapIndex)!)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let sortedVCells = _view.snapsCollectionView.visibleCells.sortedArrayByPosition()
        guard let f_Cell = sortedVCells.first as? IGStoryPreviewCell else {return}
        guard let l_Cell = sortedVCells.last as? IGStoryPreviewCell else {return}
        let f_IndexPath = _view.snapsCollectionView.indexPath(for: f_Cell)
        let l_IndexPath = _view.snapsCollectionView.indexPath(for: l_Cell)
        let numberOfItems = collectionView(_view.snapsCollectionView, numberOfItemsInSection: 0)-1
        if l_IndexPath?.item == 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                self.dismiss(animated: true, completion: nil)
            }
        }else if f_IndexPath?.item == numberOfItems {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

//MARK:- StoryPreview Protocol implementation
extension IGStoryPreviewController: StoryPreviewProtocol {
    func didCompletePreview() {
        let n = handPickedStoryIndex+nStoryIndex+1
        if let count = stories.count {
            if n < count {
                //Move to next story
                story_copy = stories.stories?[nStoryIndex+handPickedStoryIndex]
                nStoryIndex = nStoryIndex + 1
                let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
                _view.snapsCollectionView.scrollToItem(at: nIndexPath, at: .right, animated: true)
                /**@Note:
                 Here we are navigating to next snap explictly, So we need to handle the isCompletelyVisible. With help of this Bool variable we are requesting snap. Otherwise cell wont get Image as well as the Progress move :P
                 */
            }else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    func moveToPreviousStory() {
        let n = handPickedStoryIndex+nStoryIndex+1
        if let count = stories.count {
            if n < count || n > 0 {
                //Move to next story
                story_copy = stories.stories?[nStoryIndex+handPickedStoryIndex]
                nStoryIndex = nStoryIndex - 1
                let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
                _view.snapsCollectionView.scrollToItem(at: nIndexPath, at: .left, animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    func didTapCloseButton() {
        self.dismiss(animated: true, completion:nil)
    }
}

/*//MARK:- IGPlayerObserver Protocol implementation
extension IGStoryPreviewController: IGPlayerObserver {
    func didCompletePlay(){
        //        let nextIndex = snapIndex+1
        //let nextSnap = stories[nextIndex]
        //videoURL ===> nextSnap.videoURL
//        let videoURL = "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
//        let playerResource = VideoResource.init(filePath: videoURL)
//        player.play(with: playerResource)
    }
    func didTrack(progress:Float){}
}*/
