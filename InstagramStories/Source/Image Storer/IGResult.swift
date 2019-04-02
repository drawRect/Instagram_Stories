//
//  Result.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 02/04/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation

public enum IGResult<V, E> {
    case success(V)
    case failure(E)
}
