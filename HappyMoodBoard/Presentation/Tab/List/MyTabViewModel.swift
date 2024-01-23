//
//  MyTabViewModel.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/18/24.
//

import Foundation

import RxSwift

final class MyTabViewModel: ViewModel {
    struct Input {
        let viewWillAppear: Observable<Void>
        let navigationRight: Observable<Void>
        let scrollViewDidScroll: Observable<Void>
    }
    
    struct Output {
        let navigationRight: Observable<Void>
        let username: Observable<String>
        let scrollViewDidScroll: Observable<Void>
        let tag: Observable<[(String, Int)]>
        let happyItem: Observable<[Post]>
    }
    
    func transform(input: Input) -> Output {
        let post: Observable<[Post]>
        let tag: Observable<[(String, Int)]>
        
        let username = input.viewWillAppear
            .flatMapLatest {
                ApiService()
                    .request(type: MyInformationResponse.self, target: MemberTarget.me)
                    .map { $0?.nickname ?? "" }
            }

        // MARK: - /api/v1/post, 행복 아이템 게시물 조회
        post = input.viewWillAppear
            .map {
                PostTarget.fetch(
                    .init(
                        tagId: nil,
                        postId: nil
                    )
                )
            }
            .flatMapLatest {
                ApiService().request(type: [Post].self, target: $0)
            }
            .compactMap {
                $0
            }
        
        tag = post.map {
            [("전체", 0)] + $0.compactMap {
                $0.postTag.map {
                    ($0.tagName, $0.tagColorId)
                }
            }
        }
        
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
    
}
