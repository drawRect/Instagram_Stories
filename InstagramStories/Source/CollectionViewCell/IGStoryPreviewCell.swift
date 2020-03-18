//
//  IGStoryPreviewCell.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit
import AVKit

protocol StoryPreviewProtocol: class {
    func didCompletePreview()
    func moveToPreviousStory()
    func didTapCloseButton()
}
enum SnapMovementDirectionState {
    case forward
    case backward
}
//Identifiers
fileprivate let snapViewTagIndicator: Int = 8

final class IGStoryPreviewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    //MARK: - Delegate
    public weak var delegate: StoryPreviewProtocol? {
        didSet { storyHeaderView.delegate = self }
    }
    
    //MARK:- Private iVars
    private lazy var storyHeaderView: IGStoryPreviewHeaderView = {
        let v = IGStoryPreviewHeaderView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    /*private lazy var longPress_gesture: UILongPressGestureRecognizer = {
        let lp = UILongPressGestureRecognizer.init(target: self, action: #selector(didLongPress(_:)))
        lp.minimumPressDuration = 0.2
        lp.delegate = self
        return lp
    }()
    private lazy var tap_gesture: UITapGestureRecognizer = {
        let tg = UITapGestureRecognizer(target: self, action: #selector(didTapSnap(_:)))
        tg.cancelsTouchesInView = false;
        tg.numberOfTapsRequired = 1
        tg.delegate = self
        return tg
    }()*/
//    private var previousSnapIndex: Int {
//        return snapIndex - 1
//    }
//    private var snapViewXPos: CGFloat {
//        return (snapIndex == 0) ? 0 : scrollview.subviews[previousSnapIndex].frame.maxX
//    }
    //private var videoSnapIndex: Int = 0
    
    //var retryBtn: IGRetryLoaderButton!
    
    //MARK:- Public iVars
    //public var direction: SnapMovementDirectionState = .forward
    public let scrollview: IGScrollView = {
        let sv = IGScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
//    public var getSnapIndex: Int {
//        return snapIndex
//    }
    public var snapIndex: Int {
        return scrollview.snapIndex
    }
    public var story: IGStory? {
        didSet {
            storyHeaderView.story = story
            scrollview.story = story
            if let picture = story?.user.picture {
                storyHeaderView.snaperImageView.setImage(url: picture)
            }
        }
    }
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollview.frame = bounds
        loadUIElements()
        installLayoutConstraints()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        scrollview.direction = .forward
        scrollview.clearScrollViewGarbages()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    //MARK: - Private functions
    private func loadUIElements() {
        scrollview.delegate = self
        scrollview.igScrollViewDelegate = self
        contentView.addSubview(scrollview)
        contentView.addSubview(storyHeaderView)
    }
    private func installLayoutConstraints() {
        //Setting constraints for scrollview
        NSLayoutConstraint.activate([
            scrollview.igLeftAnchor.constraint(equalTo: contentView.igLeftAnchor),
            contentView.igRightAnchor.constraint(equalTo: scrollview.igRightAnchor),
            scrollview.igTopAnchor.constraint(equalTo: contentView.igTopAnchor),
            contentView.igBottomAnchor.constraint(equalTo: scrollview.igBottomAnchor),
            scrollview.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.0),
            scrollview.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1.0)
            ])
        NSLayoutConstraint.activate([
            storyHeaderView.igLeftAnchor.constraint(equalTo: contentView.igLeftAnchor),
            contentView.igRightAnchor.constraint(equalTo: storyHeaderView.igRightAnchor),
            storyHeaderView.igTopAnchor.constraint(equalTo: contentView.igTopAnchor),
            storyHeaderView.heightAnchor.constraint(equalToConstant: 80)
            ])
    }
    @objc private func didEnterForeground() {
        startSnapProgress(with: snapIndex)
        if let snap = story?.snaps[snapIndex] {
            if snap.kind == .video {
                self.scrollview.children[snapIndex].igVideoView.resumeVideo()
            }else {
                startSnapProgress(with: snapIndex)
            }
        }
    }
    @objc private func didEnterBackground() {
        if let snap = story?.snaps[snapIndex] {
            if snap.kind == .video {
                stopPlayer()
            }
        }
        resetSnapProgressors(with: snapIndex)
    }
    @objc private func didCompleteProgress() {
        let n = snapIndex + 1
        if let count = story?.snapsCount {
            if n < count {
                //Move to next snap
                let x = n.CGFlot * frame.width
                let offset = CGPoint(x: x,y: 0)
                scrollview.setContentOffset(offset, animated: false)
                story?.lastPlayedSnapIndex = n
                scrollview.direction = .forward
                scrollview.snapIndex = n
            }else {
                stopPlayer()
                delegate?.didCompletePreview()
            }
        }
    }
    
    //Before progress view starts we have to fill the progressView
    private func fillupLastPlayedSnap(_ sIndex: Int) {
        if let snap = story?.snaps[sIndex], snap.kind == .video {
            scrollview.videoSnapIndex = sIndex
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
    private func gearupTheProgressors(type: MimeType, playerView: IGPlayerView? = nil) {
        if let holderView = getProgressIndicatorView(with: snapIndex),
            let progressView = getProgressView(with: snapIndex){
            progressView.story_identifier = self.story?.internalIdentifier
            progressView.snapIndex = snapIndex
            DispatchQueue.main.async {
                if type == .image {
                    progressView.start(with: 5.0, holderView: holderView, completion: {(identifier, snapIndex, isCancelledAbruptly) in
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
        DispatchQueue.main.async {[weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.scrollview.subviews.count > 0 {
                if(strongSelf.scrollview.children[strongSelf.snapIndex].snap.kind == MimeType.image) {
                    let imageView = strongSelf.scrollview.children[strongSelf.snapIndex].igImageView.imageview
                    if imageView.image != nil && strongSelf.story?.isCompletelyVisible == true {
                        strongSelf.gearupTheProgressors(type: .image)
                    }
                }
                else {
                    // Didend displaying will call this startProgressors method. After that only isCompletelyVisible get true. Then we have to start the video if that snap contains video.
                    if strongSelf.story?.isCompletelyVisible == true {
                        let videoView = strongSelf.scrollview.children[strongSelf.snapIndex]
                        strongSelf.scrollview.startPlayer(videoView: videoView)
                    }
                }
            }
        }
    }
    func startPlayerSnapProgressor(for videoView: IGPlayerView) {
        if let holderView = getProgressIndicatorView(with: snapIndex),
            let progressView = getProgressView(with: snapIndex) {
            progressView.story_identifier = self.story?.internalIdentifier
            progressView.snapIndex = snapIndex
            if let duration = videoView.currentItem?.asset.duration {
                if Float(duration.value) > 0 {
                    progressView.start(with: duration.seconds, holderView: holderView, completion: {(identifier, snapIndex, isCancelledAbruptly) in
                        if isCancelledAbruptly == false {
                            self.scrollview.videoSnapIndex = snapIndex
                            self.scrollview.stopPlayer()
                            self.didCompleteProgress()
                        } else {
                            self.scrollview.videoSnapIndex = snapIndex
                            self.scrollview.stopPlayer()
                        }
                    })
                }else {
                    self.scrollview.children[scrollview.videoSnapIndex].igVideoView.contentState = .isFailed
                    debugPrint("Player error: Unable to play the video")
                }
            }
        }
    }
    func getProgressView(with index: Int) -> IGSnapProgressView? {
        let progressView = storyHeaderView.getProgressView
        if progressView.subviews.count > 0 {
            let pv = getProgressIndicatorView(with: index)?.subviews.first as? IGSnapProgressView
            guard let currentStory = self.story else {
                fatalError("story not found")
            }
            pv?.story = currentStory
            return pv
        }
        return nil
    }
    func getProgressIndicatorView(with index: Int) -> UIView? {
        let progressView = storyHeaderView.getProgressView
        return progressView.subviews.filter({v in v.tag == index+progressIndicatorViewTag}).first ?? nil
    }
    func adjustPreviousSnapProgressorsWidth(with index: Int) {
        fillupLastPlayedSnaps(index)
    }
    
    //MARK: - Public functions
    public func willDisplayCellForZerothIndex(with sIndex: Int) {
        story?.isCompletelyVisible = true
        willDisplayCell(with: sIndex)
    }
    public func willDisplayCell(with sIndex: Int) {
        //Todo:Make sure to move filling part and creating at one place
        //Clear the progressor subviews before the creating new set of progressors.
        storyHeaderView.clearTheProgressorSubviews()
        storyHeaderView.createSnapProgressors()
        scrollview.fillUpMissingImageViews(sIndex)
        fillupLastPlayedSnaps(sIndex)
        scrollview.snapIndex = sIndex
        
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
        story?.isCompletelyVisible = false
        getProgressView(with: sIndex)?.pause()
    }
    public func stopSnapProgressors(for sIndex: Int) {
        getProgressView(with: sIndex)?.stop()
    }
    public func resetSnapProgressors(with sIndex: Int) {
        self.getProgressView(with: sIndex)?.reset()
    }
    public func resumePreviousSnapProgress(with sIndex: Int) {
        getProgressView(with: sIndex)?.resume()
    }
    public func pauseSnapProgressor() {
        getProgressView(with: snapIndex)?.pause()
    }
    public func resumeSnapProgressor() {
        getProgressView(with: snapIndex)?.resume()
    }
    public func pausePlayer(with sIndex: Int) {
        scrollview.children[sIndex].igVideoView.playerView.pause()
    }
    public func stopPlayer() {
        if(scrollview.videoSnapIndex < scrollview.children.count) {
            let videoView = scrollview.children[scrollview.videoSnapIndex].igVideoView.playerView
            if videoView.player?.timeControlStatus != .playing {
                videoView.player?.replaceCurrentItem(with: nil)
            }
            videoView.stop()
        }
    }
    public func resumePlayer(with sIndex: Int) {
       scrollview.children[sIndex].igVideoView.playerView.play()
    }
}

//MARK: - Extension|StoryPreviewHeaderProtocol
extension IGStoryPreviewCell: StoryPreviewHeaderProtocol {
    func didTapCloseButton() {
        delegate?.didTapCloseButton()
    }
}

extension IGStoryPreviewCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
extension IGStoryPreviewCell: IGScrollViewDelegate {
    func startPlayerProgressor(for videoView: IGPlayerView) {
        self.startPlayerSnapProgressor(for: videoView)
    }
    func contentLoaded() {
        self.startProgressors()
    }
    func updateStoryHeaderView(for snap: IGSnap){
        storyHeaderView.lastUpdatedLabel.text = snap.lastUpdated
    }
    func fillLastPlayedSnap(for snapIndex: Int){
        self.fillupLastPlayedSnap(snapIndex)
    }
    func clearLastPlayedSnaps(for snapIndex: Int){
        self.clearLastPlayedSnaps(snapIndex)
    }
    func resetSnapProgressors(for snapIndex: Int){
        self.resetSnapProgressors(with: snapIndex)
    }
    func moveToPreviousStory(){
        delegate?.moveToPreviousStory()
    }
    func stopProgressors(for snapIndex: Int){
        self.stopSnapProgressors(for: snapIndex)
    }
    func pauseProgressView(){
        self.pauseSnapProgressor()
    }
    func resumeProgressView(){
        self.resumeSnapProgressor()
    }
    func didCompletePreview() {
        delegate?.didCompletePreview()
    }
}
