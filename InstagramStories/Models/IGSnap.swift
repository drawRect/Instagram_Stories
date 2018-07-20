//
//  IGSnap.swift
//
//  Created by Ranjith Kumar on 9/28/17
//  Copyright (c) Dash. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum MimeType: String {
    case image
    case video
    case unknown
}

public struct IGSnap {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kIGSnapInternalIdentifierKey: String = "id"
    private let kIGSnapMimeTypeKey: String = "mime_type"
    private let kIGSnapLastUpdatedKey: String = "last_updated"
    private let kIGSnapUrlKey: String = "url"
    
    // MARK: Properties
    public var internalIdentifier: String?
    private var mimeType: String?
    public var lastUpdated: String?
    public var url: String?
    public var kind: MimeType {
        if let type = mimeType {
            switch type {
            case MimeType.image.rawValue:
                return MimeType.image
            case MimeType.video.rawValue:
                return MimeType.video
            default:
                return MimeType.unknown
            }
        }
        return MimeType.unknown
    }
    
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
        internalIdentifier = json[kIGSnapInternalIdentifierKey].string
        mimeType = json[kIGSnapMimeTypeKey].string
        lastUpdated = json[kIGSnapLastUpdatedKey].string
        url = json[kIGSnapUrlKey].string
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = internalIdentifier { dictionary[kIGSnapInternalIdentifierKey] = value }
        if let value = mimeType { dictionary[kIGSnapMimeTypeKey] = value }
        if let value = lastUpdated { dictionary[kIGSnapLastUpdatedKey] = value }
        if let value = url { dictionary[kIGSnapUrlKey] = value }
        return dictionary
    }
    
}



