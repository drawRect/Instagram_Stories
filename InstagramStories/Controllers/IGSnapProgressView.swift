//
//  IGSnapProgressView.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/15/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

protocol SnapProgresser {
    func didCompleteProgress()
}
class IGSnapProgressView:UIProgressView {
    public var delegate:SnapProgresser?
}

extension IGSnapProgressView {
    
    func delayProcess() {
        
        let progressValue:Float = Float(String(format: "%.1f", progress))!
        
        if progressValue == 1.0 {
            progress = 0.0
            self.delegate?.didCompleteProgress()
        }else {
            progress = progress+0.1
            self.perform(#selector(delayProcess), with: nil, afterDelay: 0.1)
        }
        
        print("Progress:\(progress)")
        
    }
    
    func didBeginProgress() {
        delayProcess()
    }
    
}

