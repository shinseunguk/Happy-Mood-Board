//
//  AddTagViewModel.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/16.
//

import Foundation

import RxSwift

final class AddTagViewModel: ViewModel {
    
    struct Input {
        let name: Observable<String>
        let completeButtonTapped: Observable<Void>
        // TODO: UIButton 대체
        let colorButtonTapped: Observable<UIButton>
    }
    
    struct Output {
        let colorSelected: Observable<UIButton>
        let dismiss: Observable<Void>
        let errorMessage: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        let nameAndColor = Observable.combineLatest(
            input.name,
            input.colorButtonTapped
                .map { UIColor.tagColors.firstIndex(of: $0.tintColor) ?? 0 }
        )
        
        let result = input.completeButtonTapped.withLatestFrom(nameAndColor)
            .map { UpdatePostTagParameters(tagId: nil, tagName: $0.0, tagColorId: $0.1) }
            .flatMapLatest {
                ApiService()
                    .request(type: Empty.self, target: TagTarget.create($0))
                    .materialize()
            }
            .share()
        
        let success = result.elements()
            .map { _ in Void() }

        let failure = result.errors()
            .map { $0.localizedDescription }

        return .init(
            colorSelected: input.colorButtonTapped,
            dismiss: success,
            errorMessage: failure
        )
    }
    
}
