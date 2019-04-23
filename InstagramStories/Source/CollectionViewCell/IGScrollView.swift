//
//  IGScrollView.swift
//  InstagramStories
//
//  Created by Kumar, Ranjith B. (623-Extern) on 12/04/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation
import UIKit

protocol GestureConstable: class {
    func didLongPress(_ sender: UILongPressGestureRecognizer)
    func didTap(_ sender: UITapGestureRecognizer)
}

protocol CellVariables: class {
    var snapIIndex: Int {get}
    var isCompletelyVisible: Bool {get}
    var snap: IGSnap {get}
}

//There is no direct dealing between IGSnapview vs Cell.
class IGScrollView: UIScrollView {
    
    enum Direction {
        case forward,backward
    }
    var direction: Direction = .forward
    //The below var is replacement of subviews. anyone can add subview in scrollview. but children is blueprint of our requirement. it can have our babies only. :P
    var children: [IGXView] = [] //if you want respective child using index, you can directly get it (we are avoiding subviews explicitly)
    
    var imageView: IGImageView {
        return children[snapIndex] as! IGImageView
    }
    
    var videoView: IGVideoView {
        return children[snapIndex] as! IGVideoView
    }
    
    private lazy var guestreRecognisers: [UIGestureRecognizer] = {
        let lp = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        lp.minimumPressDuration = 0.2//hardcoded :(
        let tg = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        tg.numberOfTapsRequired = 1//hardcoded :(
        return [lp,tg]
    }()
    
    weak var gestureDelegate: GestureConstable?
    weak var cellVarDelegate: CellVariables?
//    var index: Int = 0
//    var snap:IGSnap! {
//        didSet {
//            addChildView()
//        }
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isScrollEnabled = false
        isPagingEnabled = true
        backgroundColor = .black
        gestureRecognizers = guestreRecognisers
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    private var snapViewXPos: CGFloat {
////        return (snapIndex == 0) ? 0 : scrollview.subviews[previousSnapIndex].frame.maxX
//        return children.isEmpty ? 0 : (children.last?.frame.maxX)!
//    }
    
    var xPos: CGFloat {
        if children.isEmpty {
            return 0.0
        }
        return (children.last?.frame.width)!
    }
    
    var newRect: CGRect {
        return CGRect(x: xPos, y: 0, width: frame.width, height: frame.height)
    }
    
    var snap: IGSnap {
        return (cellVarDelegate?.snap)!
    }
    
    var snapIndex: Int {
        return (cellVarDelegate?.snapIIndex)!
    }
    
    var isCompletelyVisible: Bool {
        return (cellVarDelegate?.isCompletelyVisible)!
    }
    
    func addChildView() {
        if snap.ableToPlay == false {
             print("Invalid File url\(snap.url)")
            return
        }
        var child: IGXView!
        switch snap.kind {
        case .image:
            child = IGImageView(frame: newRect, snap: snap)
        case .video:
            child = IGVideoView(frame: newRect, snap: snap)
        default:
            fatalError()
        }
        children.append(child)
    }
    
//    public func createSnapView(for snap:IGSnap) {
//        if snap.ableToPlay == true {
//            let snapView = IGSnapView(frame: CGRect(x: snapViewXPos, y: 0, width: frame.width, height: frame.height), snap: snap)
////            addSubview(snapView)
//            children.append(snapView)
//        }else {
//            print("Invalid File url\(snap.url)")
//        }
//    }
    
//    private func createSnapView() -> UIImageView {
//        let snapView = UIImageView(frame: CGRect(x: snapViewXPos, y: 0, width: scrollview.frame.width, height: scrollview.frame.height))
//        snapView.tag = snapIndex + snapViewTagIndicator
//        snapView.backgroundColor = .black
//        scrollview.addSubview(snapView)
//        return snapView
//    }
    
//    private func getSnapview() -> UIImageView? {
//        if let imageView = scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first as? UIImageView {
//            return imageView
//        }
//        return nil
//    }
//    private func createVideoView() -> IGPlayerView {
//        let videoView = IGPlayerView(frame: CGRect(x: snapViewXPos, y: 0, width: scrollview.frame.width, height: scrollview.frame.height))
//        videoView.tag = snapIndex + snapViewTagIndicator
//        videoView.playerObserverDelegate = self
//        scrollview.addSubview(videoView)
//        return videoView
//    }
//    private func getVideoView(with index: Int) -> IGPlayerView? {
//        if let videoView = scrollview.subviews.filter({$0.tag == index + snapViewTagIndicator}).first as? IGPlayerView {
//            return videoView
//        }
//        return nil
//    }
    
}

extension IGScrollView {
    @objc private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        gestureDelegate?.didLongPress(sender)
    }
    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        gestureDelegate?.didTap(sender)
    }
}


extension IGScrollView {
    //MARK:- Internal functions
//    func startProgressors() {
//        DispatchQueue.main.async {
//            if self.scrollview.subviews.count > 0 {
//                let imageView = self.scrollview.subviews.filter{v in v.tag == self.snapIndex + snapViewTagIndicator}.first as? UIImageView
//                if imageView?.image != nil && self.story?.isCompletelyVisible == true {
//                    self.gearupTheProgressors(type: .image)
//                } else {
//                    // Didend displaying will call this startProgressors method. After that only isCompletelyVisible get true. Then we have to start the video if that snap contains video.
//                    if self.story?.isCompletelyVisible == true {
//                        let videoView = self.scrollview.subviews.filter{v in v.tag == self.snapIndex + snapViewTagIndicator}.first as? IGPlayerView
//                        let snap = self.story?.snaps[self.snapIndex]
//                        if let vv = videoView, self.story?.isCompletelyVisible == true {
//                            self.startPlayer(videoView: vv, with: snap!.url)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func startProgressors() {
        if !children.isEmpty {
            let child: IGXView!
            child = children[snapIndex]
            switch snap.kind {
            case .image:
                if imageView.imageView.image != nil && isCompletelyVisible == true {
                    //self.gearupTheProgressors(type: .image)
                }
            case .video:
                if isCompletelyVisible {
                    //   self.startPlayer(videoView: vv, with: snap!.url)
                }
            default:
                fatalError()
            }
        }else {
            fatalError("Children is Empty")
        }
    }
    
//    private func gearupTheProgressors(type: MimeType, playerView: IGPlayerView? = nil) {
//        if let holderView = getProgressIndicatorView(with: snapIndex),
//            let progressView = getProgressView(with: snapIndex){
//            progressView.story_identifier = self.story?.internalIdentifier
//            progressView.snapIndex = snapIndex
//            DispatchQueue.main.async {
//                if type == .image {
//                    progressView.start(with: 5.0, width: holderView.frame.width, completion: {(identifier, snapIndex, isCancelledAbruptly) in
//                        if isCancelledAbruptly == false {
//                            self.didCompleteProgress()
//                        }
//                    })
//                }else {
//                    //Handled in delegate methods for videos
//                }
//            }
//        }
//    }
}
