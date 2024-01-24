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
        let tag: Observable<[(Int, String, Int)]>
        let happyItem: Observable<[Post]>
    }
    
    func transform(input: Input) -> Output {
        let post = PublishSubject<[Post]>()
        let tag: Observable<[(Int, String, Int)]>
        
        let username = input.viewWillAppear
            .flatMapLatest {
                ApiService()
                    .request(type: MyInformationResponse.self, target: MemberTarget.me)
                    .map { $0?.nickname ?? "" }
            }

        // MARK: - /api/v1/post, 행복 아이템 게시물 조회
        tag = input.viewWillAppear
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
            }
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
        
        // MARK: - /api/v1/post, viwWillAppear 혹은 버튼 누르면 재요청
        Observable.combineLatest(input.viewWillAppear, selectedIndex)
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
            }
            .compactMap {
                $0
            }
            .bind(to: post)
            .disposed(by: disposeBag)
        
        return Output(
            navigationRight: input.navigationRight,
            username: username,
            scrollViewDidScroll: input.scrollViewDidScroll,
            tag: tag,
            happyItem: post
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
