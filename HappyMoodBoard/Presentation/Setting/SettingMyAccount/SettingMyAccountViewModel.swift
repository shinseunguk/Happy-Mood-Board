//
//  SettingMyAccountViewModel.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/3/24.
//

import Foundation

import RxSwift
import RxCocoa
import RxGesture

final class SettingMyAccountViewModel: ViewModel {
    struct Input {
        let navigateToBack: Observable<Void>
        let navigateToNextStep: Observable<UITapGestureRecognizer>
    }
    
    struct Output {
        let navigateToBack: Observable<Void>
        let navigateToNextStep: Observable<UITapGestureRecognizer>
    }
    
    func transform(input: Input) -> Output {
        return Output(
            navigateToBack: input.navigateToBack,
            navigateToNextStep: input.navigateToNextStep
        )
    }
}
