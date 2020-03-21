//
//  IGImageLoadError.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 02/04/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation

/**
This is an enumeration of the type of image error when we load it from 'remote'
*/
public enum IGImageLoadError: Error, CustomStringConvertible {
    /// It throws when we found its invalid image url
    case invalidImageURL
    /// It throws when image is not able to download it from the internet
    case downloadError

    public var description: String {
        switch self {
        case .invalidImageURL: return "Invalid Image URL"
        case .downloadError: return "Unable to download image"
        }
    }
}
