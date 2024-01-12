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
        let checkNotification: Observable<Void>
        let navigationBack: ControlEvent<Void>
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
        let checkNotification: Observable<Bool>
        let navigationBack: Observable<Void>
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
    
    let disposeBag: DisposeBag = .init()
    
    func transform(input: Input) -> Output {
        
        let pushNotification = input.checkNotification
            .flatMap { _ in
                return self.isSystemNotificationEnabled()
            }
        
        
        return Output(
            checkNotification: pushNotification,
            navigationBack: input.navigationBack.asObservable(),
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
    
    func isSystemNotificationEnabled() -> Observable<Bool> {
        return Observable.create { observer in
            let center = NotificationCenter.default
            let notificationObserver = center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { _ in
                let isEnabled = UIApplication.shared.currentUserNotificationSettings?.types != []
                observer.onNext(isEnabled)
            }

            // Initial check for notification status
            let isEnabled = UIApplication.shared.currentUserNotificationSettings?.types != []
            observer.onNext(isEnabled)

            return Disposables.create {
                center.removeObserver(notificationObserver)
            }
        }
    }
}
