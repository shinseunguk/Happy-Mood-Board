//
//  PartialViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/31.
//

import UIKit

open class PartialViewController: UIViewController {
    
    private let direction: PartialPresentationController.Direction
    private let viewSize: PartialPresentationController.SizePair
    private let isSwipeEnabled: Bool
    
    public init(
        direction: PartialPresentationController.Direction,
        viewSize: PartialPresentationController.SizePair,
        isSwipeEnabled: Bool = true
    ) {
        self.direction = direction
        self.viewSize = viewSize
        self.isSwipeEnabled = isSwipeEnabled
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        transitioningDelegate = self    
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("All UIs are code based, not nib.")
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate

extension PartialViewController: UIViewControllerTransitioningDelegate {
    
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        return PartialPresentationController(
            direction: direction,
            viewSize: viewSize,
            isSwipeEnabled: isSwipeEnabled,
            presentedViewController: presented,
            presenting: presenting
        )
    }
    
}

