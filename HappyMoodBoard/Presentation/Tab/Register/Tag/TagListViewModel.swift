//
//  TagListViewModel.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/09.
//

import Foundation

import RxSwift

final class TagListViewModel: ViewModel {
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let editButtonTapped: Observable<Void>
        let itemSelected: Observable<TagListItem>
        let closeButtonTapped: Observable<Void>
    }
    
    struct Output {
        let navigateToEdit: Observable<Void>
        let items: Observable<[TagListSection]>
        let navigateToAdd: Observable<Bool>
        let dismiss: Observable<Tag?>
    }
    
    let tagSelected: PublishSubject<Tag?>
    
    init(tagSelected: PublishSubject<Tag?>) {
        self.tagSelected = tagSelected
    }
    
    func transform(input: Input) -> Output {
        let items = input.viewWillAppear
            .flatMapLatest {
                ApiService()
                    .request(type: [Tag].self, target: TagTarget.fetch())
                    .filterNil()
                    .map { tags -> [TagListSection] in
                        var items: [TagListItem] = tags.map { .tag($0) }
                        items.append(.add)
                        return [TagListSection(items: items)]
                    }
                //                    .materialize()
            }
            .catchAndReturn([TagListSection(items: [.add])])
            .share()
        
        // 태그/태그추가 선택시
        let itemSelected = input.itemSelected.share()
        
        // 태그 선택시
        let tagSelected = itemSelected
            .filter {
                if case .tag(_) = $0 {
                    return true
                }
                return false
            }
            .map {
                if case .tag(let tag) = $0 {
                    return Optional(tag)
                }
                return nil
            }
            .share()
        
        // 태그추가 선택시
        let addSelected = itemSelected
            .filter {
                if case .add = $0 {
                    return true
                }
                return false
            }
            .map { _ in () }
        
        // 등록한 태그 존재 여부에 따라 태그 생성 뷰에서 노출되는 UI가 달라야함
        let navigateToAddWithHasExistingTag = Observable.merge(
            addSelected.map { _ in true },                                 // with existing tag
            items.filter { $0.first?.items.count == 1 }.map { _ in false }   // without existing tag
        )
        
        let dismiss = Observable<Tag?>.merge(
            tagSelected,
            input.closeButtonTapped.map { _ -> Tag? in return nil }
        ).do(onNext: self.tagSelected.onNext)
        
        return .init(
            navigateToEdit: input.editButtonTapped,
            items: items,
            navigateToAdd: navigateToAddWithHasExistingTag,
            dismiss: dismiss
        )
    }
    
}
