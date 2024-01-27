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
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
        let navigateToBack: Observable<Void>
        let navigateToNextStep: Observable<UITapGestureRecognizer>
        let myInfoSuccess: Observable<MyInformationResponse>
        let myInfoError: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        
        let myInfo = input.viewWillAppear
            .map {
                MemberTarget.me
            }
            .debug("내 정보 보기")
            .flatMapLatest {
                ApiService().request(type: MyInformationResponse.self, target: $0)
                    .materialize()
            }
            .share()
        
        let success = myInfo.elements()
            .filterNil()
        
        let failure = myInfo.errors().map { $0.localizedDescription }
        
        return Output(
            navigateToBack: input.navigateToBack,
            navigateToNextStep: input.navigateToNextStep,
            myInfoSuccess: success,
            myInfoError: failure
        )
    }
}
