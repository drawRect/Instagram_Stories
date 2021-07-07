//
//  IGStory.swift
//
//  Created by Ranjith Kumar on 9/8/17
//  Copyright (c) DrawRect. All rights reserved.
//

import Foundation

public class IGStory: Codable {
    // Note: To retain lastPlayedSnapIndex value for each story making this type as class
    public var snapsCount: Int {
        return snaps.count
    }
    
    // To hold the json snaps.
    private var _snaps: [IGSnap]
    
    // To carry forwarding non-deleted snaps.
    public var snaps: [IGSnap] {
        return _snaps.filter{!($0.isDeleted)}
    }
    public var internalIdentifier: String
    public var lastUpdated: Int
    public var user: IGUser
    var lastPlayedSnapIndex = 0
    var isCompletelyVisible = false
    var isCancelledAbruptly = false
    
    enum CodingKeys: String, CodingKey {
        //case snapsCount = "snaps_count"
        case _snaps = "snaps"
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
