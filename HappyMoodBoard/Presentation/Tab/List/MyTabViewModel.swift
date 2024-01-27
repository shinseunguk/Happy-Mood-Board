//
//  MyTabViewModel.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/18/24.
//

import Foundation

import RxSwift

final class MyTabViewModel: ViewModel {
    
    let selectedIndex = BehaviorSubject<(Int, Int)>(value: (0, 0))
    let disposeBag: DisposeBag = .init()
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let navigationRight: Observable<Void>
        let scrollViewDidScroll: Observable<Void>
    }
    
    struct Output {
        let navigationRight: Observable<Void>
        let username: Observable<String>
        let scrollViewDidScroll: Observable<Void>
        let tagSuccess: Observable<[(Int, String, Int)]>
        let tagErrorMessage: Observable<String>
        let happyItemSuccess: Observable<[Post]>
        let happyItemErrorMessage: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        let username = input.viewWillAppear
            .flatMapLatest {
                ApiService()
                    .request(type: MyInformationResponse.self, target: MemberTarget.me)
                    .map { $0?.nickname ?? "" }
            }

        // MARK: - /api/v1/post, 행복 아이템 게시물 조회
        let tag = input.viewWillAppear
            .map {
                PostTarget.fetch(
                    .init(
                        tagId: nil,
                        postId: nil
                    )
                )
            }
            .debug("행복 아이템 게시물 조회")
            .flatMapLatest {
                ApiService().request(type: [Post].self, target: $0)
                    .compactMap {
                        $0
                    }
                    .map {
                        [(0, "전체", 0)] + $0.compactMap {
                            $0.postTag.map {
                                ($0.id, $0.tagName, $0.tagColorId)
                            }
                        }
                    }
                    .map { result in
                        // 태그 중복제거 및 순서 정렬
                        self.removeDuplicates(by: \.0, from: result)
                    }
                    .materialize()
            }
        
        let tagSuccess = tag.elements()
        let tagFailure = tag.errors().map { $0.localizedDescription }
            
        
        // MARK: - /api/v1/post, viwWillAppear 혹은 버튼 누르면 재요청
        let post = Observable.combineLatest(input.viewWillAppear, selectedIndex)
            .map { _, values in
                values.0 == 0 ? nil : values.1
            }
            .map {
                PostTarget.fetch(
                    .init(
                        tagId: $0,
                        postId: nil
                    )
                )
            }
            .debug("행복 아이템 게시물 조회")
            .flatMapLatest {
                ApiService().request(type: [Post].self, target: $0)
                    .materialize()
            }
        
        let postSuccess = post.elements()
            .compactMap {
                $0
            }
        
        let postFailure = post.errors().map { $0.localizedDescription }
        
        return Output(
            navigationRight: input.navigationRight,
            username: username,
            scrollViewDidScroll: input.scrollViewDidScroll,
            tagSuccess: tagSuccess,
            tagErrorMessage: tagFailure,
            happyItemSuccess: postSuccess,
            happyItemErrorMessage: postFailure
        )
    }
}

extension MyTabViewModel {
    func removeDuplicates(by keyPath: KeyPath<(Int, String, Int), Int>, from array: [(Int, String, Int)]) -> [(Int, String, Int)] {
        var uniqueElements: [Int: (Int, String, Int)] = [:]

        for element in array {
            let key = element[keyPath: keyPath]
            uniqueElements[key] = element
        }

        let uniqueArray = Array(uniqueElements.values)
        let sortedArray = uniqueArray.sorted { $0.0 < $1.0 }
        
        return sortedArray
    }
}
