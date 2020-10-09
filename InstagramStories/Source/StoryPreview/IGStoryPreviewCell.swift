//
//  IGStoryPreviewCell.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

protocol StoryPreviewProtocol: class {
    func didCompletePreview()
    func moveToPreviousStory()
    func didTapCloseButton()
}

enum ScreenDirection {
    case forward, backward
}

final class IGStoryPreviewCell: UICollectionViewCell {
    
    //MARK: - Delegate
    public weak var delegate: StoryPreviewProtocol? {
        didSet {
            storyHeaderView.delegate = self
        }
    }
    
    //MARK:- Private iVars
    private let storyHeaderView: IGStoryPreviewHeaderView = {
        let storyHeaderView = IGStoryPreviewHeaderView()
        storyHeaderView.translatesAutoresizingMaskIntoConstraints = false
        return storyHeaderView
    }()
    
    public let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = .black
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    var longPressGestureState: UILongPressGestureRecognizer.State?
    
    lazy var retryButton: IGRetryLoaderButton = {
        var retryButton = IGRetryLoaderButton()
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.delegate = self
        return retryButton
    }()
    
    //MARK:- Public iVars
    public var viewModel = IGStoryPreviewCellViewModel()
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollView.frame = bounds
        loadUIElements()
        installLayoutConstraints()
        viewModelObservers()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel.direction = .forward
        clearScrollViewGarbages()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func updateHeaderView() {
        storyHeaderView.story = viewModel.story
        let picture = viewModel.story.user.picture
        storyHeaderView.snaperImageView.setImage(url: picture)
    }
    
    private func viewModelObservers() {
        viewModel.enableScrollViewUserInteraction.bind { _ in
            self.scrollView.isUserInteractionEnabled = true
        }
        
        viewModel.startRequest.bind {
            if let url = $0 {
                self.startRequest(snapView: self.snapImageView, with: url)
            }
        }
        
        viewModel.startPlayer.bind {
            if let url = $0 {
                let videoView: IGPlayerView!
                if let playerView = self.getSnapView(index: self.viewModel.snapIndexWithTag) as? IGPlayerView {
                    videoView = playerView
                } else {
                    videoView = self.createVideoView()
                }
                self.startPlayer(videoView: videoView, with: url)
            }
        }
        
        viewModel.lastUpdated.bind {
            if let updated = $0 {
                self.storyHeaderView.lastUpdatedLabel.text = updated
            }
        }
        
        viewModel.startProgressor.bind { _ in
            self.startProgressors()
        }
        
        viewModel.showRetryButton.bind {
            if let urlString = $0 {
                self.showRetryButton(using: urlString)
            }
        }
        
        viewModel.playVideo.bind {
            if let videoResource = $0 {
                self.snapVideoView.play(with: videoResource)
            }
        }
        
        viewModel.stopAnimation.bind { _ in
            self.snapVideoView.stopAnimating()
        }
    }
    
    //MARK: - Private functions
    private func loadUIElements() {
        contentView.addSubview(scrollView)
        contentView.addSubview(storyHeaderView)
        
        addLongPressAndTapGestureRecognizer()
    }
    
    private func addLongPressAndTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSnap(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delegate = self
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.2
        longPressGestureRecognizer.delegate = self
        
        scrollView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    private func installLayoutConstraints() {
        installScrollViewConstraints()
        installStoryHeaderViewConstaints()
    }
    
    private func installScrollViewConstraints() {
        let left = scrollView.igLeftAnchor.constraint(equalTo: contentView.igLeftAnchor)
        let right = contentView.igRightAnchor.constraint(equalTo: scrollView.igRightAnchor)
        let top = scrollView.igTopAnchor.constraint(equalTo: contentView.igTopAnchor)
        let bottom = contentView.igBottomAnchor.constraint(equalTo: scrollView.igBottomAnchor)
        let width = scrollView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.0)
        let height = scrollView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1.0)
        NSLayoutConstraint.activate([left, right, top, bottom, width, height])
    }
    
    private func installStoryHeaderViewConstaints() {
        let left = storyHeaderView.igLeftAnchor.constraint(equalTo: contentView.igLeftAnchor)
        let right = contentView.igRightAnchor.constraint(equalTo: storyHeaderView.igRightAnchor)
        let top = storyHeaderView.igTopAnchor.constraint(equalTo: contentView.igTopAnchor)
        let height = storyHeaderView.heightAnchor.constraint(equalToConstant: 80)
        NSLayoutConstraint.activate([left, right, top, height])
    }
    
    private var snapViewXPos: CGFloat {
        var xPosition: CGFloat!
        if viewModel.snapIndex == 0 {
            xPosition = 0
        } else {
            xPosition = scrollView.subviews[viewModel.previousSnapIndex].frame.maxX
        }
        return xPosition
    }
    
    private var snapImageView: UIImageView {
        let snapView: UIImageView!
        if let imageView = self.getSnapView(index: self.viewModel.snapIndexWithTag) as? UIImageView {
            snapView = imageView
        } else {
            snapView = self.createSnapView()
        }
        return snapView
    }
    
    private var snapVideoView: IGPlayerView {
        let videoView: IGPlayerView!
        if let playerView = self.getSnapView(index: self.viewModel.snapIndexWithTag) as? IGPlayerView {
            videoView = playerView
        } else {
            videoView = self.createVideoView()
        }
        return videoView
    }
    
    private func createSnapView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tag = viewModel.snapIndexWithTag
        applySnapViewLayout(snapView: imageView)
        return imageView
    }
    
    private func getSnapView(index: Int) -> UIView? {
        let matched = scrollView.subviews.filter({$0.tag == index})
        return matched.first
    }
    
    private func createVideoView() -> IGPlayerView {
        let playerView = IGPlayerView()
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.tag = viewModel.snapIndexWithTag
        playerView.playerObserverDelegate = self
        applySnapViewLayout(snapView: playerView)
        return playerView
    }
    
    private func applySnapViewLayout(snapView: UIView) {
        /**
         Delete if there is any snapview/videoview already present in that frame location. Because of snap delete functionality, snapview/videoview can occupy different frames(created in 2nd position(frame), when 1st postion snap gets deleted, it will move to first position) which leads to weird issues.
         - If only snapViews are there, it will not create any issues.
         - But if story contains both image and video snaps, there will be a chance in same position both snapView and videoView gets created.
         - That's why we need to remove if any snap exists on the same position.
         */
        let matched = scrollView.subviews.filter({$0.tag == viewModel.snapIndexWithTag})
        matched.first?.removeFromSuperview()
        
        scrollView.addSubview(snapView)
        var leadingAnchor: NSLayoutXAxisAnchor!
        if viewModel.snapIndex == 0 {
            leadingAnchor = scrollView.leadingAnchor
        } else {
            leadingAnchor = scrollView.subviews[viewModel.previousSnapIndex].trailingAnchor
        }
        
        let leading = snapView.leadingAnchor.constraint(equalTo: leadingAnchor)
        let top = snapView.igTopAnchor.constraint(equalTo: scrollView.igTopAnchor)
        let width = snapView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        let height = snapView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        let bottom = scrollView.igBottomAnchor.constraint(equalTo: snapView.igBottomAnchor)
        
        /// Setting constraints for snap view.
        NSLayoutConstraint.activate([leading, top, width, height, bottom])
        #warning("is this condition really matters? because we are already doing something related to leading, please check the above one")
        if(viewModel.snapIndex != 0) {
            let constant = CGFloat(viewModel.snapIndex) * scrollView.width
            let leading = snapView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: constant)
            NSLayoutConstraint.activate([leading])
        }
    }
    
    private func startRequest(snapView: UIImageView, with url: String) {
        #warning("can you please move this setImage out of uiimageview. because once we moved out of it. we can call it from view model.")
        snapView.setImage(url: url, style: .squared) { result in
            self.viewModel.processImageResponse(urlString: url, result: result)
        }
    }
    
    private func startPlayer(videoView: IGPlayerView, with url: String) {
        if !scrollView.subviews.isEmpty {
            if viewModel.story?.isCompletelyVisible == true {
                videoView.startAnimating()
                viewModel.requestVideo(urlString: url)
            } else {
                debugPrint("view model story is not completely visible")
            }
        } else {
            debugPrint("scrollview subviews are empty")
        }
    }
    
    private func showRetryButton(using url: String) {
        retryButton.contentURL = url
        isUserInteractionEnabled = true
        snapImageView.addSubview(retryButton)
        
        let centerX = retryButton.igCenterXAnchor.constraint(equalTo: snapImageView.igCenterXAnchor)
        let centerY = retryButton.igCenterYAnchor.constraint(equalTo: snapImageView.igCenterYAnchor)
        
        NSLayoutConstraint.activate([centerX, centerY])
    }
    
    #warning("REFACTOR CONTINUE")
    @objc private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        longPressGestureState = sender.state
        if sender.state == .began {
            pauseEntireSnap()
        } else if sender.state == .ended {
            resumeEntireSnap()
        }
    }
    @objc private func didTapSnap(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(ofTouch: 0, in: self.scrollView)
        
        if let snapCount = viewModel.story?.snapsCount {
            var n = viewModel.snapIndex
            /*!
             * Based on the tap gesture(X) setting the direction to either forward or backward
             */
            if let snap = viewModel.story?.nonDeletedSnaps[n], snap.kind == .image, (getSnapView(index: viewModel.snapIndexWithTag) as? UIImageView)?.image == nil {
                //Remove retry button if tap forward or backward if it exists
                if let snapView = getSnapView(index: viewModel.snapIndexWithTag) as? UIImageView, snapView.subviews.contains(retryButton) {
                    snapView.removeRetryButton()
                }
                fillupLastPlayedSnap(n)
            }else {
                //Remove retry button if tap forward or backward if it exists
                if let videoView = getSnapView(index: n + viewModel.snapViewTag) as? IGPlayerView, videoView.subviews.contains(retryButton) {
                    videoView.removeRetryButton()
                }
                if (getSnapView(index: n + viewModel.snapViewTag) as? IGPlayerView)?.player?.timeControlStatus != .playing {
                    fillupLastPlayedSnap(n)
                }
            }
            if touchLocation.x < scrollView.contentOffset.x + (scrollView.frame.width/2) {
                viewModel.direction = .backward
                if viewModel.snapIndex >= 1 && viewModel.snapIndex <= snapCount {
                    clearLastPlayedSnaps(n)
                    stopSnapProgressors(with: n)
                    n -= 1
                    resetSnapProgressors(with: n)
                    willMoveToPreviousOrNextSnap(n: n)
                } else {
                    delegate?.moveToPreviousStory()
                }
            } else {
                if viewModel.snapIndex >= 0 && viewModel.snapIndex <= snapCount {
                    //Stopping the current running progressors
                    stopSnapProgressors(with: n)
                    viewModel.direction = .forward
                    n += 1
                    willMoveToPreviousOrNextSnap(n: n)
                }
            }
        }
    }
    @objc private func didEnterForeground() {
        if let snap = viewModel.story?.nonDeletedSnaps[viewModel.snapIndex] {
            if snap.kind == .video {
                if let videoView = getSnapView(index: viewModel.snapIndexWithTag) as? IGPlayerView {
                    startPlayer(videoView: videoView, with: snap.url)
                }
            }else {
                startSnapProgress(with: viewModel.snapIndex)
            }
        }
    }
    @objc private func didEnterBackground() {
        if let snap = viewModel.story?.nonDeletedSnaps[viewModel.snapIndex] {
            if snap.kind == .video {
                stopPlayer()
            }
        }
        resetSnapProgressors(with: viewModel.snapIndex)
    }
    private func willMoveToPreviousOrNextSnap(n: Int) {
        if let count = viewModel.story?.snapsCount {
            if n < count {
                //Move to next or previous snap based on index n
                let x = n.toFloat * frame.width
                let offset = CGPoint(x: x, y: 0)
                scrollView.setContentOffset(offset, animated: false)
                viewModel.story?.lastPlayedSnapIndex = n
                viewModel.handpickedSnapIndex = n
                viewModel.snapIndex = n
            } else {
                delegate?.didCompletePreview()
            }
        }
    }
    @objc private func didCompleteProgress() {
        let n = viewModel.snapIndex + 1
        if let count = viewModel.story?.snapsCount {
            if n < count {
                //Move to next snap
                let x = n.toFloat * frame.width
                let offset = CGPoint(x: x, y: 0)
                scrollView.setContentOffset(offset, animated: false)
                viewModel.story?.lastPlayedSnapIndex = n
                viewModel.direction = .forward
                viewModel.handpickedSnapIndex = n
                viewModel.snapIndex = n
            }else {
                stopPlayer()
                delegate?.didCompletePreview()
            }
        }
    }
    private func fillUpMissingImageViews(_ sIndex: Int) {
        if sIndex != 0 {
            for i in 0..<sIndex {
                viewModel.snapIndex = i
            }
            let xValue = sIndex.toFloat * scrollView.frame.width
            scrollView.contentOffset = CGPoint(x: xValue, y: 0)
        }
    }
    //Before progress view starts we have to fill the progressView
    private func fillupLastPlayedSnap(_ sIndex: Int) {
        if let snap = viewModel.story?.nonDeletedSnaps[sIndex],
           snap.kind == .video {
            viewModel.videoSnapIndex = sIndex
            stopPlayer()
        }
        if let holderView = self.getProgressIndicatorView(with: sIndex),
           let progressView = self.getProgressView(with: sIndex){
            progressView.widthConstraint?.isActive = false
            progressView.widthConstraint = progressView.widthAnchor.constraint(equalTo: holderView.widthAnchor, multiplier: 1.0)
            progressView.widthConstraint?.isActive = true
        }
    }
    private func fillupLastPlayedSnaps(_ sIndex: Int) {
        //Coz, we are ignoring the first.snap
        if sIndex != 0 {
            for i in 0..<sIndex {
                if let holderView = self.getProgressIndicatorView(with: i),
                   let progressView = self.getProgressView(with: i){
                    progressView.widthConstraint?.isActive = false
                    progressView.widthConstraint = progressView.widthAnchor.constraint(equalTo: holderView.widthAnchor, multiplier: 1.0)
                    progressView.widthConstraint?.isActive = true
                }
            }
        }
    }
    private func clearLastPlayedSnaps(_ sIndex: Int) {
        if let _ = self.getProgressIndicatorView(with: sIndex),
           let progressView = self.getProgressView(with: sIndex) {
            progressView.widthConstraint?.isActive = false
            progressView.widthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
            progressView.widthConstraint?.isActive = true
        }
    }
    private func clearScrollViewGarbages() {
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        if scrollView.subviews.count > 0 {
            #warning("why specially declared 0 here. ha ha ha")
            var i = 0 + viewModel.snapViewTag
            var snapViews = [UIView]()
            scrollView.subviews.forEach({ (imageView) in
                if imageView.tag == i {
                    snapViews.append(imageView)
                    i += 1
                }
            })
            if snapViews.count > 0 {
                snapViews.forEach({ (view) in
                    view.removeFromSuperview()
                })
            }
        }
    }
    private func gearupTheProgressors(type: MimeType, playerView: IGPlayerView? = nil) {
        if let holderView = getProgressIndicatorView(with: viewModel.snapIndex),
           let progressView = getProgressView(with: viewModel.snapIndex){
            progressView.story_identifier = viewModel.story?.id
            progressView.snapIndex = viewModel.snapIndex
            DispatchQueue.main.async {
                if type == .image {
                    progressView.start(with: 5.0, holderView: holderView, completion: {(identifier, snapIndex, isCancelledAbruptly) in
                        print("Completed snapindex: \(snapIndex)")
                        if isCancelledAbruptly == false {
                            self.didCompleteProgress()
                        }
                    })
                }else {
                    //Handled in delegate methods for videos
                }
            }
        }
    }
    
    //MARK:- Internal functions
    func startProgressors() {
        DispatchQueue.main.async {
            if self.scrollView.subviews.count > 0 {
                let imageView = self.scrollView.subviews.filter{v in v.tag == self.viewModel.snapIndexWithTag}.first as? UIImageView
                if imageView?.image != nil && self.viewModel.story?.isCompletelyVisible == true {
                    self.gearupTheProgressors(type: .image)
                } else {
                    // Didend displaying will call this startProgressors method. After that only isCompletelyVisible get true. Then we have to start the video if that snap contains video.
                    if self.viewModel.story?.isCompletelyVisible == true {
                        let videoView = self.scrollView.subviews.filter{v in v.tag == self.viewModel.snapIndexWithTag}.first as? IGPlayerView
                        let snap = self.viewModel.story?.nonDeletedSnaps[self.viewModel.snapIndex]
                        if let vv = videoView, self.viewModel.story?.isCompletelyVisible == true {
                            self.startPlayer(videoView: vv, with: snap!.url)
                        }
                    }
                }
            }
        }
    }
    func getProgressView(with index: Int) -> IGSnapProgressView? {
        let progressView = storyHeaderView.getProgressView
        if progressView.subviews.count > 0 {
            let pv = getProgressIndicatorView(with: index)?.subviews.first as? IGSnapProgressView
            guard let currentStory = viewModel.story else {
                fatalError("story not found")
            }
            pv?.story = currentStory
            return pv
        }
        return nil
    }
    func getProgressIndicatorView(with index: Int) -> IGSnapProgressIndicatorView? {
        let progressView = storyHeaderView.getProgressView
        return progressView.subviews.filter({v in v.tag == index+progressIndicatorViewTag}).first as? IGSnapProgressIndicatorView ?? nil
    }
    func adjustPreviousSnapProgressorsWidth(with index: Int) {
        fillupLastPlayedSnaps(index)
    }
    func deleteSnap() {
        let progressView = storyHeaderView.getProgressView
        clearLastPlayedSnaps(viewModel.snapIndex)
        stopSnapProgressors(with: viewModel.snapIndex)
        
        let snapCount = viewModel.story?.snapsCount ?? 0
        if let lastIndicatorView = getProgressIndicatorView(with: snapCount-1), let preLastIndicatorView = getProgressIndicatorView(with: snapCount-2) {
            
            lastIndicatorView.constraints.forEach { $0.isActive = false }
            
            preLastIndicatorView.rightConstraiant?.isActive = false
            preLastIndicatorView.rightConstraiant = progressView.igRightAnchor.constraint(equalTo: preLastIndicatorView.igRightAnchor, constant: 8)
            preLastIndicatorView.rightConstraiant?.isActive = true
        } else {
            debugPrint("No Snaps")
        }
        /**
         - If user is going to delete video snap, then we need to stop the player.
         - Remove the videoView/snapView from the scrollview subviews. Because once the snap got deleted, the next snap will be created on that same frame(x,y,width,height). If we didn't remove the videoView/snapView from scrollView subviews then it will create some wierd issues.
         */
        if viewModel.story?.nonDeletedSnaps[viewModel.snapIndex].kind == .video {
            stopPlayer()
        }
        scrollView.subviews.filter({$0.tag == viewModel.snapIndex + viewModel.snapViewTag}).first?.removeFromSuperview()
        
        /**
         Once we set isDeleted, snaps and snaps count will be reduced by one. So, instead of snapIndex+1, we need to pass snapIndex to willMoveToPreviousOrNextSnap. But the corresponding progressIndicator is not currently in active. Another possible way is we can always remove last presented progress indicator. So that snapIndex and tag will matches, so that progress indicator starts.
         */
        viewModel.story?.nonDeletedSnaps[viewModel.snapIndex].isDeleted = true
        viewModel.direction = .forward
        for sIndex in 0..<viewModel.snapIndex {
            if let holderView = self.getProgressIndicatorView(with: sIndex),
               let progressView = self.getProgressView(with: sIndex){
                progressView.widthConstraint?.isActive = false
                progressView.widthConstraint = progressView.widthAnchor.constraint(equalTo: holderView.widthAnchor, multiplier: 1.0)
                progressView.widthConstraint?.isActive = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {[weak self] in
            if let snapIndex = self?.viewModel.snapIndex {
                self?.willMoveToPreviousOrNextSnap(n: snapIndex)
            }
        }
        
        //Do the api call, when api request is success remove the snap using snap internal identifier from the nsuserdefaults.
    }
    
    //MARK: - Public functions
    public func willDisplayCellForZerothIndex(with sIndex: Int, handpickedSnapIndex: Int) {
        viewModel.handpickedSnapIndex = handpickedSnapIndex
        viewModel.story?.isCompletelyVisible = true
        willDisplayCell(with: handpickedSnapIndex)
    }
    public func willDisplayCell(with sIndex: Int) {
        //Todo:Make sure to move filling part and creating at one place
        //Clear the progressor subviews before the creating new set of progressors.
        storyHeaderView.clearTheProgressorSubviews()
        storyHeaderView.createSnapProgressors()
        fillUpMissingImageViews(sIndex)
        fillupLastPlayedSnaps(sIndex)
        viewModel.snapIndex = sIndex
        
        //Remove the previous observors
        NotificationCenter.default.removeObserver(self)
        
        // Add the observer to handle application from background to foreground
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    public func startSnapProgress(with sIndex: Int) {
        if let indicatorView = getProgressIndicatorView(with: sIndex),
           let pv = getProgressView(with: sIndex) {
            pv.start(with: 5.0, holderView: indicatorView, completion: { (identifier, snapIndex, isCancelledAbruptly) in
                if isCancelledAbruptly == false {
                    self.didCompleteProgress()
                }
            })
        }
    }
    public func pauseSnapProgressors(with sIndex: Int) {
        viewModel.story?.isCompletelyVisible = false
        getProgressView(with: sIndex)?.pause()
    }
    public func stopSnapProgressors(with sIndex: Int) {
        getProgressView(with: sIndex)?.stop()
    }
    public func resetSnapProgressors(with sIndex: Int) {
        self.getProgressView(with: sIndex)?.reset()
    }
    public func pausePlayer(with sIndex: Int) {
        (getSnapView(index: sIndex+viewModel.snapViewTag) as? IGPlayerView)?.pause()
    }
    public func stopPlayer() {
        let videoView = getSnapView(index: viewModel.videoSnapIndex+viewModel.snapViewTag) as? IGPlayerView
        if videoView?.player?.timeControlStatus != .playing {
            (getSnapView(index: viewModel.videoSnapIndex+viewModel.snapViewTag) as? IGPlayerView)?.player?.replaceCurrentItem(with: nil)
        }
        videoView?.stop()
        //getVideoView(with: videoSnapIndex)?.player = nil
    }
    public func resumePlayer(with sIndex: Int) {
        (getSnapView(index: sIndex+viewModel.snapViewTag) as? IGPlayerView)?.play()
    }
    public func didEndDisplayingCell() {
        
    }
    public func resumePreviousSnapProgress(with sIndex: Int) {
        getProgressView(with: sIndex)?.resume()
    }
    public func pauseEntireSnap() {
        let v = getProgressView(with: viewModel.snapIndex)
        let videoView = scrollView.subviews.filter{v in v.tag == viewModel.snapIndex + viewModel.snapViewTag}.first as? IGPlayerView
        if videoView != nil {
            v?.pause()
            videoView?.pause()
        }else {
            v?.pause()
        }
    }
    public func resumeEntireSnap() {
        let v = getProgressView(with: viewModel.snapIndex)
        let videoView = scrollView.subviews.filter{v in v.tag == viewModel.snapIndex + viewModel.snapViewTag}.first as? IGPlayerView
        if videoView != nil {
            v?.resume()
            videoView?.play()
        }else {
            v?.resume()
        }
    }
    //Used the below function for image retry option
    public func retryRequest(view: UIView, with url: String) {
        if let v = view as? UIImageView {
            v.removeRetryButton()
            self.startRequest(snapView: v, with: url)
        }else if let v = view as? IGPlayerView {
            v.removeRetryButton()
            self.startPlayer(videoView: v, with: url)
        }
    }
}

//MARK: - Extension|StoryPreviewHeaderProtocol
extension IGStoryPreviewCell: StoryPreviewHeaderProtocol {
    func didTapCloseButton() {
        delegate?.didTapCloseButton()
    }
}

//MARK: - Extension|RetryBtnDelegate
extension IGStoryPreviewCell: RetryBtnDelegate {
    func retryButtonTapped() {
        guard let parentView = retryButton.superview,
              let url = retryButton.contentURL else {
            return
        }
        retryRequest(view: parentView, with: url)
    }
}

//MARK: - Extension|IGPlayerObserverDelegate
extension IGStoryPreviewCell: IGPlayerObserver {
    
    func didStartPlaying() {
        if let videoView = getSnapView(index: viewModel.snapIndex+viewModel.snapViewTag) as? IGPlayerView, videoView.currentTime <= 0 {
            if videoView.error == nil && (viewModel.story?.isCompletelyVisible)! == true {
                if let holderView = getProgressIndicatorView(with: viewModel.snapIndex),
                   let progressView = getProgressView(with: viewModel.snapIndex) {
                    progressView.story_identifier = viewModel.story?.id
                    progressView.snapIndex = viewModel.snapIndex
                    if let duration = videoView.currentItem?.asset.duration {
                        if Float(duration.value) > 0 {
                            progressView.start(with: duration.seconds, holderView: holderView, completion: {(identifier, snapIndex, isCancelledAbruptly) in
                                if isCancelledAbruptly == false {
                                    self.viewModel.videoSnapIndex = snapIndex
                                    self.stopPlayer()
                                    self.didCompleteProgress()
                                } else {
                                    self.viewModel.videoSnapIndex = snapIndex
                                    self.stopPlayer()
                                }
                            })
                        }else {
                            debugPrint("Player error: Unable to play the video")
                        }
                    }
                }
            }
        }
    }
    func didFailed(withError error: String, for url: URL?) {
        debugPrint("Failed with error: \(error)")
        if let videoView = (getSnapView(index: viewModel.snapIndex+viewModel.snapViewTag) as? IGPlayerView), let videoURL = url {
            self.retryButton.contentURL = videoURL.absoluteString
            self.isUserInteractionEnabled = true
            videoView.addSubview(self.retryButton)
            let centerX = retryButton.igCenterXAnchor.constraint(equalTo: videoView.igCenterXAnchor)
            let centerY = retryButton.igCenterYAnchor.constraint(equalTo: videoView.igCenterYAnchor)
            NSLayoutConstraint.activate([centerX, centerY])
        }
    }
    func didCompletePlay() {
        //Video completed
    }
    
    func didTrack(progress: Float) {
        //Delegate already handled. If we just print progress, it will print the player current running time
    }
}

extension IGStoryPreviewCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            gestureRecognizer is UISwipeGestureRecognizer
    }
}
