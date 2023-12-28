//
//  SettingIndexViewModel.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/25/23.
//

import Foundation

import RxSwift
import RxCocoa

final class SettingIndexViewModel: ViewModel {
    
    struct Input {
        let mySettings: Observable<Void>
        let notificationSettings: Observable<Void>
        let termsOfService: Observable<Void>
        let privacyPolicy: Observable<Void>
        let openSourceLicense: Observable<Void>
        let leaveReview: Observable<Void>
        let versionInformation: Observable<Void>
        let logout: Observable<Void>
        let withdrawMembership: Observable<Void>
    }
    
    struct Output {
        let mySettings: Observable<Void>
        let notificationSettings: Observable<Void>
        let termsOfService: Observable<Void>
        let privacyPolicy: Observable<Void>
        let openSourceLicense: Observable<Void>
        let leaveReview: Observable<Void>
        let versionInformation: Observable<Void>
        let logout: Observable<Void>
        let withdrawMembership: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        
        return Output(
            mySettings: input.mySettings,
            notificationSettings: input.notificationSettings,
            termsOfService: input.termsOfService,
            privacyPolicy: input.privacyPolicy,
            openSourceLicense: input.openSourceLicense,
            leaveReview: input.leaveReview,
            versionInformation: input.versionInformation,
            logout: input.logout,
            withdrawMembership: input.withdrawMembership
        )
    }
}
