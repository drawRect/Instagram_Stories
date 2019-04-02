//
//  IGErrors.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 02/04/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation

public enum IGImageError: String, Error {
    case invalidImageURL = "Invalid Image URL"
}
public enum IGDownloadError: String, Error {
    case error = "Unable to download image"
}
