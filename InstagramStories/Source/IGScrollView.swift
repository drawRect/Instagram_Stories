//
//  IGScrollView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 19/02/20.
//  Copyright © 2020 DrawRect. All rights reserved.
//

protocol IGScrollViewDelegate {
    func updateStoryHeaderView(for snap: IGSnap)
    func fillLastPlayedSnap(for snapIndex: Int)
    func clearLastPlayedSnaps(for snapIndex: Int)
    func resetSnapProgressors(for snapIndex: Int)
    func moveToPreviousStory()
    func stopProgressors(for snapIndex: Int)
    func pauseProgressView()
    func resumeProgressView()
    func didCompletePreview()
    func contentLoaded()
    func startPlayerProgressor(for videoView: IGPlayerView)
}
import UIKit

//We have to create our own freezed scrollview. I mean when asking the scrollview it should give me the scrollview with all the settings which are sealed(ie.Gestures are long press and tap, and other settings)
//Nobody can create this scrollview without sealed settings, but they can override the properties and update their values repectively

//There is no direct dealing between IGSnapview vs Cell.
class IGScrollView: UIScrollView {
    enum Direction {
        case forward,backward
    }
    var story: IGStory?
    var igScrollViewDelegate: IGScrollViewDelegate?
    var direction: Direction = .forward
    //The below var is replacement of subviews. anyone can add subview in scrollview. but children is blueprint of our requirement. it can have our babies only. :P
    var children: [IGSnapView] = [] //if you want respective child using index, you can directly get it (we are avoiding subviews explicitly)
    
    private lazy var guestureRecognisers: [UIGestureRecognizer] = {
        let lp = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        lp.minimumPressDuration = 0.2//hardcoded :(
        let tg = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        tg.numberOfTapsRequired = 1//hardcoded :(
        return [lp,tg]
    }()
    
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
    private var previousSnapIndex: Int {
        return snapIndex - 1
    }
    var videoSnapIndex = 0
    var snapIndex: Int = 0 {
        didSet{
            self.isUserInteractionEnabled = true
            switch direction {
                case .forward:
                    if snapIndex < story?.snapsCount ?? 0 {
                        if let snap = story?.snaps[snapIndex] {
                            if snap.kind == MimeType.image {
                                if let snapView = getSnapview(snapIndex: snapIndex) {
                                    snapView.igImageView.loadContent()
                                } else {
                                    let snapView = createSnapView(for: snap)
                                    snapView.igImageView.loadContent()
                                }
                            }
                            else {
                                if let videoView = getSnapview(snapIndex: snapIndex) {
                                    startPlayer(videoView: videoView)
                                }else {
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
                            if snap.kind != MimeType.video {
                                if let snapView = getSnapview(snapIndex: snapIndex) {
                                    snapView.igImageView.loadContent()
                                }
                            }
                            else {
                                if let videoView = getSnapview(snapIndex: snapIndex) {
                                    startPlayer(videoView: videoView)
                                }else {
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
    @objc private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began || sender.state == .ended {
            if sender.state == .began {
                pauseEntireSnap()
            }else {
                resumeEntireSnap()
            }
        }
    }
    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(ofTouch: 0, in: self)
        
        if let snapCount = story?.snapsCount {
            var n = snapIndex
            /*!
             * Based on the tap gesture(X) setting the direction to either forward or backward
             */
            if let snap = story?.snaps[n], snap.kind == .image {
                //Remove retry button if tap forward or backward if it exists
                igScrollViewDelegate?.fillLastPlayedSnap(for: n)
            }else {
                //Remove retry button if tap forward or backward if it exists
                if self.children[n].igVideoView.playerView.player?.timeControlStatus != .playing {
                   igScrollViewDelegate?.fillLastPlayedSnap(for: n)
                }
            }
            if touchLocation.x < self.contentOffset.x + (self.frame.width/2) {
                direction = .backward
                if snapIndex >= 1 && snapIndex <= snapCount {
                    igScrollViewDelegate?.clearLastPlayedSnaps(for: n)
                    igScrollViewDelegate?.stopProgressors(for: n)
                    n -= 1
                    igScrollViewDelegate?.resetSnapProgressors(for: n)
                    willMoveToPreviousOrNextSnap(n: n)
                } else {
                    igScrollViewDelegate?.moveToPreviousStory()
                }
            } else {
                if snapIndex >= 0 && snapIndex <= snapCount {
                    //Stopping the current running progressors
                    igScrollViewDelegate?.stopProgressors(for: n)
                    direction = .forward
                    n += 1
                    willMoveToPreviousOrNextSnap(n: n)
                }
            }
        }
    }
    
    public func createSnapView(for snap:IGSnap) -> IGSnapView{
        let snapView = IGSnapView(frame: frame, snap: snap)
        snapView.translatesAutoresizingMaskIntoConstraints = false
        snapView.igSnapViewDelegate = self
        children.append(snapView)
        self.addSubview(snapView)
        
        // Setting constraints for snap view.
        NSLayoutConstraint.activate([
            snapView.leadingAnchor.constraint(equalTo: (snapIndex == 0) ? self.leadingAnchor : self.subviews[previousSnapIndex].trailingAnchor),
            snapView.igTopAnchor.constraint(equalTo: self.igTopAnchor),
            snapView.widthAnchor.constraint(equalTo: self.widthAnchor),
            snapView.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.igBottomAnchor.constraint(equalTo: snapView.igBottomAnchor)
        ])
        return snapView
    }
    private func getSnapview(snapIndex: Int) -> IGSnapView? {
        if children.isEmpty || snapIndex > children.count - 1 {
            return nil
        }
        return self.children[snapIndex]
    }
    private func createVideoView(for snap:IGSnap) -> IGSnapView {
        let snapView = IGSnapView(frame: frame, snap: snap)
        snapView.translatesAutoresizingMaskIntoConstraints = false
        snapView.igSnapViewDelegate = self
        snapView.igVideoView.playerView.playerObserverDelegate = self
        children.append(snapView)
        self.addSubview(snapView)
        
        // Setting constraints for snap view.
        NSLayoutConstraint.activate([
            snapView.leadingAnchor.constraint(equalTo: (snapIndex == 0) ? self.leadingAnchor : self.subviews[previousSnapIndex].trailingAnchor),
            snapView.igTopAnchor.constraint(equalTo: self.igTopAnchor),
            snapView.widthAnchor.constraint(equalTo: self.widthAnchor),
            snapView.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.igBottomAnchor.constraint(equalTo: snapView.igBottomAnchor)
        ])
        return snapView
    }
    func startPlayer(videoView: IGSnapView) {
        if !(self.children.isEmpty) &&  story?.isCompletelyVisible == true {
            videoView.igVideoView.loadContent()
        }
    }
    public func pausePlayer(with sIndex: Int) {
        self.children[sIndex].igVideoView.pauseVideo()
    }
    public func stopPlayer() {
        let videoView = self.children[videoSnapIndex].igVideoView
        if videoView.playerView.player?.timeControlStatus != .playing {
            videoView.playerView.player?.replaceCurrentItem(with: nil)
        }
        videoView.stopVideo()
        videoView.playerView.player = nil
    }
    public func resumePlayer(with sIndex: Int) {
        self.children[sIndex].igVideoView.resumeVideo()
    }
    public func clearScrollViewGarbages() {
        self.contentOffset = CGPoint(x: 0, y: 0)
        self.children.forEach { (snapview) in
            snapview.removeFromSuperview()
        }
        self.children.removeAll()
    }
    public func pauseEntireSnap() {
        if(self.children[snapIndex].snap.kind == MimeType.video) {
            igScrollViewDelegate?.pauseProgressView()
            self.children[snapIndex].igVideoView.pauseVideo()
        } else {
            igScrollViewDelegate?.pauseProgressView()
        }
    }
    public func resumeEntireSnap() {
        //let v = getProgressView(with: snapIndex)
        if(self.children[snapIndex].snap.kind == MimeType.video) {
            igScrollViewDelegate?.resumeProgressView()
            self.children[snapIndex].igVideoView.resumeVideo()
        } else {
            igScrollViewDelegate?.resumeProgressView()
        }
    }
    
    func fillUpMissingImageViews(_ sIndex: Int) {
        if sIndex != 0 {
            for i in 0..<sIndex {
                snapIndex = i
            }
            let xValue = sIndex.toFloat * self.frame.width
            self.contentOffset = CGPoint(x: xValue, y: 0)
        }
    }
    func willMoveToPreviousOrNextSnap(n: Int) {
        if let count = story?.snapsCount {
            if n < count {
                //Move to next or previous snap based on index n
                let x = n.toFloat * frame.width
                let offset = CGPoint(x: x,y: 0)
                self.setContentOffset(offset, animated: false)
                story?.lastPlayedSnapIndex = n
                snapIndex = n
            } else {
                igScrollViewDelegate?.didCompletePreview()
            }
        }
    }
}

extension IGScrollView : IGSnapViewDelegate {
    func imageLoaded(isLoaded: Bool) {
        if(isLoaded){
            igScrollViewDelegate?.contentLoaded()
        }
    }
}

//MARK: - Extension|IGPlayerObserverDelegate
extension IGScrollView: IGPlayerObserver {
    func didStartPlaying() {
        let videoView = self.children[snapIndex].igVideoView.playerView
        if videoView.currentTime <= 0 {
            if videoView.error == nil && (story?.isCompletelyVisible)! == true {
                igScrollViewDelegate?.startPlayerProgressor(for: videoView)
            }
        }
    }
    func didFailed(withError error: String, for url: URL?) {
        debugPrint("Failed with error: \(error)")
        /*if let videoView = getVideoView(with: snapIndex), let videoURL = url {
            self.retryBtn = IGRetryLoaderButton(withURL: videoURL.absoluteString)
            self.retryBtn.translatesAutoresizingMaskIntoConstraints = false
            self.retryBtn.delegate = self
            self.isUserInteractionEnabled = true
            videoView.addSubview(self.retryBtn)
            NSLayoutConstraint.activate([
                self.retryBtn.igCenterXAnchor.constraint(equalTo: videoView.igCenterXAnchor),
                self.retryBtn.igCenterYAnchor.constraint(equalTo: videoView.igCenterYAnchor)
            ])
        }*/
    }
    func didCompletePlay() {
        //Video completed
    }
    
    func didTrack(progress: Float) {
        //Delegate already handled. If we just print progress, it will print the player current running time
    }
}
