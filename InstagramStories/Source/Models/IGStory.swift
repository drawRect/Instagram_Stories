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
    private var snaps: [IGSnap]
    
    // To carry forwarding non-deleted snaps.
    public var nonDeletedSnaps: [IGSnap] {
        return snaps.filter{!($0.isDeleted)}
    }
    public var id: String
    public var lastUpdated: Int
    public var user: IGUser
    var lastPlayedSnapIndex = 0
    var isCompletelyVisible = false
    var isCancelledAbruptly = false
    
    enum CodingKeys: String, CodingKey {
        case snaps = "snaps"
        case id = "id"
        case lastUpdated = "last_updated"
        case user = "user"
    }
    
}

extension IGStory: Equatable {
    public static func == (lhs: IGStory, rhs: IGStory) -> Bool {
        return lhs.id == rhs.id
    }
}



