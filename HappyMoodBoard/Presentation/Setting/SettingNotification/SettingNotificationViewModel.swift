//
//  SettingNotificationViewModel.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 1/5/24.
//

import Foundation

import RxSwift

final class SettingNotificationViewModel: ViewModel {
    struct Input {
        let navigateToBack: Observable<Void>
    }
    
    struct Output {
        let navigateToBack: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        return Output(
            navigateToBack: input.navigateToBack
        )
    }
}
