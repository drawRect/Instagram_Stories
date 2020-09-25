//
//  IGHomeController.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

fileprivate let isClearCacheEnabled = true
internal var isDeleteSnapEnabled = true

final class IGHomeController: UIViewController {
    
    //MARK: - iVars
    private var _view: IGHomeView { return view as! IGHomeView }
    private var viewModel: IGHomeViewModel = IGHomeViewModel(stories: Bundle.main.decode("stories.json"))
    
    //MARK: - Overridden functions
    override func loadView() {
        super.loadView()
        view = IGHomeView(frame: UIScreen.main.bounds)
        _view.collectionView.delegate = self
        _view.collectionView.dataSource = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        viewModelObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override var navigationItem: UINavigationItem {
        let navigationItem = UINavigationItem()
        navigationItem.titleView = UIImageView(image: UIImage(named: "Logo"))
        if isClearCacheEnabled {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .done, target: self, action: #selector(clearImageCache))
        }
        return navigationItem
    }
    
    //MARK: - Private functions
    private func viewModelObservers() {
        self.viewModel.showAlertMsg.bind {
            if let msg = $0 {
                self.showAlert(withMsg: msg)
            }
        }
        self.viewModel.presentPreviewScreen.bind {
            if let controller = $0 {
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    @objc private func clearImageCache() {
        IGCache.shared.removeAllObjects()
        IGStories.removeAllVideoFilesFromCache()
        showAlert(withMsg: "Images & Videos are deleted from cache")
    }
    
}

//MARK: - UICollectionViewDataSource
extension IGHomeController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.register(IGAddStoryCell.self, indexPath: indexPath)
            cell.userDetails = ("Your story","https://avatars2.githubusercontent.com/u/32802714?s=200&v=4")
            return cell
        } else {
            let cell =  collectionView.register(IGStoryListCell.self, indexPath: indexPath)
            cell.story = viewModel.cellForItemAt(indexPath: indexPath)
            return cell
        }
    }
}

//MARK: - UICollectionViewDelegate
extension IGHomeController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItemAt(indexPath: indexPath)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension IGHomeController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemSize: CGSize!
        if indexPath.row == 0 {
            itemSize = CGSize(width: 100, height: 100)
        }  else {
            itemSize = CGSize(width: 80, height: 100)
        }
        return itemSize
    }
}
