//
//  IGStories.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/8/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import Foundation

public struct IGStories: Decodable {
    public var count: Int
    public var stories: [IGStory]
    
    enum CodingKeys: String, CodingKey {
        case count = "count"
        case stories = "stories"
    }
}
