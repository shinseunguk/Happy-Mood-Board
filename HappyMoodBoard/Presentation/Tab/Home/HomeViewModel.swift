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
        let viewWillDisAppear: Observable<Bool>
    }
    
    struct Output {
        let viewWillAppear: Observable<Void>
        let viewWillDisAppear: Observable<Bool>
        let username: Observable<String?>
    }
    
    func transform(input: Input) -> Output {
        let result = input.viewWillAppear
            .flatMapLatest {
                ApiService()
                    .request(type: MyInformationResponse.self, target: MemberTarget.me)
                    .materialize()
            }
            .share()
        
        let user = result.elements()
            .do(onNext: { user in
                PreferencesService.shared.memberId = user?.memberId
            })
            .share()
        let username = user.map { $0?.nickname }
        
        
        return Output(
            viewWillAppear: input.viewWillAppear,
            viewWillDisAppear: input.viewWillDisAppear,
            username: username
        )
    }
    
}
