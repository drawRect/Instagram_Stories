//
//  IGHomeController.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

final class IGHomeController: UIViewController {
    
     lazy var storiesCollectionView: UICollectionView = {
        //setting the flowlayout for collectionView
        let storyFlowLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        storyFlowLayout.scrollDirection = .horizontal
        storyFlowLayout.itemSize = CGSize(width: 100, height: 100)
        
        //setting the properties for collectionview
        let storyCV:UICollectionView = UICollectionView(frame: view.frame, collectionViewLayout: storyFlowLayout)
            storyCV.delegate = self
            storyCV.dataSource = self
            storyCV.backgroundColor = .white
        storyCV.showsVerticalScrollIndicator = false
        storyCV.showsHorizontalScrollIndicator = false
            storyCV.register(IGStoryListCell.nib(), forCellWithReuseIdentifier: IGStoryListCell.reuseIdentifier())
            storyCV.register(IGAddStoryCell.nib(), forCellWithReuseIdentifier: IGAddStoryCell.reuseIdentifier())
            storyCV.translatesAutoresizingMaskIntoConstraints = false
            automaticallyAdjustsScrollViewInsets = false
        return storyCV
    }()
    
    //Keep it Immutable! don't get Dirty :P
    let stories:IGStories? = {
        do {
            return try IGMockLoader.loadMockFile(named: "stories.json",bundle:.main)
        } catch let e as MockLoaderError{
            e.desc()
        }catch{
            debugPrint("could not read Mock json file :(")
        }
        return nil
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .white
        view.addSubview(storiesCollectionView)
        setupLayout()
    }
    
    func setupLayout(){
        storiesCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        storiesCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        storiesCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        storiesCollectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}

extension IGHomeController:UICollectionViewDelegate,UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = stories?.count {
            return count + 1 // Add Story cell
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGAddStoryCell.reuseIdentifier(),for: indexPath) as? IGAddStoryCell else { return UICollectionViewCell() }
            return cell
        }else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryListCell.reuseIdentifier(),for: indexPath) as? IGStoryListCell else { return UICollectionViewCell() }
            // Add Story cell
            cell.story = stories?.stories?[indexPath.row-1]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //Add your own story
            debugPrint("Need to implement!")
        }else{
            let storyPreviewScene = IGStoryPreviewController.init(stories: stories!, handPickedStoryIndex: indexPath.row-1)
            present(storyPreviewScene, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.row == 0 ? CGSize(width: 100, height: 100) : CGSize(width: 80, height: 100)
    }
}
