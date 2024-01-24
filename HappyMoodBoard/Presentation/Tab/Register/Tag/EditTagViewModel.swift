//
//  EditTagViewModel.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/19.
//

import Foundation

import RxSwift

final class EditTagViewModel: ViewModel {
    
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let itemDeleted: Observable<Tag>
        let itemAccessoryButtonTapped: Observable<IndexPath>
        let deleteOkActionTapped: Observable<Tag>
    }
    
    struct Output {
        let items: Observable<[EditTagSection]>
        let showDeleteAlert: Observable<Tag>
        let navigateToEdit: Observable<Tag>
    }
    
    func transform(input: Input) -> Output {
        let itemDeleted = input.itemDeleted
            .share()
        
        // TODO: 태그로 수정
        let itemAccessoryButtonTapped = input.itemAccessoryButtonTapped
            .map { Tag(id: $0.section, tagName: "name", tagColorId: $0.row) }
        
        let result = input.deleteOkActionTapped
            .flatMapLatest {
                ApiService()
                    .request(type: Empty.self, target: TagTarget.delete($0.id))
                    .materialize()
            }
            .elements()
            .map { _ in () }
        
        let items = Observable.merge(
            input.viewWillAppear,
            result
        ).flatMapLatest {
                ApiService()
                    .request(type: [Tag].self, target: TagTarget.fetch())
                    .compactMap { [EditTagSection(items: $0 ?? [])] }
            }
            .share()
            
        return .init(
            items: items,
            showDeleteAlert: itemDeleted,
            navigateToEdit: itemAccessoryButtonTapped
        )
    }
    
}