//
//  CubeAttributesAnimator.swift
//  AnimatedCollectionViewLayout
//
//  Created by Jin Wang on 8/2/17.
//  Copyright © 2017 Uthoft. All rights reserved.
//

import UIKit

/// An animator that applies a cube transition effect when you scroll.
public struct CubeAttributesAnimator: LayoutAttributesAnimator {
    /// The perspective that will be applied to the cells. Must be negative. -1/500 by default.
    /// Recommended range [-1/2000, -1/200].
    public var perspective: CGFloat
    
    /// The higher the angle is, the _steeper_ the cell would be when transforming.
    public var totalAngle: CGFloat
    
    public init(perspective: CGFloat = -1 / 500, totalAngle: CGFloat = .pi / 2) {
        self.perspective = perspective
        self.totalAngle = totalAngle
    }
    
    public func animate(collectionView: UICollectionView, attributes: AnimatedCollectionViewLayoutAttributes) {
        let position = attributes.middleOffset
        if abs(position) >= 1 {
            attributes.contentView?.layer.transform = CATransform3DIdentity
        } else if attributes.scrollDirection == .horizontal {
            let rotateAngle = totalAngle * position
            var transform = CATransform3DIdentity
            transform.m34 = perspective
            transform = CATransform3DRotate(transform, rotateAngle, 0, 1, 0)
            /* Handling collectionView's contentView transform animation
             * Setting contentView's subview's first which is scrollView UserInteractionEnabled = false
             * Then checking the completion status. If false then again setting UserInteractionEnabled = false
             * Otherwise setting UserInteractionEnabled = true.
             * Until animation completes, UIView Animation completion block will be called continuously.
             * If animation completed will get status value as true otherwise false
             */
            UIView.animate(withDuration: 0.3, animations: {
                attributes.contentView?.subviews.first?.isUserInteractionEnabled = false
                attributes.contentView?.layer.transform = transform
            }) {
                attributes.contentView?.subviews.first?.isUserInteractionEnabled = $0
            }
            attributes.contentView?.keepCenterAndApplyAnchorPoint(CGPoint(x: position > 0 ? 0 : 1, y: 0.5))
        } else {
            let rotateAngle = totalAngle * position
            var transform = CATransform3DIdentity
            transform.m34 = perspective
            transform = CATransform3DRotate(transform, rotateAngle, -1, 0, 0)
            /* Handling collectionView's contentView transform animation
             * Setting contentView's subview's first which is scrollView UserInteractionEnabled = false
             * Then checking the completion status. If false then again setting UserInteractionEnabled = false
             * Otherwise setting UserInteractionEnabled = true.
             * Until animation completes, UIView Animation completion block will be called continuously.
             * If animation completed will get status value as true otherwise false
             */
            UIView.animate(withDuration: 0.3, animations: {
                attributes.contentView?.subviews.first?.isUserInteractionEnabled = false
                attributes.contentView?.layer.transform = transform
            }) {
                attributes.contentView?.subviews.first?.isUserInteractionEnabled = $0
            }
            attributes.contentView?.keepCenterAndApplyAnchorPoint(CGPoint(x: 0.5, y: position > 0 ? 0 : 1))
        }
    }
}
