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

        return Output(
            agreeToAllOptions: state.map { $0.allOptions },
            agreeToAge: state.map { $0.age },
            agreeToPrivacyPolicy: state.map { $0.privacyPolicy },
            agreeToTerms: state.map { $0.terms },
            agreeToMarketingEmail: state.map { $0.marketingEmail },
            navigateToNextStep: input.navigateToNextStep
        )
    }
    
}
