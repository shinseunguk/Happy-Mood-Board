//
//  PhotoLibraryAuthorizationViewModel.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/29.
//

import Foundation

import RxSwift

final class PhotoLibraryAuthorizationViewModel: ViewModel {
    
    struct Input {
        let settingTrigger: Observable<Void>
    }
    
    struct Output {
        let openSettingApp: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        return .init(
            openSettingApp: input.settingTrigger
        )
    }
    
}
