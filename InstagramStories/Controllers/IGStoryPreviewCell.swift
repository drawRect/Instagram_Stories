//
//  IGStoryPreviewCell.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

protocol StoryPreviewProtocol:class {
    func didCompletePreview()
    func didTapCloseButton()
}

final class IGStoryPreviewCell: UICollectionViewCell {
    
    @IBOutlet weak private var scrollview: UIScrollView!{
        didSet{
            if let count = story?.snaps?.count {
                scrollview.contentSize = CGSize(width:IGScreen.width * CGFloat(count), height:IGScreen.height)
            }
        }
    }
    
    @IBOutlet weak private var headerView:UIView!
    
    private lazy var storyHeaderView: IGStoryPreviewHeaderView = {
        let v = Bundle.loadView(with: IGStoryPreviewHeaderView.self)
        v.frame = CGRect(x:0,y:0,width:frame.width,height:80)
        return v
    }()
    private lazy var longPress_gesture: UILongPressGestureRecognizer = {
        let lp = UILongPressGestureRecognizer.init(target: self, action: #selector(didLongPress(_:)))
        lp.minimumPressDuration = 0.2
        return lp
    }()
    public var isVisible:Bool = false
    
    //MARK: - Overriden functions
    override func awakeFromNib() {
        super.awakeFromNib()
        headerView.addSubview(storyHeaderView)
        addGestureRecognizer(longPress_gesture)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - iVars
    public weak var delegate:StoryPreviewProtocol? {
        didSet { storyHeaderView.delegate = self }
    }
    public var snapIndex:Int = 0 {
        didSet {
            if snapIndex < story?.snapsCount ?? 0 {
                if let snap = story?.snaps?[snapIndex] {
                    if let picture = snap.url {
                        createImageView(with:picture)
                    }
                    storyHeaderView.lastUpdatedLabel.text = snap.lastUpdated
                }
            }
        }
    }
    public var story:IGStory? {
        didSet {
            storyHeaderView.story = story
            if let picture = story?.user?.picture {
                storyHeaderView.snaperImageView.setImage(url: picture)
            }
        }
    }
    
    //MARK: - Private functions
    private func createImageView(with picture:String) {
        let iv = IGImageView(frame:
            CGRect(x:scrollview.subviews.last?.frame.maxX ?? CGFloat(0.0),y:0, width:IGScreen.width, height:IGScreen.height))
        iv.delegate = self
        startLoadContent(with: iv, picture: picture)
        scrollview.addSubview(iv)
    }
    
    private func startLoadContent(with imageView:UIImageView,picture:String) {
        imageView.setImage(url: picture, style: .squared, completion: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }else {
//                let holderView = self.getProgressIndicatorView(with: self.snapIndex)
//                let progressView = self.getProgressView(with: self.snapIndex)
//                progressView.start(with: 5.0, width: holderView.frame.width, completion: {
//                    self.didCompleteProgress()
//                })
            }
        })
    }
    
    @objc private func didEnterForeground() {
        let holderView = self.getProgressIndicatorView(with: self.snapIndex)
        let pv = self.getProgressView(with: self.snapIndex)
        pv.start(with: 5.0, width: holderView.frame.width, completion: {
            self.didCompleteProgress()
        })
    }

    
    @objc private func didCompleteProgress() {
        //let progressView = self.getProgressView(with: self.snapIndex)
        let n = snapIndex + 1
        if let count = story?.snapsCount {
            if n < count {
                //Move to next snap
                let x = n.toFloat() * frame.width
                let offset = CGPoint(x:x,y:0)
                scrollview.setContentOffset(offset, animated: false)
                snapIndex = n
                
            }else {
                delegate?.didCompletePreview()
            }
        }
    }
    
    private func markProgressViewAsCompleted() {
        if let count = story?.snapsCount {
            for i in 0..<count {
                if i == snapIndex{ break }
                let pv = getProgressView(with: i)
                pv.frame = CGRect(x:pv.frame.origin.x,y:pv.frame.origin.y,width:getProgressIndicatorView(with: i).frame.width,height:pv.frame.height)
            }
        }
    }
    
    private func getProgressView(with index:Int)->IGSnapProgressView {
        return storyHeaderView.subviews.first?.subviews.filter({v in v.tag == index+progressViewTag}).first as! IGSnapProgressView
    }
    
    private func getProgressIndicatorView(with index:Int)->UIView {
        return (storyHeaderView.subviews.first?.subviews.filter({v in v.tag == index+progressIndicatorViewTag}).first)!
    }
    
    public func willDisplayCell() {
        storyHeaderView.generateSnappers()
        snapIndex = 0
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    public func didEndDisplayingCell() {
        NotificationCenter.default.removeObserver(self)
        getProgressView(with: snapIndex).stop()
    }
    public func willBeginDragging(with index:Int) {
        getProgressView(with: index).pause()
    }
    public func didEndDecelerating(with index:Int) {
        getProgressView(with: index).play()
    }
    public func createGenerateSnappersFirstTime() {
        isVisible = true
        storyHeaderView.generateSnappers()
        startSnappers()
    }
    @objc private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began || sender.state == .ended {
            let v = getProgressView(with: snapIndex)
            if sender.state == .began {
                v.pause()
            }else {
                v.play()
            }
        }
    }
    func startSnappers() {
        getProgressView(with: snapIndex).stop()
        let holderView = self.getProgressIndicatorView(with: self.snapIndex)
        let progressView = self.getProgressView(with: self.snapIndex)
        progressView.start(with: 5.0, width: holderView.frame.width, completion: {
            self.didCompleteProgress()
        })
    }
}

extension IGStoryPreviewCell:StoryPreviewHeaderProtocol {
    func didTapCloseButton() {
        delegate?.didTapCloseButton()
    }
}
extension IGStoryPreviewCell:IGImageviewProtocol {
    func imageloaded(_ successfully: Bool) {
        if successfully && isVisible {
            startSnappers()
        }else {
            debugPrint("Someone fucked this image :(")
        }
    }
}

protocol IGImageviewProtocol:class {
    func imageloaded(_ successfully:Bool)
}

class IGImageView:UIImageView {
    public weak var delegate:IGImageviewProtocol?
    override var image: UIImage?{
        didSet {
            if image != nil{
                //do your stuff (add effects, layers, ...)
                delegate?.imageloaded(true)
            } else {
                //clean your filter or added layer (remove your effects over the view)
                delegate?.imageloaded(false)
            }
        }
    }

}

