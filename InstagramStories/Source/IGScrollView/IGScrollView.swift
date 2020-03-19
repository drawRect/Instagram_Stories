//
//  IGScrollView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 19/02/20.
//  Copyright © 2020 DrawRect. All rights reserved.
//

import UIKit

protocol IGScrollViewDelegate: class {
    /// updating the Story Header View based on the snap update
    func updateStoryHeaderView(for snap: IGSnap)
    /// its going to fill last played snap like.
    /// you watched and simply tries to go back last story, we explictly filling up this
    func fillLastPlayedSnap(for snapIndex: Int)
    /// clear last played snap
    func clearLastPlayedSnaps(for snapIndex: Int)
    /// reset snap progressors if cell is reused
    func resetSnapProgressors(for snapIndex: Int)
    /// move back to previous story
    func moveToPreviousStory()
    /// stop headerview progressor views based on the snap index
    func stopProgressors(for snapIndex: Int)
    /// pause progress view
    func pauseProgressView()
    /// resume progress view
    func resumeProgressView()
    /// callback which complete the snap preview
    func didCompletePreview()
    /// image or video has been loaded
    func contentLoaded()
    /// start progressor for video player
    func startPlayerProgressor(for videoView: IGPlayerView)
}

/*(We have to create our own freezed scrollview.
I mean when asking the scrollview it should give me the scrollview
 with all the settings which are sealed(ie.Gestures are long press and tap,
 and other settings)
Nobody can create this scrollview without sealed settings,
 but they can override the properties and update their values repectively */

//There is no direct dealing between IGSnapview vs Cell.
class IGScrollView: UIScrollView {
    enum Direction {
        case forward, backward
    }
    // MARK: Private Vars
    private var previousSnapIndex: Int {
        return snapIndex - 1
    }
    private lazy var guestureRecognisers: [UIGestureRecognizer] = {
        let lpGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        lpGesture.minimumPressDuration = 0.2//hardcoded :(
        let tpGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        tpGesture.numberOfTapsRequired = 1//hardcoded :(
        return [lpGesture, tpGesture]
    }()
    // MARK: iVars
    var story: IGStory?
    weak var igScrollViewDelegate: IGScrollViewDelegate?
    var direction: Direction = .forward
    //The below var is replacement of subviews.
    //anyone can add subview in scrollview. but children is blueprint
    //of our requirement. it can have our babies only. :P
    var children: [IGSnapView] = [] //if you want respective child using index,
    //you can directly get it (we are avoiding subviews explicitly)
    var videoSnapIndex = 0
    var snapIndex: Int = 0 {
        didSet {
            self.isUserInteractionEnabled = true
            switch direction {
            case .forward:
                    if snapIndex < story?.snapsCount ?? 0 {
                        if let snap = story?.snaps[snapIndex] {
                            if snap.kind == MimeType.image {
                                if let snapView = getSnapview(snapIndex: snapIndex) {
                                    snapView.igImageView?.loadContent()
                                } else {
                                    let snapView = createSnapView(for: snap)
                                    snapView.igImageView?.loadContent()
                                }
                            } else {
                                if let videoView = getSnapview(snapIndex: snapIndex) {
                                    startPlayer(videoView: videoView)
                                } else {
                                    let videoView = createVideoView(for: snap)
                                    startPlayer(videoView: videoView)
                                }
                            }
                            igScrollViewDelegate?.updateStoryHeaderView(for: snap)
                        }
                }
            case .backward:
                    if snapIndex < story?.snapsCount ?? 0 {
                        if let snap = story?.snaps[snapIndex] {
                            if snap.kind != .video {
                                if let snapView = getSnapview(snapIndex: snapIndex) {
                                    snapView.igImageView?.loadContent()
                                }
                            } else {
                                if let videoView = getSnapview(snapIndex: snapIndex) {
                                    startPlayer(videoView: videoView)
                                } else {
                                    let videoView = createVideoView(for: snap)
                                    startPlayer(videoView: videoView)
                                }
                            }
                            igScrollViewDelegate?.updateStoryHeaderView(for: snap)
                        }
                }
            }
        }
    }
    // MARK: init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isScrollEnabled = false
        isPagingEnabled = true
        backgroundColor = .black
        gestureRecognizers = guestureRecognisers
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: Private methods
    @objc private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began || sender.state == .ended {
            if sender.state == .began {
                pauseEntireSnap()
            } else {
                resumeEntireSnap()
            }
        }
    }
    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(ofTouch: 0, in: self)
        if let snapCount = story?.snapsCount {
            var snapIndexCopy = snapIndex
            /*!
             * Based on the tap gesture(X) setting the direction to either forward or backward
             */
            if let snap = story?.snaps[snapIndexCopy], snap.kind == .image {
                //Remove retry button if tap forward or backward if it exists
                igScrollViewDelegate?.fillLastPlayedSnap(for: snapIndexCopy)
            } else {
                //Remove retry button if tap forward or backward if it exists
                if self.children[snapIndexCopy].igVideoView?.playerView.player?.timeControlStatus != .playing {
                    igScrollViewDelegate?.fillLastPlayedSnap(for: snapIndexCopy)
                }
            }
            if touchLocation.x < self.contentOffset.x + (self.frame.width/2) {
                direction = .backward
                if snapIndex >= 1 && snapIndex <= snapCount {
                    igScrollViewDelegate?.clearLastPlayedSnaps(for: snapIndexCopy)
                    igScrollViewDelegate?.stopProgressors(for: snapIndexCopy)
                    snapIndexCopy -= 1
                    igScrollViewDelegate?.resetSnapProgressors(for: snapIndexCopy)
                    willMoveToPreviousOrNextSnap(nextIndex: snapIndexCopy)
                } else {
                    igScrollViewDelegate?.moveToPreviousStory()
                }
            } else {
                if snapIndex >= 0 && snapIndex <= snapCount {
                    //Stopping the current running progressors
                    igScrollViewDelegate?.stopProgressors(for: snapIndexCopy)
                    direction = .forward
                    snapIndexCopy += 1
                    willMoveToPreviousOrNextSnap(nextIndex: snapIndexCopy)
                }
            }
        }
    }
    private func createSnapView(for snap: IGSnap) -> IGSnapView {
        let snapView = IGSnapView(frame: frame, snap: snap)
        snapView.translatesAutoresizingMaskIntoConstraints = false
        snapView.igSnapViewDelegate = self
        children.append(snapView)
        self.addSubview(snapView)
        // Setting constraints for snap view.
        NSLayoutConstraint.activate(
            [snapView.leadingAnchor.constraint(
                equalTo: (snapIndex == 0) ? self.leadingAnchor : self.subviews[previousSnapIndex].trailingAnchor
                ),
            snapView.igTopAnchor.constraint(equalTo: self.igTopAnchor),
            snapView.widthAnchor.constraint(equalTo: self.widthAnchor),
            snapView.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.igBottomAnchor.constraint(equalTo: snapView.igBottomAnchor)
        ]
        )
        return snapView
    }
    private func getSnapview(snapIndex: Int) -> IGSnapView? {
        if children.isEmpty || snapIndex > children.count - 1 {
            return nil
        }
        return self.children[snapIndex]
    }
    private func createVideoView(for snap: IGSnap) -> IGSnapView {
        let snapView = IGSnapView(frame: frame, snap: snap)
        snapView.translatesAutoresizingMaskIntoConstraints = false
        snapView.igSnapViewDelegate = self
        snapView.igVideoView?.playerView.playerObserverDelegate = self
        children.append(snapView)
        self.addSubview(snapView)
        // Setting constraints for snap view.
        NSLayoutConstraint.activate([
            snapView.leadingAnchor.constraint(
                equalTo: (snapIndex == 0) ? self.leadingAnchor : self.subviews[previousSnapIndex].trailingAnchor
            ),
            snapView.igTopAnchor.constraint(equalTo: self.igTopAnchor),
            snapView.widthAnchor.constraint(equalTo: self.widthAnchor),
            snapView.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.igBottomAnchor.constraint(equalTo: snapView.igBottomAnchor)
        ])
        return snapView
    }
    private func willMoveToPreviousOrNextSnap(nextIndex: Int) {
        if let count = story?.snapsCount {
            if nextIndex < count {
                //Move to next or previous snap based on index n
                let maxX = nextIndex.CGFlot * frame.width
                let offset = CGPoint(x: maxX, y: 0)
                self.setContentOffset(offset, animated: false)
                story?.lastPlayedSnapIndex = nextIndex
                snapIndex = nextIndex
            } else {
                igScrollViewDelegate?.didCompletePreview()
            }
        }
    }
    // MARK: Internal methods
    func startPlayer(videoView: IGSnapView) {
        if !(self.children.isEmpty) &&  story?.isCompletelyVisible == true {
            videoView.igVideoView?.loadContent()
        }
    }
    func pausePlayer(with sIndex: Int) {
        self.children[sIndex].igVideoView?.pauseVideo()
    }
    func stopPlayer() {
        let videoView = self.children[videoSnapIndex].igVideoView
        if videoView?.playerView.player?.timeControlStatus != .playing {
            videoView?.playerView.player?.replaceCurrentItem(with: nil)
        }
        videoView?.stopVideo()
        videoView?.playerView.player = nil
    }
    func resumePlayer(with sIndex: Int) {
        self.children[sIndex].igVideoView?.resumeVideo()
    }
    func clearScrollViewGarbages() {
        self.contentOffset = CGPoint(x: 0, y: 0)
        self.children.forEach { (snapview) in
            snapview.removeFromSuperview()
        }
        self.children.removeAll()
    }
    func pauseEntireSnap() {
        if self.children[snapIndex].snap.kind == .video {
            igScrollViewDelegate?.pauseProgressView()
            self.children[snapIndex].igVideoView?.pauseVideo()
        } else {
            igScrollViewDelegate?.pauseProgressView()
        }
    }
    func resumeEntireSnap() {
        //let v = getProgressView(with: snapIndex)
        if self.children[snapIndex].snap.kind == .video {
            igScrollViewDelegate?.resumeProgressView()
            self.children[snapIndex].igVideoView?.resumeVideo()
        } else {
            igScrollViewDelegate?.resumeProgressView()
        }
    }
    func fillUpMissingImageViews(_ sIndex: Int) {
        if sIndex != 0 {
            for index in 0..<sIndex {
                snapIndex = index
            }
            let xValue = sIndex.CGFlot * self.frame.width
            self.contentOffset = CGPoint(x: xValue, y: 0)
        }
    }
}

// MARK: - Extension|IGSnapViewDelegate
extension IGScrollView: IGSnapViewDelegate {
    func imageLoaded(isLoaded: Bool) {
        if isLoaded {
            igScrollViewDelegate?.contentLoaded()
        }
    }
}

// MARK: Extension|IGPlayerObserverDelegate
extension IGScrollView: IGPlayerObserver {
    func didStartPlaying() {
        guard let videoView = self.children[snapIndex].igVideoView?.playerView else {
            return
        }
        if videoView.currentTime <= 0 {
            if videoView.error == nil && (story?.isCompletelyVisible)! == true {
                igScrollViewDelegate?.startPlayerProgressor(for: videoView)
            }
        }
    }
    func didFailed(withError error: String, for url: URL?) {
        debugPrint("Failed with error: \(error)")
    }
    func didCompletePlay() {
        //Video completed
    }
    func didTrack(progress: Float) {
        //Delegate already handled. If we just print progress, it will print the player current running time
    }
}
