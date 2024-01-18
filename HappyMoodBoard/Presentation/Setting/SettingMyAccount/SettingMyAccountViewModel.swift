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
        let myInfo: Observable<MyInformationResponse?>
    }
    
    func transform(input: Input) -> Output {
        
        let myInfo: Observable<MyInformationResponse?> = input.viewWillAppear
            .map {
                MemberTarget.me
            }
            .debug("내 정보 보기")
            .flatMapLatest {
                ApiService().request(type: MyInformationResponse.self, target: $0)
            }
            .map { result in
                if let response = result {
                    return response
                } else {
                    return nil
                }
            }
        
        return Output(
            navigateToBack: input.navigateToBack,
            navigateToNextStep: input.navigateToNextStep,
            myInfo: myInfo
        )
    }
}
