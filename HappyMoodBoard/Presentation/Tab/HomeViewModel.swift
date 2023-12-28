//
//  HomeViewModel.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/22.
//

import Foundation

import RxSwift

final class HomeViewModel: ViewModel {
    
    struct Input {
        let navigateToSetting: Observable<Void>
    }
    
    struct Output {
        let username: Observable<String>
        let navigateToSetting: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        // TODO: UserDefaults 또는 API 호출
        let username = Observable.just("행복호소인")
        
        return Output(
            username: username,
            navigateToSetting: input.navigateToSetting
        )
    }
    
}
