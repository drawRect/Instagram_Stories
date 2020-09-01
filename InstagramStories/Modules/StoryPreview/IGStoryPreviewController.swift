//
//  IGStoryPreviewController.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

/**Road-Map: Story(CollectionView)->Cell(ScrollView(nImageViews:Snaps))
 If Story.Starts -> Snap.Index(Captured|StartsWith.0)
 While Snap.done->Next.snap(continues)->done
 then Story Completed
 */
final class IGStoryPreviewController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: - Private Vars
    private var _view: IGStoryPreviewView {return view as! IGStoryPreviewView}
    private var viewModel: IGStoryPreviewModel?
    
    private(set) var stories: [IGStory]
    /** This index will tell you which Story, user has picked*/
    private(set) var handPickedStoryIndex: Int //starts with(i)
    /** This index will tell you which Snap, user has picked*/
    private(set) var handPickedSnapIndex: Int //starts with(i)
    /** This index will help you simply iterate the story one by one*/
    
    private var nStoryIndex: Int = 0 //iteration(i+1)
    private var story_copy: IGStory?
    private(set) var layoutType: IGLayoutType
    private(set) var executeOnce = false
    
    //check whether device rotation is happening or not
    private(set) var isTransitioning = false
    private(set) var currentIndexPath: IndexPath?
    
    private let dismissGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .down
        return gesture
    }()
    private let showActionSheetGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .up
        return gesture
    }()
    private var currentCell: IGStoryPreviewCell? {
        guard let indexPath = self.currentIndexPath else {
            debugPrint("Current IndexPath is nil")
            return nil
        }
        return self._view.snapsCollectionView.cellForItem(at: indexPath) as? IGStoryPreviewCell
    }
    lazy private var actionSheetController: UIAlertController = {
        let alertController = UIAlertController(title: "Instagram Stories", message: "More Options", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteSnap()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.currentCell?.resumeEntireSnap()
        }
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        return alertController
    }()
    
    //MARK: - Overriden functions
    override func loadView() {
        super.loadView()
        view = IGStoryPreviewView.init(layoutType: self.layoutType)
        viewModel = IGStoryPreviewModel.init(self.stories, self.handPickedStoryIndex)
        _view.snapsCollectionView.decelerationRate = .fast
        dismissGesture.delegate = self
        dismissGesture.addTarget(self, action: #selector(didSwipeDown(_:)))
        _view.snapsCollectionView.addGestureRecognizer(dismissGesture)
        
        // This should be handled for only currently logged in user story and not for all other user stories.
        if(isDeleteSnapEnabled) {
            showActionSheetGesture.delegate = self
            showActionSheetGesture.addTarget(self, action: #selector(showActionSheet))
            _view.snapsCollectionView.addGestureRecognizer(showActionSheetGesture)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        if UIDevice.current.userInterfaceIdiom == .phone {
            IGAppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        }
        if !executeOnce {
            DispatchQueue.main.async {
                self._view.snapsCollectionView.delegate = self
                self._view.snapsCollectionView.dataSource = self
                let indexPath = IndexPath(item: self.handPickedStoryIndex, section: 0)
                self._view.snapsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                self.handPickedStoryIndex = 0
                self.executeOnce = true
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if UIDevice.current.userInterfaceIdiom == .phone {
            // Don't forget to reset when view is being removed
            IGAppUtility.lockOrientation(.all)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        isTransitioning = true
        _view.snapsCollectionView.collectionViewLayout.invalidateLayout()
    }
    init(layout:IGLayoutType = .cubic,stories: [IGStory],handPickedStoryIndex: Int, handPickedSnapIndex: Int = 0) {
        self.layoutType = layout
        self.stories = stories
        self.handPickedStoryIndex = handPickedStoryIndex
        self.handPickedSnapIndex = handPickedSnapIndex
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var prefersStatusBarHidden: Bool { return true }
    
    @objc private func showActionSheet() {
        self.present(actionSheetController, animated: true) { [weak self] in
            self?.currentCell?.pauseEntireSnap()
        }
    }
    private func deleteSnap() {
        guard let indexPath = currentIndexPath else {
            debugPrint("Current IndexPath is nil")
            return
        }
        let cell = _view.snapsCollectionView.cellForItem(at: indexPath) as? IGStoryPreviewCell
        cell?.deleteSnap()
    }
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryPreviewCell.reuseIdentifier, for: indexPath) as? IGStoryPreviewCell else {
            fatalError()
        }
        let story = viewModel?.cellForItemAtIndexPath(indexPath)
        cell.story = story
        cell.delegate = self
        currentIndexPath = indexPath
        nStoryIndex = indexPath.item
        return cell
    }
}

//MARK:- Extension|UICollectionViewDelegate
extension IGStoryPreviewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? IGStoryPreviewCell else {
            return
        }
        
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
            cell.willDisplayCellForZerothIndex(with: cell.story?.lastPlayedSnapIndex ?? 0, handpickedSnapIndex: handPickedSnapIndex)
            return
        }
        if indexPath.item == nStoryIndex {
            let s = stories[nStoryIndex+handPickedStoryIndex]
            cell.willDisplayCell(with: s.lastPlayedSnapIndex)
        }
        /// Setting to 0, otherwise for next story snaps, it will consider the same previous story's handPickedSnapIndex. It will create issue in starting the snap progressors.
        handPickedSnapIndex = 0
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
        let visibleCell = visibleCells.first as? IGStoryPreviewCell
        guard let vCell = visibleCell else {return}
        guard let vCellIndexPath = _view.snapsCollectionView.indexPath(for: vCell) else {
            return
        }
        vCell.story?.isCompletelyVisible = true
        
        if vCell.story == story_copy {
            nStoryIndex = vCellIndexPath.item
            if vCell.longPressGestureState == nil {
                vCell.resumePreviousSnapProgress(with: (vCell.story?.lastPlayedSnapIndex)!)
            }
            if (vCell.story?.snaps[vCell.story?.lastPlayedSnapIndex ?? 0])?.kind == .video {
                vCell.resumePlayer(with: vCell.story?.lastPlayedSnapIndex ?? 0)
            }
            vCell.longPressGestureState = nil
        }else {
            if let cell = cell as? IGStoryPreviewCell {
                cell.stopPlayer()
            }
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
        /* During device rotation, invalidateLayout gets call to make cell width and height proper.
         * InvalidateLayout methods call this UICollectionViewDelegateFlowLayout method, and the scrollView content offset moves to (0, 0). Which is not the expected result.
         * To keep the contentOffset to that same position adding the below code which will execute after 0.1 second because need time for collectionView adjusts its width and height.
         * Adjusting preview snap progressors width to Holder view width because when animation finished in portrait orientation, when we switch to landscape orientation, we have to update the progress view width for preview snap progressors also.
         * Also, adjusting progress view width to updated frame width when the progress view animation is executing.
         */
        if isTransitioning {
            let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
            let visibleCell = visibleCells.first as? IGStoryPreviewCell
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
                guard let strongSelf = self,
                    let vCell = visibleCell,
                    let progressIndicatorView = vCell.getProgressIndicatorView(with: vCell.snapIndex),
                    let pv = vCell.getProgressView(with: vCell.snapIndex) else {
                        fatalError("Visible cell or progressIndicatorView or progressView is nil")
                }
                vCell.scrollview.setContentOffset(CGPoint(x: CGFloat(vCell.snapIndex) * collectionView.frame.width, y: 0), animated: false)
                vCell.adjustPreviousSnapProgressorsWidth(with: vCell.snapIndex)
                
                if pv.state == .running {
                    pv.widthConstraint?.constant = progressIndicatorView.frame.width
                }
                strongSelf.isTransitioning = false
            }
        }
        if #available(iOS 11.0, *) {
            return CGSize(width: _view.snapsCollectionView.safeAreaLayoutGuide.layoutFrame.width, height: _view.snapsCollectionView.safeAreaLayoutGuide.layoutFrame.height)
        } else {
            return CGSize(width: _view.snapsCollectionView.frame.width, height: _view.snapsCollectionView.frame.height)
        }
    }
}

//MARK:- Extension|UIScrollViewDelegate<CollectionView>
extension IGStoryPreviewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let vCell = _view.snapsCollectionView.visibleCells.first as? IGStoryPreviewCell else {return}
        vCell.pauseSnapProgressors(with: (vCell.story?.lastPlayedSnapIndex)!)
        vCell.pausePlayer(with: (vCell.story?.lastPlayedSnapIndex)!)
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
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK:- StoryPreview Protocol implementation
extension IGStoryPreviewController: StoryPreviewProtocol {
    func didCompletePreview() {
        let n = handPickedStoryIndex+nStoryIndex+1
        if n < stories.count {
            //Move to next story
            story_copy = stories[nStoryIndex+handPickedStoryIndex]
            nStoryIndex = nStoryIndex + 1
            let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
            //_view.snapsCollectionView.layer.speed = 0;
            _view.snapsCollectionView.scrollToItem(at: nIndexPath, at: .right, animated: true)
            /**@Note:
             Here we are navigating to next snap explictly, So we need to handle the isCompletelyVisible. With help of this Bool variable we are requesting snap. Otherwise cell wont get Image as well as the Progress move :P
             */
        }else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func moveToPreviousStory() {
        //let n = handPickedStoryIndex+nStoryIndex+1
        let n = nStoryIndex+1
        if n <= stories.count && n > 1 {
            story_copy = stories[nStoryIndex+handPickedStoryIndex]
            nStoryIndex = nStoryIndex - 1
            let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
            _view.snapsCollectionView.scrollToItem(at: nIndexPath, at: .left, animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func didTapCloseButton() {
        self.dismiss(animated: true, completion:nil)
    }
}
