//
//  IGXView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 19/02/20.
//  Copyright © 2020 DrawRect. All rights reserved.
//

import UIKit

protocol IGXMisc: class {
    func showLoader(color: UIColor)
    func hideLoader(color: UIColor)
}

extension IGXMisc where Self: IGXView {
    func showLoader(color: UIColor = .black) {
        backgroundColor = color
    }
    
    func hideLoader(color: UIColor = .clear) {
        backgroundColor = color
    }
}

//This class can act as Person class
//ScrollView children should have Parent class of IGXView but the instance is based on the MIME Type whether it is a IGImageView or IGPlayerView
class IGXView: UIView, IGXMisc {
    enum ContentState {
        case isLoading, isLoaded, isFailed
    }
    typealias CompletionHandler = (_ success:Bool) -> Void
    var contentLoaded: CompletionHandler?
    
    lazy var retryBtn: UIButton = {
        let bt = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        bt.setTitle("Re-try", for: .normal)
        bt.center = center
        bt.addTarget(self, action: #selector(loadContent), for: .touchUpInside)
        return bt
    }()
    
    let snap: IGSnap
    var contentState: ContentState = .isLoading {
        didSet {
            switch contentState {
                case .isLoading:
                    showLoader()
                case .isLoaded:
                    hideLoader()
                    //Implement remove retryButton code
                    if(contentLoaded != nil) {
                        contentLoaded!(true)
                }
                case .isFailed:
                    hideLoader(color: UIColor.black.withAlphaComponent(0.2))//dimmed
                    addSubview(retryBtn)
            }
        }
    }
    
    init(frame: CGRect, snap:IGSnap) {
        self.snap = snap
        super.init(frame: frame)
//        defer {
//            loadContent()
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func loadContent() {
        //start request this image using sdwebimage using snap.url
        //start request this video using avplayer with contents of url
    }
}
