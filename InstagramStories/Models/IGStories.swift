//
//  IGStories.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/8/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct IGStories {
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kIGStoriesCountKey: String = "count"
    private let kIGStoriesStoriesKey: String = "stories"
    private let kIGStoriesInternalIdentifierKey: String = "id"
    
    // MARK: Properties
    public var count: Int?
    public var stories: [IGStory]?
    public var internalIdentifier: Int?
    
    // MARK: SwiftyJSON Initalizers
    /**
     Initates the instance based on the object
     - parameter object: The object of either Dictionary or Array kind that was passed.
     - returns: An initalized instance of the class.
     */
    public init(object: Any) {
        self.init(json: JSON(object))
    }
    
    /**
     Initates the instance based on the JSON that was passed.
     - parameter json: JSON object from SwiftyJSON.
     - returns: An initalized instance of the class.
     */
    public init(json: JSON) {
        count = json[kIGStoriesCountKey].int
        if let items = json[kIGStoriesStoriesKey].array { stories = items.map { IGStory(json: $0) } }
        internalIdentifier = json[kIGStoriesInternalIdentifierKey].int
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = count { dictionary[kIGStoriesCountKey] = value }
        if let value = stories { dictionary[kIGStoriesStoriesKey] = value.map { $0.dictionaryRepresentation() } }
        if let value = internalIdentifier { dictionary[kIGStoriesInternalIdentifierKey] = value }
        return dictionary
    }

}
