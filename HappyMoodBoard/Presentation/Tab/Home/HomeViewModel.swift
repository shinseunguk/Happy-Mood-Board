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
        let viewWillAppear: Observable<Void>
        let navigateToSetting: Observable<Void>
    }
    
    struct Output {
        let username: Observable<String>
        let navigateToSetting: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let username = input.viewWillAppear
            .flatMapLatest {
                ApiService()
                    .request(type: MyInformationResponse.self, target: MemberTarget.me)
                    .map { $0?.nickname ?? "" }
            }
        
        return Output(
            username: username,
            navigateToSetting: input.navigateToSetting
        )
    }
    
}
