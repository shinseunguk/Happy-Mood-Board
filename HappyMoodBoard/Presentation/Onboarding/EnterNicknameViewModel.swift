//
//  EnterNicknameViewModel.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/14.
//

import Foundation

import RxSwift

final class EnterNicknameViewModel: ViewModel {
    
    enum Constants {
        static let maxLength = 10
    }
    
    struct Input {
        let nickname: Observable<String>
        let navigateToHome: Observable<Void>
    }
    
    struct Output {
        let nickname: Observable<String>
        let nextButtonEnabled: Observable<Bool>
        let navigateTohome: Observable<Void>
    }
    
    private let disposeBag: DisposeBag = .init()
    
    func transform(input: Input) -> Output {
        let nickname = input.nickname
            .scan(String()) { previous, new -> String in
                // 최대 글자수 초과시 초과된 부분은 입력되지 않음
                guard new.count <= Constants.maxLength else { return previous }
                return new
            }
        
        // 앞뒤 공백을 절삭한 후 글자수 길이가 충족하면 완료 버튼 활성화
        let isNicknameValid = nickname
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { $0.count <= Constants.maxLength && $0.count > 0 }
        
        // 앞뒤 공백을 절삭하여 서버에 요청
        let result = input.navigateToHome
            .withLatestFrom(
                nickname
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            )
            .map { MemberTarget.nickname(.init(nickname: $0)) }
            .flatMapLatest {
                ApiService().request(type: Empty.self, target: $0)
                    .materialize()
            }
            .share()
        
        let success = result
            .elements()
            .map { _ in }
        
        // TODO: 응답 에러 처리
        
        return Output(
            nickname: nickname,
            nextButtonEnabled: isNicknameValid,
            navigateTohome: success
        )
    }
    
}
