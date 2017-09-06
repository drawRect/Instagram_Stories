//
//  StoryViewController.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

struct StoryConstants {
    static let snapTime:Double = 1.0
}

class IGStoryPreviewController: UIViewController {

    public var stories:[IGStory]?
    private var storyIndex:Int = 0
    var headerView:IGStoryPreviewHeaderView?
    private var snapTimer:Timer?
    
    @IBOutlet weak var storyPreview: UIView! {
        didSet {
            headerView = IGStoryPreviewHeaderView.instanceFromNib()
            headerView?.delegate = self
            storyPreview.addSubview(headerView!)
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
        headerView?.stories = stories
        snapTimer = Timer.scheduledTimer(timeInterval: StoryConstants.snapTime, target: self, selector: #selector(IGStoryPreviewController.didMoveNextSnap), userInfo: nil, repeats: true)
    }
    
    //MARK: - Selectors
    func didMoveNextSnap(){
        guard let stories = stories else {
            return
        }
        storyIndex = storyIndex+1
        if storyIndex == stories.count-1 {
            snapTimer?.invalidate()
            return
        }
        if storyIndex<stories.count{
            let indexPath = IndexPath.init(row: storyIndex, section: 0)
            collectionview.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    //MARK: -
    deinit {
        snapTimer?.invalidate()
    }

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
