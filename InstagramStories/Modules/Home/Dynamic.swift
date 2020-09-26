//
//  Dynamic.swift
//  InstagramStories
//
//  Created by Ranjit on 26/09/20.
//  Copyright © 2020 DrawRect. All rights reserved.
//

///This Dynamic helper class help us to build the MVVM Architecture.
final class Dynamic<T> {
    typealias Listener = (T)
    
    var value: Listener? {
        didSet {
            observer?(value)
        }
    }
    var observer:((Listener?) -> Void)?

    func bind(observer:@escaping ((Listener?) -> Void)) {
        self.observer = observer
    }
}

