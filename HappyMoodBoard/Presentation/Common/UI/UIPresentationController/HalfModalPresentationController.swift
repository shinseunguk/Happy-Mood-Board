//
//  HalfModalPresentationController.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 1/5/24.
//

import UIKit

final class HalfModalPresentationController: UIPresentationController {
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return CGRect.zero }
        let height = containerView.frame.height / 3.0
        return CGRect(x: 0, y: containerView.frame.height - height, width: containerView.frame.width, height: height)
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
}

final class CustomPresentationController: UIPresentationController {
    
    private lazy var dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = .init(white: 0, alpha: 0.5)
        dimmingView.alpha = 0
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap(recognizer:))
        )
        dimmingView.addGestureRecognizer(recognizer)
        return dimmingView
    }()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        
        var frame: CGRect = .zero
        frame.size = size(
            forChildContentContainer: presentedViewController,
            withParentContainerSize: containerView.bounds.size
        )
        
        frame.origin.y = containerView.frame.height * (2.0/3.0)
        return frame
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }
        containerView.insertSubview(dimmingView, at: 0)
        
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = 16
    }
    
    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: parentSize.height * (1.0/3.0))
    }
}

private extension CustomPresentationController {
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
    
}
