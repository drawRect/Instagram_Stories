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

//There is no direct dealing between IGSnapview vs Cell.
class IGScrollView: UIScrollView {
    enum Direction {
        case forward,backward
    }
    var direction: Direction = .forward
    //The below var is replacement of subviews. anyone can add subview in scrollview. but children is blueprint of our requirement. it can have our babies only. :P
    var children: [IGSnapView] = [] //if you want respective child using index, you can directly get it (we are avoiding subviews explicitly)
    
    private lazy var guestreRecognisers: [UIGestureRecognizer] = {
        let lp = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        lp.minimumPressDuration = 0.2//hardcoded :(
        let tg = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        tg.numberOfTapsRequired = 1//hardcoded :(
        return [lp,tg]
    }()
    
    public weak var gestureDelegate: GestureConstable?
    
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
    private var snapViewXPos: CGFloat {
//        return (snapIndex == 0) ? 0 : scrollview.subviews[previousSnapIndex].frame.maxX
        return children.isEmpty ? 0 : (children.last?.frame.maxX)!
    }
    
    public func createSnapView(for snap:IGSnap) {
        if snap.ableToPlay == true {
            let snapView = IGSnapView(frame: CGRect(x: snapViewXPos, y: 0, width: frame.width, height: frame.height), snap: snap)
            addSubview(snapView)
            children.append(snapView)
        }else {
            print("Invalid File url\(snap.url)")
        }
    }
    
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
