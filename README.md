<p align="center">
    <img src="logo.png" width="480” max-width="90%" alt="Instagram Stories" />
</p>
                                                                           
<p align="center">
     <img src="https://img.shields.io/cocoapods/l/BadgeSwift.svg?style=flat" />
    <img src="https://img.shields.io/badge/language-Swift%205.0-orange.svg" />
    <img src="https://img.shields.io/badge/platforms-iOS-cc9c00.svg" />
</p>


## Screenshots

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/cbf93e2e9c2c4032a1cbe7aee31a2db5)](https://app.codacy.com/gh/drawRect/Instagram_Stories?utm_source=github.com&utm_medium=referral&utm_content=drawRect/Instagram_Stories&utm_campaign=Badge_Grade_Dashboard)

<img src="https://github.com/drawRect/Instagram_Stories/blob/master/InstagramStories/Sample%20Screenshots/ig_home.png" width="233" height="483"> <img src="https://github.com/drawRect/Instagram_Stories/blob/master/InstagramStories/Sample%20Screenshots/snap_delete.png" width="233" height="483"> <img src="https://github.com/drawRect/Instagram_Stories/blob/master/InstagramStories/Sample%20Screenshots/demo.gif" width="233" height="483"> <img src="https://github.com/drawRect/Instagram_Stories/blob/master/InstagramStories/Sample%20Screenshots/xr-2.png" width="233" height="483">

## Features
* Supports portrait orientation(only) in iPhone and all orientations on iPad.
* Image Support
* Video Support
* Long press pause and play
* Manual swipe between stories
* Left tap and Right-tap gestures to switch between snaps and stories
* If there is no user interruption, it will automatically move to the next snap or next story, once the progress bar completes.
* Image caching handled using NSCache.
* Video caching is handled in the documents directory using FileManager.
* Users can define the snap index, from where they want to start the snap by setting the **handPickedSnapIndex** value. In IGHomeController, when instantiating IGStoryPreviewController user can set this value. The below code is just reference and it has been written in IGHomeController.
    
    `let storyPreviewScene = IGStoryPreviewController.init(stories: stories_copy, handPickedStoryIndex: indexPath.row-1,  handPickedSnapIndex: 2)`
* Delete snap
* Clear Image & Video Caches

## How To Use
* Open the project(Instagram_Stories) folder. You can find the Source folder inside.
* Drag and drop the **Source** folder into your project.
* In your project, use the same **IGStoryPreviewController**.
* But do not change the default code that we have written in IGStoryPreviewController. You can add code on top of that.
* Also do not change the collectionView custom cell. Use the same **IGStoryPreviewCell**.
* Because all the functionalities are handled in the IGStoryPreviewCell only.
* If there is any issue or don't know how to configure the Source folder on your project, please raise Github's issues. We will reply as soon as possible.

## Requirements
* iOS 10
* Xcode 8

### Swift v4.2: https://github.com/drawRect/Instagram_Stories/tree/Swift-v4.2

## We
* Hi! We are two people joined together and spent weekends and free time to make this repo as an example of how Instagram stories built in our assumption.
* Ranjith(https://github.com/ranmyfriend), Boominadha Prakash(https://github.com/boominadhaprakash)

## Contributing
* If you like this repository, please do :star: to make this useful for others.
* Feel free to contribute by [open an Issue](https://github.com/drawRect/Instagram_Stories/issues/new/choose) or [create a Pull Request](https://github.com/drawRect/Instagram_Stories/pull/new)

## License

All the code here is under MIT license. Which means you could do virtually anything with the code.
I will appreciate it very much if you keep an attribution where appropriate.

    The MIT License (MIT)
    
    Copyright (c) 2013 ranjit (ranjithkumar2010a@live.com)
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
