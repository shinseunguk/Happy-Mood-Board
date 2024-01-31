//
//  ViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/31.
//

import UIKit

import SnapKit
import Then

public final class PartialPresentationController: UIPresentationController {
    
    // MARK: Constants
    
    public enum Direction {
        case top
        case bottom
        case center
        
        var swipeDirection: UISwipeGestureRecognizer.Direction {
            switch self {
            case .top: return .up
            case .bottom: return .down
            case .center: return .init()
            }
        }
    }
    
    public enum SizeType {
        case full
        case fit
        case absolute(CGFloat)
    }
    
    public typealias SizePair = (width: SizeType, height: SizeType)
    
    // MARK: Properties
    
    /// presentedView 방향
    private let direction: Direction
    
    /// presentedView 크기
    private let viewSize: SizePair
    
    /// presentedView의 preferredContentSize
    private var contentSize: CGSize = .zero
    
    /// swipe로 dismiss on / off
    private let isSwipeEnabled: Bool
    
    private lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
    private var swipeRecognizer: UISwipeGestureRecognizer {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(onSwiped))
        swipe.direction = direction.swipeDirection
        return swipe
    }
    
    private lazy var dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.backgroundColor = .init(white: 0, alpha: 0.5)
        dimmingView.alpha = 0
        dimmingView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        dimmingView.addGestureRecognizer(tapRecognizer)
        if isSwipeEnabled {
            dimmingView.addGestureRecognizer(swipeRecognizer)
        }
        return dimmingView
    }()
    
    // MARK: Initialize
    
    init(
        direction: Direction,
        viewSize: SizePair,
        isSwipeEnabled: Bool = true,
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?
    ) {
        presentedViewController.modalPresentationStyle = .custom
        //        presentedViewController.modalTransitionStyle = .crossDissolve
        self.direction = direction
        self.viewSize = viewSize
        self.isSwipeEnabled = isSwipeEnabled
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    /// present 애니메이션
    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        containerView?.addSubview(dimmingView)
        dimmingView.frame.size = containerView?.bounds.size ?? .zero
        
        // container(UITransitionView) 관련 애니메이션
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] context in
            self?.dimmingView.alpha = 1
            
            let transform: CGAffineTransform
            switch self?.direction {
            case .top:
                transform = .init(translationX: 0, y: self?.presentedView?.frame.height ?? 0)
            case .bottom:
                transform = .init(translationX: 0, y: -(self?.presentedView?.frame.height ?? 0))
            case .center:
                transform = .identity
            case .none:
                transform = .identity
            }
            self?.presentedView?.transform = transform
        }, completion: nil)
        
        // swipe to dismiss
        if isSwipeEnabled {
            presentedView?.addGestureRecognizer(swipeRecognizer)
        }
    }
    
    /// dismiss 애니메이션
    public override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        // container(UITransitionView) 관련 애니메이션
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] context in
            self?.dimmingView.alpha = 0
            self?.presentedView?.transform = .identity
            if context.transitionDuration <= 0 {
                self?.dimmingView.removeFromSuperview()
            }
        }, completion: { [weak self] _ in
            self?.dimmingView.removeFromSuperview()
        })
    }
    
    /// presentedView frame 계산
    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView,
              let presentedView = presentedView else { return .zero }
        
        let compressedSize = presentedView.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize,
            withHorizontalFittingPriority: .defaultLow,
            verticalFittingPriority: .defaultLow
        )
        
        var frame = containerView.bounds
        
        switch viewSize.width {
        case .full:
            frame.size.width = frame.width
        case .fit:
            frame.size.width = compressedSize.width
        case .absolute(let value):
            frame.size.width = value
        }
        
        switch viewSize.height {
        case .full:
            frame.size.height = frame.height
        case .fit:
            frame.size.height = compressedSize.height
        case .absolute(let value):
            frame.size.height = value
        }
        
        if case .fit = viewSize.width {
            let temp = CGSize(
                width: UIView.layoutFittingCompressedSize.width,
                height: frame.size.height
            )
            frame.size.width = presentedView.systemLayoutSizeFitting(
                temp,
                withHorizontalFittingPriority: .defaultLow,
                verticalFittingPriority: .required
            ).width
        }
        if case .fit = viewSize.height {
            let temp = CGSize(
                width: frame.size.width,
                height: UIView.layoutFittingCompressedSize.height
            )
            frame.size.height = presentedView.systemLayoutSizeFitting(
                temp,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .defaultLow
            ).height
        }
        
        switch direction {
        case .top:
            frame.origin.y = 0 - frame.height
            frame.origin.x = (containerView.bounds.width - frame.width) / 2
        case .bottom:
            frame.origin.y = containerView.bounds.height - frame.height + frame.height
            frame.origin.x = (containerView.bounds.width - frame.width) / 2
        case .center:
            frame.origin.x = containerView.center.x - frame.width / 2
            frame.origin.y = containerView.center.y - frame.height / 2
        }
        
        return frame
    }
    
    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.layer.cornerRadius = 30
        
        switch direction {
        case .top:
            presentedView?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        case .bottom:
            presentedView?.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        default:
            break
        }
    }
    
    // tap background to dismiss
    @objc private func onTapBackground() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    // swipe to dismiss
    @objc private func onSwiped() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
}

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
        
        // Custom PresentationController를 사용하기 위함
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        transitioningDelegate = self
        
        // statusBar를 presentedViewController 기준으로 설정할지
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("All UIs are code based, not nib.")
    }
    
}

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

