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

//Identifiers
fileprivate let snapViewTag = 8

final class IGStoryPreviewCell: UICollectionViewCell,UIScrollViewDelegate {

    //MARK: - iVars
    let scrollview: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.isScrollEnabled = false
        return sv
    }()
    
    private lazy var storyHeaderView: IGStoryPreviewHeaderView = {
        let v = IGStoryPreviewHeaderView.init(frame: CGRect(x:0,y:0,width:frame.width,height:80))
        return v
    }()
    private lazy var longPress_gesture: UILongPressGestureRecognizer = {
        let lp = UILongPressGestureRecognizer.init(target: self, action: #selector(didLongPress(_:)))
        lp.minimumPressDuration = 0.2
        return lp
    }()
    
    var isCompletelyVisible:Bool = false{
        didSet{
            if scrollview.subviews.count > 0{
                let imageView = scrollview.subviews.filter{v in v.tag == snapIndex + snapViewTag}.first as? UIImageView
                if imageView?.image != nil && isCompletelyVisible == true{
                    gearupTheProgressors()
                }
            }
        }
    }
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollview.frame = bounds
        loadUIElements()
        //installLayoutConstraints()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        isCompletelyVisible = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                        let snapView = createSnapView()
                        startRequest(snapView: snapView, with: url)
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
            if let count = story?.snaps?.count {
                let scrollview_subviews = scrollview.subviews.filter({v in v is UIImageView})
                scrollview_subviews.forEach{v in v.removeFromSuperview()}
                scrollview.contentSize = CGSize(width:IGScreen.width * CGFloat(count), height:IGScreen.height)
            }
        }
    }
    
    //MARK: - Private functions
    
    private func loadUIElements(){
        scrollview.delegate = self
        scrollview.isPagingEnabled = true
        addSubview(scrollview)
        //storyHeaderView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        addSubview(storyHeaderView)
        scrollview.addGestureRecognizer(longPress_gesture)
    }
    
    private func installLayoutConstraints(){
        scrollview.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        scrollview.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        scrollview.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        scrollview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    private func createSnapView()->UIImageView {
        let xValue = (scrollview.subviews.count > 0) ? scrollview.subviews[snapIndex-1].frame.maxX : scrollview.frame.origin.x
        let snapView = UIImageView.init(frame: CGRect(x: xValue, y: 0, width: scrollview.frame.width, height: scrollview.frame.height))
        snapView.tag = snapIndex + snapViewTag
        scrollview.addSubview(snapView)
        return snapView
    }
    private func startRequest(snapView:UIImageView,with url:String) {
        snapView.setImage(url: url, style: .squared, completion: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }else {
                if self.isCompletelyVisible {
                    self.gearupTheProgressors()
                }
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
        let indicatorView = getProgressIndicatorView(with: snapIndex)
        let pv = getProgressView(with: snapIndex)
        pv.start(with: 5.0, width: indicatorView.frame.width, completion: {
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
    
    private func getProgressView(with index:Int)->IGSnapProgressView {
        if (storyHeaderView.subviews.first?.subviews.count)! > 0{
            return storyHeaderView.subviews.first?.subviews.filter({v in v.tag == index+progressViewTag}).first as! IGSnapProgressView
        }else{
            //correct it!
            return IGSnapProgressView()
        }
    }
    
    private func getProgressIndicatorView(with index:Int)->UIView {
        if (storyHeaderView.subviews.first?.subviews.count)! > 0{
            return (storyHeaderView.subviews.first?.subviews.filter({v in v.tag == index+progressIndicatorViewTag}).first)!
        }else{
            //correct it!
            return UIView()
        }
    }
    
    public func willDisplayAtZerothIndex() {
        isCompletelyVisible = true
        willDisplayCell(with: 0)
    }
    
    public func willDisplayCell(with sIndex:Int) {
        storyHeaderView.createSnapProgressors()
        snapIndex = sIndex
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    public func didEndDisplayingCell() {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func willBeginDragging(with index:Int) {
        getProgressView(with: index).pause()
    }
    public func didEndDecelerating(with index:Int) {
        getProgressView(with: index).play()
    }
    
    private func gearupTheProgressors() {
        let holderView = getProgressIndicatorView(with: snapIndex)
        let progressView = getProgressView(with: snapIndex)
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
