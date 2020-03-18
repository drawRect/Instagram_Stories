//
//  IGSnapProgressView.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/15/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

enum ProgressorState {
    case notStarted
    case paused
    case running
    case finished
}
protocol ViewAnimator: class {
    func start(with duration: TimeInterval,
               holderView: UIView,
               completion: @escaping (
        _ storyIdentifier: String,
        _ snapIndex: Int,
        _ isCancelledAbruptly: Bool
        ) -> Void)
    func resume()
    func pause()
    func stop()
    func reset()
}
extension ViewAnimator where Self: IGSnapProgressView {
    func start(with duration: TimeInterval,
               holderView: UIView,
               completion: @escaping (
        _ storyIdentifier: String,
        _ snapIndex: Int,
        _ isCancelledAbruptly: Bool
        ) -> Void
    ) {
        // Modifying the existing widthConstraint and setting the width equalTo holderView's widthAchor
        self.state = .running
        self.widthConstraint?.isActive = false
        self.widthConstraint = self.widthAnchor.constraint(equalToConstant: 0)
        self.widthConstraint?.isActive = true
        self.widthConstraint?.constant = holderView.igWidth
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [.curveLinear],
            animations: {
                [weak self] in
                self?.superview?.layoutIfNeeded()
            },
            completion: { [weak self] (finished) in
                self?.story.isCancelledAbruptly = !finished
                self?.state = .finished
                return completion(self?.storyIdentifier ?? "Unknown",
                                  self?.snapIndex ?? 0,
                                  self?.story.isCancelledAbruptly ?? true)
        })
    }
    func resume() {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
        state = .running
    }
    func pause() {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
        state = .paused
    }
    func stop() {
        resume()
        layer.removeAllAnimations()
        state = .finished
    }
    func reset() {
        state = .notStarted
        self.story.isCancelledAbruptly = true
        self.widthConstraint?.isActive = false
        self.widthConstraint = self.widthAnchor.constraint(equalToConstant: 0)
        self.widthConstraint?.isActive = true
    }
}

final class IGSnapProgressView: UIView, ViewAnimator {
    public var storyIdentifier: String?
    public var snapIndex: Int?
    public var story: IGStory!
    public var widthConstraint: NSLayoutConstraint?
    public var state: ProgressorState = .notStarted
}
