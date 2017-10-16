//
//  IGStory.swift
//
//  Created by Ranjith Kumar on 9/8/17
//  Copyright (c) Dash. All rights reserved.
//

import Foundation
import SwiftyJSON

public class IGStory {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kIGStorySnapsCountKey: String = "snaps_count"
    private let kIGStorySnapsKey: String = "snaps"
    private let kIGStoryInternalIdentifierKey: String = "id"
    private let kIGStoryLastUpdatedKey: String = "last_updated"
    private let kIGStoryUserKey: String = "user"
    
    // MARK: Properties
    public var snapsCount: Int?
    public var snaps: [IGSnap]?
    public var internalIdentifier: String?
    public var lastUpdated: Int?
    public var user:IGUser?
    private var _lastPlayedSnap:Int = 0
    // MARK: SwiftyJSON Initalizers
    /**
     Initates the instance based on the object
     - parameter object: The object of either Dictionary or Array kind that was passed.
     - returns: An initalized instance of the class.
     */
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    
    /**
     Initates the instance based on the JSON that was passed.
     - parameter json: JSON object from SwiftyJSON.
     - returns: An initalized instance of the class.
     */
    public init(json: JSON) {
        snapsCount = json[kIGStorySnapsCountKey].int
        if let items = json[kIGStorySnapsKey].array { snaps = items.map { IGSnap(json: $0) } }
        internalIdentifier = json[kIGStoryInternalIdentifierKey].string
        lastUpdated = json[kIGStoryLastUpdatedKey].int
        user = IGUser.init(json: json[kIGStoryUserKey])
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = snapsCount { dictionary[kIGStorySnapsCountKey] = value }
        if let value = snaps { dictionary[kIGStorySnapsKey] = value.map { $0.dictionaryRepresentation() } }
        if let value = internalIdentifier { dictionary[kIGStoryInternalIdentifierKey] = value }
        if let value = lastUpdated { dictionary[kIGStoryLastUpdatedKey] = value }
        if let value = user {dictionary[kIGStoryUserKey] = value}
        return dictionary
    }
    
}


