//
//  IGSetImage.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 02/04/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation
import UIKit

public typealias ImageResponse = (IGResult<UIImage, Error>) -> Void

protocol IGSetImage {
    func ig_setImage(urlString: String, completionBlock: ImageResponse?)
    func ig_setImage(urlString: String, placeHolderImage: UIImage?, completionBlock: ImageResponse?)
}
