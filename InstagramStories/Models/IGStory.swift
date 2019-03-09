//
//  IGStory.swift
//
//  Created by Ranjith Kumar on 9/8/17
//  Copyright (c) Dash. All rights reserved.
//

import Foundation

public class IGStory: Decodable {
    // Note: To retain lastPlayedSnapIndex value for each story making this type as class
    public let snapsCount: Int
    public let snaps: [IGSnap]
    public let internalIdentifier: String
    public let lastUpdated: Int
    public let user: IGUser
    var lastPlayedSnapIndex = 0
    var isCompletelyVisible = false
    var isCancelledAbruptly = false
    
    enum CodingKeys: String, CodingKey {
        case snapsCount = "snaps_count"
        case snaps = "snaps"
        case internalIdentifier = "id"
        case lastUpdated = "last_updated"
        case user = "user"
    }
}

extension IGStory: Equatable {
    public static func == (lhs: IGStory, rhs: IGStory) -> Bool {
        return lhs.internalIdentifier == rhs.internalIdentifier
    }
}
