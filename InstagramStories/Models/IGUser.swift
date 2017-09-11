//
//  IGUser.swift
//
//  Created by Ranjith Kumar on 9/8/17
//  Copyright (c) Dash. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct IGUser {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kIGUserInternalIdentifierKey: String = "id"
  private let kIGUserNameKey: String = "name"
  private let kIGUserPictureKey: String = "picture"

  // MARK: Properties
  public var internalIdentifier: String?
  public var name: String?
  public var picture: String?

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
    internalIdentifier = json[kIGUserInternalIdentifierKey].string
    name = json[kIGUserNameKey].string
    picture = json[kIGUserPictureKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = internalIdentifier { dictionary[kIGUserInternalIdentifierKey] = value }
    if let value = name { dictionary[kIGUserNameKey] = value }
    if let value = picture { dictionary[kIGUserPictureKey] = value }
    return dictionary
  }

}
