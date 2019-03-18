//
//  IGStories.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/8/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import Foundation

public class IGStories: Codable {
    public let count: Int
    public let stories: [IGStory]
    
    enum CodingKeys: String, CodingKey {
        case count = "count"
        case stories = "stories"
    }
    func copy() throws -> IGStories {
        let data = try JSONEncoder().encode(self)
        let copy = try JSONDecoder().decode(IGStories.self, from: data)
        return copy
    }
}
