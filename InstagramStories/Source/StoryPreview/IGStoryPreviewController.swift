//
//  IGStoryPreviewController.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

final class IGStoryPreviewController: UIViewController {
    
    //MARK: - Private Vars
    private var _view: IGStoryPreviewView { return view as! IGStoryPreviewView }
    public let viewModel: IGStoryPreviewModel
    
    private(set) var executeOnce = false
    let ableToDelete: Bool
    
    //check whether device rotation is happening or not
    private(set) var isTransitioning = false
    
    #warning("Needs to refactor current cell and cell related stuff. when you start segregating the cell and view model. then automatically everything will be leveraged!")
    private var currentCell: IGStoryPreviewCell? {
        var cell: IGStoryPreviewCell?
        if let indexPath = viewModel.currentIndexPath {
            cell = _view.collectionView.cellForItem(at: indexPath) as? IGStoryPreviewCell
        }
        return cell
    }
    
    //MARK: - Overriden functions
    override func loadView() {
        super.loadView()
        view = IGStoryPreviewView()
        
        self._view.collectionView.delegate = self
        self._view.collectionView.dataSource = self
        
        // This should be handled for only currently logged in user story and not for all other user stories.
        if ableToDelete {
            _view.swipeUpGestureRecognizer.delegate = self
            _view.swipeUpGestureRecognizer.addTarget(self, action: #selector(showDeleteSnapActions))
        }
        
        ///Adding this gesture to dimiss the screen
        _view.swipeDownGestureRecognizer.delegate = self
        _view.swipeDownGestureRecognizer.addTarget(self, action: #selector(dismissScreen(_:)))
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModelObservers()
    }
    
    private func viewModelObservers() {       
        self.viewModel.moveStoryOnIndexPath.bind {
            if let indexPath = $0 {
                self._view.collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
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
            DispatchQueue.main.async { [weak self] in
                if let index = self?.viewModel.handPickedStoryIndex {
                    let indexPath = IndexPath(item: index, section: 0)
                    self?._view.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                    self?.viewModel.handPickedStoryIndex = 0
                    self?.executeOnce = true
                } else {
                    debugPrint("self become nil, so cannot access the hand picked story index")
                }
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
        _view.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    init(viewModel: IGStoryPreviewModel, ableToDelete: Bool = false) {
        self.viewModel = viewModel
        self.ableToDelete = ableToDelete
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    ///Showing an alert view where user can do delete, share, favourite and other options.
    @objc private func showDeleteSnapActions() {
        let alertController = UIAlertController(title: Bundle.main.displayName, message: "More...", preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteSnap()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.currentCell?.resumeEntireSnap()
        }
        alertController.addAction(delete)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true) { [weak self] in
            self?.currentCell?.pauseEntireSnap()
        }
    }
    
    private func deleteSnap() {
        if let indexPath = viewModel.currentIndexPath {
            let cell = _view.collectionView.cellForItem(at: indexPath) as! IGStoryPreviewCell
            cell.deleteSnap()
        }
    }
    
    @objc func dismissScreen(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- UICollectionViewDataSource
extension IGStoryPreviewController: UICollectionViewDataSource {
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

//MARK:- UICollectionViewDelegate
extension IGStoryPreviewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! IGStoryPreviewCell
        
        //Taking Previous(Visible) cell to store previous story
        let visibleCells = collectionView.visibleCells.sortedByPosition
        if !visibleCells.isEmpty {
            let visibleCell = visibleCells.first as! IGStoryPreviewCell
            visibleCell.viewModel.story.isCompletelyVisible = false
            visibleCell.pauseSnapProgressors(with: visibleCell.viewModel.story.lastPlayedSnapIndex)
            viewModel.story_copy = visibleCell.viewModel.story
        }
        
        //Prepare the setup for first time story launch
        if viewModel.story_copy == nil {
            cell.willDisplayCellForZerothIndex(with: cell.viewModel.story.lastPlayedSnapIndex, handpickedSnapIndex: viewModel.handPickedSnapIndex)
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
        let visibleCells = collectionView.visibleCells.sortedByPosition
        if !visibleCells.isEmpty {
            let visibleCell = visibleCells.first as! IGStoryPreviewCell
            if let indexPathOnCell = _view.collectionView.indexPath(for: visibleCell) {
                visibleCell.viewModel.story.isCompletelyVisible = true
                
                if visibleCell.viewModel.story == viewModel.story_copy {
                    viewModel.nStoryIndex = indexPathOnCell.item
                    if visibleCell.longPressGestureState == nil {
                        visibleCell.resumePreviousSnapProgress(with: visibleCell.viewModel.story.lastPlayedSnapIndex)
                    }
                    let snaps = visibleCell.viewModel.story.nonDeletedSnaps
                    let snapIndex = visibleCell.viewModel.story.lastPlayedSnapIndex
                    if snaps[snapIndex].kind == .video {
                        visibleCell.resumePlayer(with: snapIndex)
                    }
                    visibleCell.longPressGestureState = nil
                }else {
                    let cell = cell as! IGStoryPreviewCell
                    cell.stopPlayer()
                    visibleCell.startProgressors()
                }
                if indexPathOnCell.item == viewModel.nStoryIndex {
                    visibleCell.didEndDisplayingCell()
                }
            } else {
                fatalError("IndexPath is matched with IGStoryPreviewCell")
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let cell = _view.collectionView.visibleCells.first as! IGStoryPreviewCell
        cell.pauseSnapProgressors(with: cell.viewModel.story.lastPlayedSnapIndex)
        cell.pausePlayer(with: cell.viewModel.story.lastPlayedSnapIndex)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let visibleCells = _view.collectionView.visibleCells.sortedByPosition
        if !visibleCells.isEmpty {
            let firstIndexPath = _view.collectionView.indexPath(for: visibleCells.first!)
            let lastIndexPath = _view.collectionView.indexPath(for: visibleCells.last!)
            let numberOfItems = viewModel.numberOfItemsInSection(0) - 1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                if lastIndexPath?.item == 0 || firstIndexPath?.item == numberOfItems {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
}

//MARK:- UICollectionViewDelegateFlowLayout
extension IGStoryPreviewController: UICollectionViewDelegateFlowLayout {
    
    #warning("The below lengthy notes is it mandatory or self explanatory?")
    /* NOTE:*/
    /* During device rotation, invalidateLayout gets call to make cell width and height proper.
     * InvalidateLayout methods call this UICollectionViewDelegateFlowLayout method, and the scrollView content offset moves to (0, 0). Which is not the expected result.
     * To keep the contentOffset to that same position adding the below code which will execute after 0.1 second because need time for collectionView adjusts its width and height.
     * Adjusting preview snap progressors width to Holder view width because when animation finished in portrait orientation, when we switch to landscape orientation, we have to update the progress view width for preview snap progressors also.
     * Also, adjusting progress view width to updated frame width when the progress view animation is executing.
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let visibleCells = collectionView.visibleCells.sortedByPosition
        if isTransitioning && !visibleCells.isEmpty {
            let visibleCell = visibleCells.first as! IGStoryPreviewCell
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
                if let progressIndicatorView = visibleCell.getProgressIndicatorView(with: visibleCell.viewModel.snapIndex),
                   let pv = visibleCell.getProgressView(with: visibleCell.viewModel.snapIndex) {
                    visibleCell.scrollView.setContentOffset(CGPoint(x: CGFloat(visibleCell.viewModel.snapIndex) * collectionView.frame.width, y: 0), animated: false)
                    visibleCell.adjustPreviousSnapProgressorsWidth(with: visibleCell.viewModel.snapIndex)
                    
                    if pv.state == .running {
                        pv.widthConstraint?.constant = progressIndicatorView.frame.width
                    }
                    self?.isTransitioning = false
                } else {
                    fatalError("ProgressIndicatorView is nil due to cell snapIndex is wrong")
                }
            }
        }
        
        var width: CGFloat!
        var height: CGFloat!
        if #available(iOS 11.0, *) {
            width = _view.collectionView.safeAreaLayoutGuide.layoutFrame.width
            height = _view.collectionView.safeAreaLayoutGuide.layoutFrame.height
        } else {
            width = _view.collectionView.frame.width
            height = _view.collectionView.frame.height
        }
        return CGSize(width: width, height: height)
    }
}

//MARK:- UIGestureRecognizerDelegate
extension IGStoryPreviewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
