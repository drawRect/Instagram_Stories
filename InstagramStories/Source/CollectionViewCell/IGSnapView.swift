//
//  IGSnapView.swift
//  InstagramStories
//
//  Created by Kumar, Ranjith B. (623-Extern) on 12/04/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation
import UIKit

class IGSnapView: UIView {
    let snap: IGSnap
    var children: IGXView? = nil
    
    init(frame: CGRect, snap: IGSnap) {
        self.snap = snap
        super.init(frame: frame)
        switch snap.mimeType {
        case MimeType.image.rawValue:
            let contentView: IGXView = IGImageView(frame: bounds, snap: snap)
            addSubview(contentView)
            children = contentView
        case MimeType.video.rawValue:
            let contentView: IGXView = IGVideoView(frame: bounds, snap: snap)
            addSubview(contentView)
            children = contentView
        case MimeType.unknown.rawValue:
            fatalError("Unknown type Snap found\(snap)")
            break
        default:
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
