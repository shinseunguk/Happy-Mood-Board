//
//  AgreeViewModel.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/07.
//

import Foundation

import RxSwift

final class AgreeViewModel: ViewModel {
    
    struct Input {
        let agreeToAllOptions: Observable<Void>
        let agreeToAgeRequirements: Observable<Void>
        let agreeToPrivacyPolicy: Observable<Void>
        let agreeToTerms: Observable<Void>
        let agreeToMarketingEmail: Observable<Void>

        let navigateToPrivacyPolicy: Observable<Void>
        let navigateToTerms: Observable<Void>
        let navigateToMarketingEmail: Observable<Void>
        let navigateToNextStep: Observable<Void>
    }
    
    struct Output {
        let agreeToAllOptions: Observable<Bool>
        let agreeToAge: Observable<Bool>
        let agreeToPrivacyPolicy: Observable<Bool>
        let agreeToTerms: Observable<Bool>
        let agreeToMarketingEmail: Observable<Bool>
        // TODO: webview
        let navigateToNextStep: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        enum Action {
            case toggleAge
            case togglePrivacyPolicy
            case toggleTerms
            case toggleMarketingEmail
            case toggleAllOptions
        }
        
        struct State {
            var age: Bool = false
            var privacyPolicy: Bool = false
            var terms: Bool = false
            var marketingEmail: Bool = false
            var allOptions: Bool = false
//            var navigateToURL: String? = ""
        }
        
        let action = Observable.merge(
            input.agreeToAllOptions
                .map { Action.toggleAllOptions },
            input.agreeToAgeRequirements
                .map { Action.toggleAge },
            input.agreeToPrivacyPolicy
                .map { Action.togglePrivacyPolicy },
            input.agreeToTerms
                .map { Action.toggleTerms },
            input.agreeToMarketingEmail
                .map { Action.toggleMarketingEmail }
        )
        
        let state = action.scan(into: State()) { current, action in
            switch action {
            case .toggleAllOptions:
                current.age = !current.allOptions
                current.privacyPolicy = !current.allOptions
                current.terms = !current.allOptions
                current.marketingEmail = !current.allOptions
            case .toggleAge:
                current.age = !current.age
            case .togglePrivacyPolicy:
                current.privacyPolicy = !current.privacyPolicy
            case .toggleTerms:
                current.terms = !current.terms
            case .toggleMarketingEmail:
                current.marketingEmail = !current.marketingEmail
            }
            current.allOptions = current.age
            && current.privacyPolicy
            && current.terms // 필수
            // && current.marketingEmail // 선택
        }
            .share()
        
        let result = input.navigateToNextStep.withLatestFrom(state)
            .map { MemberTarget.consent(
                    .init(
                        upperFourteen: $0.age,
                        serviceTerms: $0.terms,
                        privacyPolicy: $0.privacyPolicy,
                        marketingTerms: $0.marketingEmail
                    )
                )
            }
            .debug("약관동의")
            .flatMapLatest {
                ApiService().request(type: Empty.self, target: $0)
                    .materialize()
            }
            .share()
        
        let success = result
//            .elements()
            .map { _ in Void() }

        // TODO: 에러 응답 처리
        // (약관동의 한번 더 하는 경우) 발생하는 케이스가 있는지 확인 후, 사용자 편의성을 위해 그냥 다음 화면으로 이동할지 or 경고창 띄울지
        
        return Output(
            agreeToAllOptions: state.map { $0.allOptions }, // canNext
            agreeToAge: state.map { $0.age },
            agreeToPrivacyPolicy: state.map { $0.privacyPolicy },
            agreeToTerms: state.map { $0.terms },
            agreeToMarketingEmail: state.map { $0.marketingEmail },
            navigateToNextStep: success
        )
    }
    
}
