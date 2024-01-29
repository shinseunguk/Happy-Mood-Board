//
//  AddTagViewModel.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/16.
//

import Foundation

import RxSwift

final class AddTagViewModel: ViewModel {
    
    enum UpdatePostTagMode {
        case add
        case edit
        
        var title: String {
            switch self {
            case .add:
                return "태그 생성"
            case .edit:
                return "태그 편집"
            }
        }
    }
    
    struct Input {
        let name: Observable<String>
        let completeButtonTapped: Observable<Void>
        let colorButtonTapped: Observable<Int>
    }
    
    struct Output {
        let title: Observable<String>
        let tag: Observable<Tag>
        let dismiss: Observable<Void>
        let errorMessage: Observable<String>
    }
    
    private let tag: Tag
    private let mode: UpdatePostTagMode
    
    init(tag: Tag = .init()) {
        self.tag = tag
        self.mode = (tag.id == nil) ? .add : .edit
    }
    
    func transform(input: Input) -> Output {
        let nameAndColor = Observable.combineLatest(
            input.name,
            input.colorButtonTapped.startWith(self.tag.tagColorId)
        )
        
        let tag = Observable.combineLatest(Observable.just(self.tag), nameAndColor) { (tag, nameAndColor) -> Tag in
            return Tag(id: tag.id, tagName: nameAndColor.0, tagColorId: nameAndColor.1)
        }
            .startWith(self.tag)
//            .share()
        
        let result = input.completeButtonTapped.withLatestFrom(tag)
            .map {
                UpdatePostTagParameters(
                    tagId: $0.id,
                    tagName: $0.tagName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? .init(),
                    tagColorId: $0.tagColorId
                )
            }
            .flatMapLatest { parameter -> Observable<Event<PostTagResponse?>> in
                if parameter.tagId == nil {
                    // 태그 생성
                    return ApiService()
                        .request(type: PostTagResponse.self, target: TagTarget.create(parameter))
                        .debug("태그 생성")
                        .materialize()
                } else {
                    // 태그 편집
                    return ApiService()
                        .request(type: PostTagResponse.self, target: TagTarget.update(parameter))
                        .debug("태그 편집")
                        .materialize()
                }
            }
            .share()
        
        let success = result.elements()
            .map { _ in Void() }
            .debug("성공")
        
        let failure = result.errors()
            .map { $0.localizedDescription }
            .debug("실패")
        
        return .init(
            title: Observable.just(self.mode.title),
            tag: tag,
            dismiss: success,
            errorMessage: failure
        )
    }
    
}
