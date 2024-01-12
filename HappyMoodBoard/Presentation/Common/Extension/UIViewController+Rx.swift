//
//  UIViewController+Rx.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/10.
//

import UIKit

import RxSwift
import RxCocoa

public extension Reactive where Base: UIViewController {
    
    var viewDidLoad: ControlEvent<Void> {
        let source = methodInvoked(#selector(Base.viewDidLoad))
            .map { _ in }
        return ControlEvent(events: source)
    }
    
    var viewWillAppear: ControlEvent<Void> {
        let source = methodInvoked(#selector(Base.viewWillAppear))
            .map { _ in }
        return ControlEvent(events: source)
    }
    
}
    
