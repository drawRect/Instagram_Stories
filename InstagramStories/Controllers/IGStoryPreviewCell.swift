//
//  IGStoryPreviewCell.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

//Exposing didTapClose function to Objc via #selector thats why we are adding
@objc protocol StoryPreviewProtocol:class {
    func didCompletePreview()
    func didTapClose()
}

class IGStoryPreviewCell: UICollectionViewCell {
    
    //Think about Xcode Snippets here! when you are creating UIElements default behaviour should be 'Private'
    @IBOutlet weak private var headerView: UIView!
    @IBOutlet weak private var scrollView: UIScrollView! {
        didSet {
            if let count = story?.snaps?.count {
                //Here there's an issue with taking scrollview.frame
                scrollView.contentSize = CGSize(width:scrollView.frame.size.width * CGFloat(count), height:scrollView.frame.size.height)
            }
        }
    }
    
    //MARK: - Overriden functions
    override func awakeFromNib() {
        super.awakeFromNib()
        storyHeaderView = Bundle.loadView(with: IGStoryPreviewHeaderView.self)
        storyHeaderView?.frame = CGRect(x:0,y:0,width:frame.width,height:80)
        headerView.addSubview(storyHeaderView!)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let iv:UIImageView = self.scrollView.subviews.last as? UIImageView else{return}
        iv.sd_cancelCurrentImageLoad()
    }
    
    //MARK: - iVars
    public weak var delegate:StoryPreviewProtocol?{
        didSet {
            if let delegate = delegate {
             NotificationCenter.default.addObserver(delegate, selector: #selector(delegate.didTapClose), name: NSNotification.Name(rawValue: IGNotification.previewDismisser), object: nil)
            }
        }
    }
    private var storyHeaderView:IGStoryPreviewHeaderView?
    fileprivate var snapIndex:Int = 0 {
        didSet {
            if snapIndex < story?.snapsCount ?? 0 {
                if let snap = story?.snaps?[snapIndex] {
                    if let urlString = snap.url {
                        createImageView(with:urlString)
                    }
                    storyHeaderView?.lastUpdatedLabel.text = snap.lastUpdated
                }
            }
        }
    }
    public var story:IGStory? {
        didSet {
            storyHeaderView?.story = story
            if let picture = story?.user?.picture {
                self.storyHeaderView?.snaperImageView.setImage(url: picture)
            }
        }
    }
    
    //MARK: - Private functions
    //@note:Here we creating the ImageView before cell displaying on view;So we will get improper self.frame so that only am using IGScreen.frame
    private func createImageView(with urlString:String) {
        let x = scrollView.subviews.last?.frame.maxX ?? CGFloat(0.0)
        let iv = UIImageView(frame: CGRect(x:x,y:0,width:IGScreen.width,height:IGScreen.height))
        scrollView.addSubview(iv)
        iv.setImage(url: urlString, style: .squared, completion: { (result, error) in
            debugPrint("Loading content")
            if let error = error {
                debugPrint(error.localizedDescription)
            }else {
                let pv = self.storyHeaderView?.progressView(with: self.snapIndex)
                pv?.delegate = self
                pv?.willBeginProgress()
            }
        })
    }
    
    public func willDisplay() {
        storyHeaderView?.generateSnappers()
        snapIndex = 0
    }
    public func didEndDisplay() {
        storyHeaderView?.stopTimer(for: snapIndex)
    }
}

extension IGStoryPreviewCell:SnapProgresser {
    func didCompleteProgress() {
        let n = snapIndex + 1
        if let count = story?.snapsCount {
            if n < count {
                //Move to next snap
                let x = n.toFloat() * frame.width
                let offset = CGPoint(x:x,y:0)
                scrollView.setContentOffset(offset, animated: false)
                snapIndex = n
            }else {
                delegate?.didCompletePreview()
            }
        }
    }
}
