//
//  IGStoryPreviewHeaderView.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

protocol Progresser {
    func didCompleteProgress()
    func didBeginProgress()
}
class IGProgressView:UIProgressView {
    var snapId:String?
}
extension IGProgressView:Progresser {
    func didCompleteProgress() {}
    func didBeginProgress() {}
}

protocol StoryPreviewHeaderTapper {
    func didTapCloseButton()
}

class IGStoryPreviewHeaderView: UIView {
    public var delegate:StoryPreviewHeaderTapper?
    fileprivate var maxSnaps:Int = 15
    public var snaps:[IGSnap]? {
        didSet {
            maxSnaps  = (snaps?.count)! < maxSnaps ? (snaps?.count)! : maxSnaps
        }
    }
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var snaperImageView: UIImageView! {
        didSet {
            snaperImageView.layer.cornerRadius = 40/2
            snaperImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var snaperNameLabel: UILabel!{
        didSet {
            snaperNameLabel.text = "Ramesh"
        }
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.delegate?.didTapCloseButton()
    }
    
    //MARK: - Selectors
    class func instanceFromNib() -> IGStoryPreviewHeaderView {
        let view =  Bundle.loadView(fromNib: "IGStoryPreviewHeaderView", withType: IGStoryPreviewHeaderView.self)
        return view
    }
    
    func generateSnappers(){
        let padding:CGFloat = 8
        var pvX:CGFloat = padding
        let pvY:CGFloat = (self.progressView.frame.height/2)-5
        let pvWidth = (progressView.frame.width - ((maxSnaps+1).toFloat() * padding))/maxSnaps.toFloat()
        let pvHeight:CGFloat = 5
        for _ in 0..<maxSnaps{
            let pv = IGProgressView.init(frame: CGRect(x:pvX,y:pvY,width:pvWidth,height:pvHeight))
            pv.progressTintColor = .red
            pv.progress = 1.0
            progressView.addSubview(pv)
            pvX = pvX + pvWidth + padding
        }
    }
    
}

extension Bundle {
    static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }
        fatalError("Could not load view with type " + String(describing: type))
    }
}

extension Int {
    func toFloat()->CGFloat {
        return CGFloat(self)
    }
}
