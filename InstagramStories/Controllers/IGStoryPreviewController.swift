//
//  StoryViewController.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

struct StoryConstants {
    static let snapTime:Double = 5.0
}

class IGStoryPreviewController: UIViewController {

    lazy var snapTimer = Timer.scheduledTimer(timeInterval: StoryConstants.snapTime, target: self, selector: #selector(IGStoryPreviewController.didMoveNextSnap), userInfo: nil, repeats: false)
    public var stories:[IGStory]?
    private var storyIndex:Int = 0
   
    @IBOutlet weak var storyPreview: UIView! {
        didSet {
            let iv = IGStoryPreviewHeaderView.instanceFromNib()
            iv.delegate = self
            storyPreview.addSubview(iv)
        }
    }
    
    @IBOutlet weak var collectionview: UICollectionView! {
        didSet {
            collectionview.delegate = self
            collectionview.dataSource = self
            let storyNib = UINib.init(nibName: IGStoryPreviewCell.reuseIdentifier(), bundle: nil)
            collectionview.register(storyNib, forCellWithReuseIdentifier: IGStoryPreviewCell.reuseIdentifier())
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Story"
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    //MARK: - Selectors
    func didMoveNextSnap(){
        guard let stories = stories else {
            return
        }
        storyIndex = storyIndex + 1
        if storyIndex <= stories.count-1{
            let indexPath = IndexPath.init(row: storyIndex, section: 0)
            collectionview.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            snapTimer.fire()
        }
    }
    //MARK: -

}

extension IGStoryPreviewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryPreviewCell.reuseIdentifier(), for: indexPath) as! IGStoryPreviewCell
        cell.imageview.image = stories?[indexPath.row].snap
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
}

extension IGStoryPreviewController:StoryPreviewHeaderTapper {
    func didTapCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
