//
//  IGStoryPreviewCell.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

protocol StoryPreviewProtocol {
    func didCompletePreview()
    //func requestImage(with urlString:String)
}

/*protocol StoryPreviewImageProtocol {
    func didSetImage()
}
class IGStoryPreviewImage:UIImageView {
    public var delegate:StoryPreviewImageProtocol?
    override var image: UIImage?{
        didSet {
            if image != nil{
                delegate?.didSetImage()
            } else {
                //clean your filter or added layer (remove your effects over the view)
            }
        }
    }
}*/

class IGStoryPreviewCell: UICollectionViewCell {
    
    @IBOutlet weak private var headerView: UIView!
    @IBOutlet weak internal var scrollview: UIScrollView!
    
    //MARK: - Overriden functions
    override func awakeFromNib() {
        super.awakeFromNib()
        storyHeaderView = IGStoryPreviewHeaderView.instanceFromNib()
        storyHeaderView?.frame = CGRect(x:0,y:0,width:self.frame.width,height:80)
        self.headerView.addSubview(storyHeaderView!)
    }
    
    override func prepareForReuse() {
        let imageViews = scrollview.subviews.filter({v in v is UIImageView}) as![UIImageView]
        imageViews.forEach({iv in iv.sd_cancelCurrentImageLoad()})
        self.storyHeaderView?.progressView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    //MARK: - iVars
    public var delegate:StoryPreviewProtocol?
    public var storyHeaderView:IGStoryPreviewHeaderView?
    public var snapIndex:Int = 0 {
        didSet {
            if snapIndex < story?.snapsCount ?? 0 {
                if let snap = story?.snaps?[snapIndex] {
                    if let picture = snap.mediaURL {
                        let iv = self.imageView(with: snapIndex)
                        self.startLoadContent(with: iv, picture: picture)
                    }
                }
            }
        }
       /* willSet {
            print("value")
        }*/
    }
    public var story:IGStory? {
        didSet {
            storyHeaderView?.story = story
            //Put this line into IInd Prioirty thread
            storyHeaderView?.generateSnappers()
            if let picture = story?.user?.picture {
                self.storyHeaderView?.snaperImageView.setImage(url: picture)
            }
            //FIXME:Put this line into Ist Prioirty thread
            //Scrollview should create 0th index UIImageView until user interested look for the next snap. you should not create the Imageview. This creation should happen at ON-DEMAND
            generateImageViews()
        }
    }
    internal lazy var imageOperationQueue: OperationQueue = {
        let oq = OperationQueue()
        oq.maxConcurrentOperationCount = 1
        return oq
    }()
    
    
    //MARK: - Private functions
    private func generateImageViews() {
        if let count = story?.snapsCount {
            for index in 0...count-1 {
                let x:CGFloat = CGFloat(index) * frame.size.width
                let iv = UIImageView(frame: CGRect(x:x, y:0, width:frame.size.width, height:frame.size.height))
                iv.tag = index
                //iv.delegate = self
                scrollview.addSubview(iv)
            }
            scrollview.contentSize = CGSize(width:scrollview.frame.size.width * CGFloat(count), height:scrollview.frame.size.height)
        }
    }
    
    //TODO:This expensive code should move to controller(ie.StoryPreviewController)
    //If Child wants an image it should not simply go and take
    //It should ask parent i want an image to represent the UIImageView!!!
    private func startLoadContent(with imageView:UIImageView,picture:String) {
        imageOperationQueue.addOperation {
            imageView.setImage(url: picture, style: .squared, completion: { (result, error) in
                print("Loading content")
                if let error = error {
                    print(error.localizedDescription)
                }else {
                    OperationQueue.main.addOperation({
                        //Start the progress
                        let pv = self.storyHeaderView?.progressView(with: self.snapIndex)
                        pv?.delegate = self
                        pv?.didBeginProgress()
                    })
                }
            })
        }
    }
    
    private func imageView(with index:Int)->UIImageView {
        return scrollview.subviews.filter({v in v.tag == index}).first as! UIImageView
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
                scrollview.setContentOffset(offset, animated: false)
                snapIndex = n
            }else {
                self.delegate?.didCompletePreview()
            }
        }
    }
}
/*extension IGStoryPreviewCell:StoryPreviewImageProtocol {
    func didSetImage() {
        //Start the progress
        let pv = self.storyHeaderView?.progressView(with: self.snapIndex)
        pv?.delegate = self
        DispatchQueue.main.async {
            pv?.didBeginProgress()
        }
    }
}*/
