//
//  EnterNicknameViewModel.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/14.
//

import Foundation

import RxSwift

final class EnterNicknameViewModel: ViewModel {
    
    struct Input {
        let nickname: Observable<String>
        let navigateToHome: Observable<Void>
    }
    
    struct Output {
        let nickname: Observable<String>
        let isValid: Observable<Bool>
        let navigateTohome: Observable<Void>
    }

    private let disposeBag: DisposeBag = .init()
    
    func transform(input: Input) -> Output {
        let isValid = BehaviorSubject(value: false)

        let maxCount = 10
        let nickname = input.nickname
            .scan("") { previous, new -> String in
                // TODO: 앞뒤 공백 제거
                if new.count >= maxCount {
                    return previous
                } else {
                    return new
                }
            }

        nickname
            .map { $0.count <= maxCount && $0.count > 0 }
            .subscribe(onNext: {
                isValid.onNext($0)
            })
            .disposed(by: disposeBag)

        return Output(
            nickname: nickname,
            isValid: isValid,
            navigateTohome: input.navigateToHome
        )
    }
    
}
