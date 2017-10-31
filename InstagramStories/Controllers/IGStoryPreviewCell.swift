//
//  IGStoryPreviewCell.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

final class IGStoryPreviewCell: UICollectionViewCell {
    
    
    //MARK: - Overriden functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(IGStoryPreviewView(frame:contentView.frame))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
