//
//  IGHomeViewModel.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 01/11/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import Foundation

class IGHomeViewModel:NSObject{
    
    //Keep it Immutable! don't get Dirty :P
    private let stories:IGStories? = {
        do {
            return try IGMockLoader.loadMockFile(named: "stories.json",bundle:.main)
        } catch let e as MockLoaderError{
            e.desc()
        }catch{
            debugPrint("could not read Mock json file :(")
        }
        return nil
    }()
    public func getStories()->IGStories? {
        return stories
    }
    
    public func numberOfItemsInSection(_ section:Int)->Int {
        if let count = stories?.count {
            return count + 1 // Add Story cell
        }
        return 1
    }
    public func cellForItemAt(indexPath:IndexPath)->IGStory? {
        return stories?.stories?[indexPath.row-1]
    }
    
}
