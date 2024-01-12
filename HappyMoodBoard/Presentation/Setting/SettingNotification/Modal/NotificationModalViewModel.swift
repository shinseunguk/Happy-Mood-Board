//
//  NotificationModalViewModel.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 1/5/24.
//

import Foundation

import RxSwift
import RxCocoa

final class NotificationModalViewModel: ViewModel {
    struct Input {
        let prefNotification: Observable<Void>
        let dismiss: Observable<Void>
    }
    
    struct Output {
        let prefNotification: Observable<Void>
        let dismiss: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        
        return Output(
            prefNotification: input.prefNotification,
            dismiss: input.dismiss
        )
    }
}
