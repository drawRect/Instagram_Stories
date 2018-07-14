//
//  IGPlayerView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 14/07/18.
//  Copyright © 2018 Dash. All rights reserved.
//

import UIKit

class IGPlayerView: UIView {
    
    //MARK:- iVars
    lazy var player = VideoPlayer()
    lazy var playerView: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: IGScreen.width, height: IGScreen.height))
        player.playerLayer.frame = v.frame
        v.layer.addSublayer(player.playerLayer)
        return v
    }()

    //MARK:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(playerView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK:- Public methods
    public func startPlayer(withResource resource: VideoResource) {
        player.play(with: resource)
    }
}
