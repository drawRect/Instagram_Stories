//
//  IGStoryPreviewCell.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout

protocol StoryPreviewProtocol: class {
    func didCompletePreview()
    func didTapCloseButton()
}
//Identifiers
fileprivate let snapViewTagIndicator: Int = 8

final class IGStoryPreviewCell: UICollectionViewCell,UIScrollViewDelegate {
    
    //MARK: - Delegate
    public weak var delegate: StoryPreviewProtocol? {
        didSet { storyHeaderView.delegate = self }
    }
    
    //MARK:- Private iVars
    private let scrollview: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.isScrollEnabled = false
        return sv
    }()
    private lazy var storyHeaderView: IGStoryPreviewHeaderView = {
        let v = IGStoryPreviewHeaderView.init(frame: CGRect(x: 0,y: 0,width: frame.width,height: 80))
        return v
    }()
    private lazy var longPress_gesture: UILongPressGestureRecognizer = {
        let lp = UILongPressGestureRecognizer.init(target: self, action: #selector(didLongPress(_:)))
        lp.minimumPressDuration = 0.2
        return lp
    }()
    
    //MARK:- Public iVars
    public var snapIndex: Int = 0 {
        didSet {
            if snapIndex < story?.snapsCount ?? 0 {
                if let snap = story?.snaps?[snapIndex] {
                    if let url = snap.url {
                        let snapView = createSnapView()
                        startRequest(snapView: snapView, with: url)
                    }
                    storyHeaderView.lastUpdatedLabel.text = snap.lastUpdated
                }
            }
        }
    }
    public var story: IGStory? {
        didSet {
            storyHeaderView.story = story
            if let picture = story?.user?.picture {
                storyHeaderView.snaperImageView.setImage(url: picture)
            }
            if let count = story?.snaps?.count {
                scrollview.contentSize = CGSize(width: IGScreen.width * CGFloat(count), height: IGScreen.height)
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
        clearScrollViewGarbages()
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
        scrollview.isPagingEnabled = true
        contentView.addSubview(scrollview)
        contentView.addSubview(storyHeaderView)
        scrollview.addGestureRecognizer(longPress_gesture)
    }
    private func installLayoutConstraints() {
        //Setting constraints for scrollview
        NSLayoutConstraint.activate([
            scrollview.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            scrollview.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            scrollview.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)])
    }
    private func createSnapView() -> UIImageView {
        let previousSnapIndex = snapIndex - 1
        let x_value = (snapIndex == 0) ? 0 : scrollview.subviews[previousSnapIndex].frame.maxX
        let snapView = UIImageView.init(frame: CGRect(x: x_value, y: 0, width: scrollview.frame.width, height: scrollview.frame.height))
        snapView.tag = snapIndex + snapViewTagIndicator
        scrollview.addSubview(snapView)
        return snapView
    }
    private func startRequest(snapView: UIImageView, with url: String) {
        snapView.setImage(url: url, style: .squared, completion: {[weak self]
            (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                if let _self = self {
                    snapView.addRetryButton(_self, url)
                }
            }else {
                self?.startProgressors()
            }
        })
    }
    @objc private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began || sender.state == .ended {
            let v = getProgressView(with: snapIndex)
            if sender.state == .began {
                v?.pause()
            }else {
                v?.resume()
            }
        }
    }
    @objc private func didEnterForeground() {
        if let indicatorView = getProgressIndicatorView(with: snapIndex),
            let pv = getProgressView(with: snapIndex) {
            pv.start(with: 5.0, width: indicatorView.frame.width, completion: { (identifier) in
                self.didCompleteProgress()
            })
        }
    }
    @objc private func didCompleteProgress() {
        let n = snapIndex + 1
        if let count = story?.snapsCount {
            if n < count {
                //Move to next snap
                let x = n.toFloat() * frame.width
                let offset = CGPoint(x: x,y: 0)
                scrollview.setContentOffset(offset, animated: false)
                story?.lastPlayedSnapIndex = n
                snapIndex = n
            }else {
                delegate?.didCompletePreview()
            }
        }
    }
    private func getProgressView(with index: Int) -> IGSnapProgressView? {
        let progressView = storyHeaderView.getProgressView()
        if progressView.subviews.count>0 {
            return progressView.subviews.filter({v in v.tag == index+progressViewTag}).first as? IGSnapProgressView
        }
        return nil
    }
    private func getProgressIndicatorView(with index: Int) -> UIView? {
        let progressView = storyHeaderView.getProgressView()
        if progressView.subviews.count>0 {
            return progressView.subviews.filter({v in v.tag == index+progressIndicatorViewTag}).first
        }else{
            return nil
        }
    }
    private func fillUpMissingImageViews(_ sIndex: Int) {
        if sIndex != 0 {
            for i in 0..<sIndex {
                snapIndex = i
            }
            let xValue = sIndex.toFloat() * scrollview.frame.width
            scrollview.contentOffset = CGPoint(x: xValue, y: 0)
        }
    }
    private func fillupLastPlayedSnaps(_ sIndex: Int) {
        //Coz, we are ignoring the first.snap
        if sIndex != 0 {
            for i in 0..<sIndex {
                if let holderView = self.getProgressIndicatorView(with: i),
                    let progressView = self.getProgressView(with: i){
                    progressView.frame.size.width = holderView.frame.width
                }
            }
        }
    }
    private func clearScrollViewGarbages() {
        scrollview.contentOffset = CGPoint(x: 0, y: 0)
        if scrollview.subviews.count > 0 {
            var i = 0 + snapViewTagIndicator
            var snapViews = [UIView]()
            scrollview.subviews.forEach({ (imageView) in
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
    @objc private func gearupTheProgressors() {
        if let holderView = getProgressIndicatorView(with: snapIndex),
            let progressView = getProgressView(with: snapIndex){
            progressView.story_identifier = self.story?.internalIdentifier
            progressView.start(with: 5.0, width: holderView.frame.width, completion: {(identifier) in
                self.didCompleteProgress()
            })
        }
    }
    
    //MARK:- Internal functions
    internal func startProgressors() {
        if scrollview.subviews.count > 0 {
            let imageView = scrollview.subviews.filter{v in v.tag == snapIndex + snapViewTagIndicator}.first as? UIImageView
            if imageView?.image != nil && story?.isCompletelyVisible == true {
                    self.gearupTheProgressors()
            }
        }
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
        fillUpMissingImageViews(sIndex)
        fillupLastPlayedSnaps(sIndex)
        snapIndex = sIndex
        
        //Remove the previous observors
        NotificationCenter.default.removeObserver(self)
    }
    public func stopPreviousProgressors(with sIndex: Int) {
        story?.isCompletelyVisible = false
        getProgressView(with: sIndex)?.pause()
    }
    public func didEndDisplayingCell() {
        //Here only the cell is completely visible. So this is the right place to add the observer.
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    public func resumePreviousSnapProgress(with sIndex: Int) {
        getProgressView(with: sIndex)?.resume()
    }
    //Used the below function for image retry option
    public func imageRequest(snapView:UIImageView, with url: String) {
        snapView.removeRetryButton()
        self.startRequest(snapView: snapView, with: url)
    }
}

//MARK: - Extension|StoryPreviewHeaderProtocol
extension IGStoryPreviewCell: StoryPreviewHeaderProtocol {
    func didTapCloseButton() {
        delegate?.didTapCloseButton()
    }
}
