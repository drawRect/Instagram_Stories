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
    public var isCompletelyVisible:Bool = false {
        didSet{
            didObserveProgressor()
        }
    }
    private var snapView:UIImageView?
    
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
                    if let url = snap.url {
                        createSnapView()
                        //Requesting a snap on-demand
                        startRequestSnap(with: url)
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
    private func createSnapView() {
        let iv_frame = CGRect(x:scrollview.subviews.last?.frame.maxX ?? CGFloat(0.0),y:0, width:IGScreen.width, height:IGScreen.height)
        snapView = UIImageView.init(frame: iv_frame)
        scrollview.addSubview(snapView!)
    }
    private func startRequestSnap(with url:String) {
        snapView?.setImage(url: url, style: .squared, completion: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }else {
                // Cross check the function whether image has been loaded and also cell might get visible!
                self.didObserveProgressor(with: true)
            }
        })
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
    
    @objc private func didEnterForeground() {
        let holderView = self.getProgressIndicatorView(with: self.snapIndex)
        let pv = self.getProgressView(with: self.snapIndex)
        pv.start(with: 5.0, width: holderView.frame.width, completion: {
            self.didCompleteProgress()
        })
    }
    
    @objc private func didCompleteProgress() {
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
    /*-----------------------Boiler Plate Code----------------------------------------*/
    /*---------------Don't spoil the above code,if you want, start writting it down---*/
    
    
    public func markProgressViewAsCompleted() {
        /*if let count = story?.snapsCount {
         for i in 0..<count {
         if i == snapIndex{ break }
         let pv = getProgressView(with: i)
         pv.frame = CGRect(x:pv.frame.origin.x,y:pv.frame.origin.y,width:getProgressIndicatorView(with: i).frame.width,height:pv.frame.height)
         pv.stop()
         }
         }*/
        let pv = getProgressView(with: snapIndex)
        pv.stop()
        didEnterForeground()
    }
    
    private func getProgressView(with index:Int)->IGSnapProgressView {
        return storyHeaderView.subviews.first?.subviews.filter({v in v.tag == index+progressViewTag}).first as! IGSnapProgressView
    }
    
    private func getProgressIndicatorView(with index:Int)->UIView {
        return (storyHeaderView.subviews.first?.subviews.filter({v in v.tag == index+progressIndicatorViewTag}).first)!
    }
    
    public func willDisplayCell() {
        storyHeaderView.createSnapProgressors()
        snapIndex = 0
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    public func didEndDisplayingCell() {
        NotificationCenter.default.removeObserver(self)
//        getProgressView(with: snapIndex).stop()
    }
    public func willBeginDragging(with index:Int) {
        getProgressView(with: index).pause()
    }
    public func didEndDecelerating(with index:Int) {
        //This is a Initial setting up the true' value for upcoming cell
        isCompletelyVisible = true
        getProgressView(with: index).play()
    }
    
    public func willDisplayingAtFirstTime(){
        //for the very first cell is already in visible state
        isCompletelyVisible = true
        willDisplayCell()
    }
    
    func gearupTheProgressors() {
        let holderView = getProgressIndicatorView(with: snapIndex)
        let progressView = getProgressView(with: snapIndex)
        progressView.start(with: 5.0, width: holderView.frame.width, completion: {
            self.didCompleteProgress()
        })
    }
    
    private func didObserveProgressor(with content:Bool = false) {
        if isCompletelyVisible && content {
            gearupTheProgressors()
        }
    }
}

extension IGStoryPreviewCell:StoryPreviewHeaderProtocol {
    func didTapCloseButton() {
        delegate?.didTapCloseButton()
    }
}
