//
//  LoginViewModel.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/28/23.
//

import Foundation

import RxSwift
import RxCocoa

final class LoginViewModel: ViewModel {
    struct Input {
        let kakaoLogin: Observable<Void>
        let appleLogin: Observable<Void>
    }
    
    struct Output {
        let kakaoLogin: Observable<Void>
        let appleLogin: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        return Output(
            kakaoLogin: input.kakaoLogin,
            appleLogin: input.appleLogin
        )
    }
}
