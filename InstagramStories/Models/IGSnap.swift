//
//  IGSnap.swift
//
//  Created by Ranjith Kumar on 9/8/17
//  Copyright (c) Dash. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct IGSnap {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kIGSnapInternalIdentifierKey: String = "id"
  private let kIGSnapTypeKey: String = "type"
  private let kIGSnapMediaURLKey: String = "mediaURL"

  // MARK: Properties
  public var internalIdentifier: Int?
  public var type: String?
  public var mediaURL: String?

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
    internalIdentifier = json[kIGSnapInternalIdentifierKey].int
    type = json[kIGSnapTypeKey].string
    mediaURL = json[kIGSnapMediaURLKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = internalIdentifier { dictionary[kIGSnapInternalIdentifierKey] = value }
    if let value = type { dictionary[kIGSnapTypeKey] = value }
    if let value = mediaURL { dictionary[kIGSnapMediaURLKey] = value }
    return dictionary
  }

}
