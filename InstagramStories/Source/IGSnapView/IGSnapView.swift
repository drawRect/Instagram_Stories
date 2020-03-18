//
//  IGSnapView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 19/02/20.
//  Copyright © 2020 DrawRect. All rights reserved.
//

import UIKit

protocol IGSnapViewDelegate: class {
    func imageLoaded(isLoaded: Bool)
}
class IGSnapView: UIView {
    // MARK: iVars
    let snap: IGSnap
    weak var igSnapViewDelegate: IGSnapViewDelegate?
    var igImageView: IGImageView? {
        return self.subviews.last as? IGImageView
    }
    var igVideoView: IGVideoView? {
        return self.subviews.last as? IGVideoView
    }
    // MARK: init methods
    init(frame: CGRect, snap: IGSnap) {
        self.snap = snap
        super.init(frame: frame)
        self.backgroundColor = .black
        switch snap.kind {
        case .image:
            let contentView: IGXView = IGImageView(frame: frame, snap: snap)
            addSubview(contentView)
            contentView.contentLoaded = { [weak self] status in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.igSnapViewDelegate?.imageLoaded(isLoaded: status)
            }
        case .video:
            let contentView: IGXView = IGVideoView(frame: frame, snap: snap)
            addSubview(contentView)
        case .unknown:
                break
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(snap: IGSnap) {
        self.init(frame: CGRect.zero, snap: snap)
    }
}
