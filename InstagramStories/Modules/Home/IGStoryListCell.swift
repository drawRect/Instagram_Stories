//
//  IGStoryListCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

final class IGStoryListCell: UICollectionViewCell {
    // MARK: Public iVars
    public var story: IGStory? {
        didSet {
            self.profileNameLabel.text = story?.user.name
            if let picture = story?.user.picture {
                profileImageView.imageView.setImage(url: picture, style: .rounded) { (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let image):
                            self.profileImageView.imageView.image = image
                        case .failure(let error):
                            debugPrint("image load erro:\(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
//    public var userDetails: (String, String)? {
//        didSet {
//            if let details = userDetails {
//                self.profileNameLabel.text = details.0
//                profileImageView.imageView.setImage(url: details.1, style: .rounded) { (result) in
//                    DispatchQueue.main.async {
//                        switch result {
//                        case .success(let image):
//                            self.profileImageView.imageView.image = image
//                        case .failure(let error):
//                            debugPrint("image load erro:\(error.localizedDescription)")
//                        }
//                    }
//                }
//            }
//        }
//    }
    // MARK: Private ivars
    private let profileImageView: IGRoundedView = {
        let roundedView = IGRoundedView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        return roundedView
    }()
    private let profileNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    // MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: Private functions
    private func loadUIElements() {
        addSubview(profileImageView)
        addSubview(profileNameLabel)
    }
    private func installLayoutConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 68),
            profileImageView.heightAnchor.constraint(equalToConstant: 68),
            profileImageView.igTopAnchor.constraint(equalTo: self.igTopAnchor, constant: 8),
            profileImageView.igCenterXAnchor.constraint(equalTo: self.igCenterXAnchor)])

        NSLayoutConstraint.activate([
            profileNameLabel.igLeftAnchor.constraint(equalTo: self.igLeftAnchor),
            profileNameLabel.igRightAnchor.constraint(equalTo: self.igRightAnchor),
            profileNameLabel.igTopAnchor.constraint(equalTo: self.profileImageView.igBottomAnchor, constant: 2),
            profileNameLabel.igCenterXAnchor.constraint(equalTo: self.igCenterXAnchor),
            self.igBottomAnchor.constraint(equalTo: profileNameLabel.igBottomAnchor, constant: 8)])
        layoutIfNeeded()
    }
}
