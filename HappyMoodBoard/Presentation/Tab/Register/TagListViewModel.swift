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
        let itemSelected: Observable<TagListItemType>
        let closeButtonTapped: Observable<Void>
    }
    
    struct Output {
        let navigateToEdit: Observable<Void>
        let items: Observable<[TagListItemType]>
        let navigateToAdd: Observable<Void>
        let dismiss: Observable<Tag?>
    }
    
    func transform(input: Input) -> Output {
        let items = input.viewWillAppear
            .flatMapLatest {
                ApiService()
                    .request(type: [Tag].self, target: TagTarget.fetch())
                    .map { $0 != nil ? $0! : [] }
                    .map { $0.map(TagListItemType.tag) }
                    .map {
                        var copy = $0
                        copy.append(.add)
                        return copy
                    }
            }
        let itemSelected = input.itemSelected.share()
        let tagSelected = itemSelected.map {
            if case let .tag(tag) = $0 {
                PreferencesService.shared.setTag(tag)
                return tag
            }
            return nil
        }
            .filter { $0 != nil }
            .share()
    
        let navigateToAdd = itemSelected.map { if case .add = $0 { return Void() } }
        let dismiss = Observable<Tag?>.merge(
            tagSelected,
            input.closeButtonTapped.map { _ -> Tag? in return nil }
        )
        return .init(
            navigateToEdit: input.editButtonTapped,
            items: items,
            navigateToAdd: navigateToAdd,
            dismiss: dismiss
        )
    }
    
}
