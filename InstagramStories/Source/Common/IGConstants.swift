//
//  IGConstants.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/24/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

public struct IGScreen {
    /**UIScreen.main.bounds.width*/
    static let width = UIScreen.main.bounds.width
    /**UIScreen.main.bounds.height*/
    static let height = UIScreen.main.bounds.height
    
    private init() {}
}

//Referring the Instagram Theme colors
//https://www.designpieces.com/palette/instagram-new-logo-2016-color-palette/
public struct IGTheme {
    //Instagram Red Orange
    static let redOrange = UIColor(rgb: 0xe95950)
    
    private init() {}
}
