//
//  IGSnapProgressView.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/15/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

protocol ViewAnimator:class {
    func start(with duration:TimeInterval,width:CGFloat,completion:@escaping (_ story_id:String)->())
    func play()
    func pause()
    func stop()
}

extension ViewAnimator where Self:IGSnapProgressView {

    func start(with duration:TimeInterval,width:CGFloat,completion:@escaping (_ story_id:String)->()) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            self.frame.size.width = width
        }) { (finished) in
            if finished == true {
                completion(storyId!)
            }
        }
    }
    func play() {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    func pause() {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    func stop() {
        play()
        layer.removeAllAnimations()
    }
    
    func _stop() {
        layer.speed = 0.0
        layer.removeAllAnimations()
    }
}

final class IGSnapProgressView:UIView,ViewAnimator{}
