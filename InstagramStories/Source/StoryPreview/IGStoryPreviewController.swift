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
    private var _view: IGStoryPreviewView { return view as! IGStoryPreviewView }
    public let viewModel: IGStoryPreviewModel
    
    private(set) var layoutType: IGLayoutType
    private(set) var executeOnce = false
    var isDeleteSnap: Bool = false
    
    //check whether device rotation is happening or not
    private(set) var isTransitioning = false
    
    private var currentCell: IGStoryPreviewCell? {
        guard let indexPath = viewModel.currentIndexPath else {
            debugPrint("Current IndexPath is nil")
            return nil
        }
        return self._view.snapsCollectionView.cellForItem(at: indexPath) as? IGStoryPreviewCell
    }
   
    
    //MARK: - Overriden functions
    override func loadView() {
        super.loadView()
        view = IGStoryPreviewView(layoutType: self.layoutType, isDeleteSnap: isDeleteSnap)
        
        // This should be handled for only currently logged in user story and not for all other user stories.
        if isDeleteSnap {
            _view.swipeUpGestureRecognizer.delegate = self
            _view.swipeUpGestureRecognizer.addTarget(self, action: #selector(showDeleteSnapActions))
        }
        
        ///Adding this gesture to dimiss the screen
        _view.swipeDownGestureRecognizer.delegate = self
        _view.swipeDownGestureRecognizer.addTarget(self, action: #selector(didSwipeDown(_:)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModelObservers()
    }
    
    private func viewModelObservers() {
        self.viewModel.isDeleteSnap.bind {
            if $0 == true {
                
            }
        }
        self.viewModel.moveStoryOnIndexPath.bind {
            if let indexPath = $0 {
                self._view.snapsCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            }
        }
        self.viewModel.dismissScreen.bind {
            if let dismis = $0 {
                self.dismiss(animated: dismis, completion: nil)
            }
        }
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
                let indexPath = IndexPath(item: self.viewModel.handPickedStoryIndex, section: 0)
                self._view.snapsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                self.viewModel.handPickedStoryIndex = 0
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
    #warning("can we move handPickedStoryIndex variable in IGStories Model or ViewModel")
    #warning("can we move handPickedSnapIndex variable in IGStory Model or ViewModel")
    //because Controller should not aware of the Model and model related things directly.
    init(layout: IGLayoutType = .cubic, viewModel: IGStoryPreviewModel, isDeleteSnap: Bool = false) {
        self.layoutType = layout
        self.viewModel = viewModel
        self.isDeleteSnap = isDeleteSnap
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var prefersStatusBarHidden: Bool { return true }
    
    @objc private func showDeleteSnapActions() {
        self.present(_view.actionSheet, animated: true) { [weak self] in
            self?.currentCell?.pauseEntireSnap()
        }
    }
    private func deleteSnap() {
        guard let indexPath = viewModel.currentIndexPath else {
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
        viewModel.numberOfItemsInSection(section)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.register(IGStoryPreviewCell.self, indexPath: indexPath)
        let story = viewModel.cellForItemAtIndexPath(indexPath)
        cell.viewModel.story = story
        cell.updateHeaderView()
        cell.delegate = viewModel
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
            vCell.viewModel.story?.isCompletelyVisible = false
            vCell.pauseSnapProgressors(with: (vCell.viewModel.story?.lastPlayedSnapIndex)!)
            viewModel.story_copy = vCell.viewModel.story
        }
        //Prepare the setup for first time story launch
        if viewModel.story_copy == nil {
            cell.willDisplayCellForZerothIndex(with: cell.viewModel.story?.lastPlayedSnapIndex ?? 0, handpickedSnapIndex: viewModel.handPickedSnapIndex)
            return
        }
        if indexPath.item == viewModel.nStoryIndex {
            let s = viewModel.stories[viewModel.nStoryIndex+viewModel.handPickedStoryIndex]
            cell.willDisplayCell(with: s.lastPlayedSnapIndex)
        }
        /// Setting to 0, otherwise for next story snaps, it will consider the same previous story's handPickedSnapIndex. It will create issue in starting the snap progressors.
        viewModel.handPickedSnapIndex = 0
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
        let visibleCell = visibleCells.first as? IGStoryPreviewCell
        guard let vCell = visibleCell else {return}
        guard let vCellIndexPath = _view.snapsCollectionView.indexPath(for: vCell) else {
            return
        }
        vCell.viewModel.story?.isCompletelyVisible = true
        
        if vCell.viewModel.story == viewModel.story_copy {
            viewModel.nStoryIndex = vCellIndexPath.item
            if vCell.longPressGestureState == nil {
                vCell.resumePreviousSnapProgress(with: (vCell.viewModel.story?.lastPlayedSnapIndex)!)
            }
            if (vCell.viewModel.story?.nonDeletedSnaps[vCell.viewModel.story?.lastPlayedSnapIndex ?? 0])?.kind == .video {
                vCell.resumePlayer(with: vCell.viewModel.story?.lastPlayedSnapIndex ?? 0)
            }
            vCell.longPressGestureState = nil
        }else {
            if let cell = cell as? IGStoryPreviewCell {
                cell.stopPlayer()
            }
            vCell.startProgressors()
        }
        if vCellIndexPath.item == viewModel.nStoryIndex {
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
        let cell = _view.snapsCollectionView.visibleCells.first as! IGStoryPreviewCell
        cell.pauseSnapProgressors(with: cell.viewModel.story.lastPlayedSnapIndex)
        cell.pausePlayer(with: cell.viewModel.story.lastPlayedSnapIndex)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let sortedVisibleCells = _view.snapsCollectionView.visibleCells.sortedArrayByPosition()
        let firstIndexPath = _view.snapsCollectionView.indexPath(for: sortedVisibleCells.first!)
        let lastIndexPath = _view.snapsCollectionView.indexPath(for: sortedVisibleCells.last!)
        let numberOfItems = viewModel.numberOfItemsInSection(0) - 1
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
            if lastIndexPath?.item == 0 || firstIndexPath?.item == numberOfItems {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
