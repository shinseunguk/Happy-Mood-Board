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
        let editButtonTapped: Observable<Tag>
        let deleteOkActionTapped: Observable<Tag>
    }
    
    struct Output {
        let items: Observable<[EditTagSection]>
        let errorMessage: Observable<String>
        let showDeleteAlert: Observable<Tag>
        let navigateToEdit: Observable<Tag>
    }
    
    func transform(input: Input) -> Output {
        let itemDeleted = input.itemDeleted
            .share()
        
        let result = input.deleteOkActionTapped
            .map { $0.id }
            .filterNil()
            .flatMapLatest {
                ApiService()
                    .request(type: Empty.self, target: TagTarget.delete($0))
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
                    .materialize()
            }
            .share()
        
        let success = items.elements()
        
        let failure = items.errors().map { $0.localizedDescription }
            
        return .init(
            items: success,
            errorMessage: failure,
            showDeleteAlert: itemDeleted,
            navigateToEdit: input.editButtonTapped
        )
    }
    
}
