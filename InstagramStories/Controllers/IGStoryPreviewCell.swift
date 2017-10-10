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
    @IBOutlet weak private var scrollView: UIScrollView!{
        didSet{
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
//    public var snapIndex:Int = 0 {
//        didSet {
//            if snapIndex < story?.snapsCount ?? 0 {
//                if let snap = story?.snaps?[snapIndex] {
//                    if let picture = snap.url {
//                        createImageView(with:picture)
//                    }
//                    storyHeaderView?.lastUpdatedLabel.text = snap.lastUpdated
//                }
//            }
//        }
//    }
//    public var story:IGStory? {
//        didSet {
//            storyHeaderView?.story = story
//            if let picture = story?.user?.picture {
//                self.storyHeaderView?.snaperImageView.setImage(url: picture)
//            }
//        }
//    }
    
    //MARK: - Private functions
    //TODO:Here the ScrollView.width is not matching with UIScreen.width<Issue> fix it asap
    private func createImageView(with picture:String) {
        let iv = UIImageView(frame: CGRect(x:scrollView.subviews.last?.frame.maxX ?? CGFloat(0.0),
                                           y:0, width:scrollView.frame.size.width, height:scrollView.frame.size.height))
        startLoadContent(with: iv, picture: picture)
        scrollView.addSubview(iv)
    }
    
    //TODO:This expensive code should move to controller(ie.StoryPreviewController)
    //If Child wants an image it should not simply go and take
    //It should ask parent i want an image to represent the UIImageView!!!
    private func startLoadContent(with imageView:UIImageView,picture:String) {
        imageView.setImage(url: picture, style: .squared, completion: { (result, error) in
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
