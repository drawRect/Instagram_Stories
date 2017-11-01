//
//  IGStoryPreviewController.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout

public enum layoutType {
    case crossFade,cubic,linearCard,page,parallax,rotateInOut,snapIn,zoomInOut
    var animator:LayoutAttributesAnimator {
        switch self {
        case .crossFade:return CrossFadeAttributesAnimator()
        case .cubic:return CubeAttributesAnimator()
        case .linearCard:return LinearCardAttributesAnimator()
        case .page:return PageAttributesAnimator()
        case .parallax:return ParallaxAttributesAnimator()
        case .rotateInOut:return RotateInOutAttributesAnimator()
        case .snapIn:return SnapInAttributesAnimator()
        case .zoomInOut:return ZoomInOutAttributesAnimator()
        }
    }
}

/**Road-Map: Story(CollectionView)->Cell(ScrollView(nImageViews:Snaps))
 If Story.Starts -> Snap.Index(Captured|StartsWith.0)
 While Snap.done->Next.snap(continues)->done
 then Story Completed
 */
final class IGStoryPreviewController: UIViewController,UIGestureRecognizerDelegate {
    
    //MARK: - iVars
    private(set) var stories:IGStories
    /** This index will tell you which Story, user has picked*/
    private(set) var handPickedStoryIndex:Int //starts with(i)
    /** This index will help you simply iterate the story one by one*/
    private var nStoryIndex:Int = 0 //iteration(i+1)
    //public weak var storyPreviewHelperDelegate:pastStoryClearer?
    private(set) var layoutType:layoutType
    
    /**Layout Animate options(ie.choose which kinda animation you want!)*/
    private(set) lazy var layoutAnimator: (LayoutAttributesAnimator, Bool, Int, Int) = (layoutType.animator, true, 1, 1)
    
    let dismissGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .down
        return gesture
    }()
    
    lazy var snapsCollectionView: UICollectionView = {
        //Setting the Layout
        let flowLayout = AnimatedCollectionViewLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 100, height: 100)
        flowLayout.animator = (CubeAttributesAnimator(), true, 1, 1) as? LayoutAttributesAnimator
        
        //setting the properties for collectionview
        let cv:UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        cv.backgroundColor = .black
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(IGStoryPreviewCell.self, forCellWithReuseIdentifier: IGStoryPreviewCell.reuseIdentifier())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.isPrefetchingEnabled = false
        
        if let layout = cv.collectionViewLayout as? AnimatedCollectionViewLayout {
            layout.scrollDirection = .horizontal
            layout.animator = layoutAnimator.0
        }
        return cv
    }()
    
    func loadUIElements(){
        view.backgroundColor = .white
        dismissGesture.addTarget(self, action: #selector(didSwipeDown(_:)))
    
        snapsCollectionView.addGestureRecognizer(dismissGesture)
        snapsCollectionView.delegate = self
        snapsCollectionView.dataSource = self
        view.addSubview(snapsCollectionView)
    }
    
    func installLayoutConstraints(){
        //Setting constraints for snapsCollectionview
        snapsCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        snapsCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        snapsCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        snapsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    //MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUIElements()
        installLayoutConstraints()
    }

    init(layout:layoutType = .cubic,stories:IGStories,handPickedStoryIndex:Int) {
        self.layoutType = layout
        self.stories = stories
        self.handPickedStoryIndex = handPickedStoryIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    //MARK: - Selectors
    @objc func didSwipeDown(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension IGStoryPreviewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = stories.count {
            return count-handPickedStoryIndex
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryPreviewCell.reuseIdentifier(), for: indexPath) as? IGStoryPreviewCell else{return UICollectionViewCell()}
        let counted = handPickedStoryIndex+indexPath.item
        if let count = stories.count {
            if counted < count {
                let story = stories.stories?[counted]
                cell.story = story
                cell.delegate = self
            }else {
                fatalError("Stories Index mis-matched :(")
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? IGStoryPreviewCell {
            cell.willDisplayCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? IGStoryPreviewCell {
            cell.didEndDisplayingCell()
        }else {fatalError()}
    }
   
}

extension IGStoryPreviewController:StoryPreviewProtocol {
    func didCompletePreview() {
        let n = handPickedStoryIndex+nStoryIndex+1
        if let count = stories.count {
            if n < count {
                //Move to next story
                nStoryIndex = nStoryIndex + 1
                let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
                snapsCollectionView.scrollToItem(at: nIndexPath, at: .right, animated: true)
            }else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    func didTapCloseButton() {
        self.dismiss(animated: true, completion:nil)
    }
}
