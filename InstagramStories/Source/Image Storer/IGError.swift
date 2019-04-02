//
//  IGErrors.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 02/04/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation

public enum IGError: Error {
    case invalidImageURL
    case downloadError
    var debugDescription: String {
        switch self {
        case .invalidImageURL:
            return "Invalid Image URL"
        case .downloadError:
            return "Unable to download image"
        }
    }
}
