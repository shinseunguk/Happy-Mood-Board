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
        let navigateToAdd: Observable<Void>
        let dismiss: Observable<Tag?>
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
        let tagSelected = itemSelected.map {
            if case let .tag(tag) = $0 {
                PreferencesService.shared.tag = tag
                return tag
            }
            
            return nil
        }
            .filter { $0 != nil }
            .share()
    
        // 태그추가 선택시
        let addSelected = itemSelected.map { if case .add = $0 { return Void() } }

        let dismiss = Observable<Tag?>.merge(
            tagSelected,
            input.closeButtonTapped.map { _ -> Tag? in return nil }
        )
        return .init(
            navigateToEdit: input.editButtonTapped,
            items: items,
            navigateToAdd: addSelected,
            dismiss: dismiss
        )
    }
    
}
