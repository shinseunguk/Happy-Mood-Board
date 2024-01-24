//
//  PostDetailViewModel.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 1/21/24.
//

import Foundation

import RxSwift

final class PostDetailViewModel: ViewModel {
    enum Constants {
        static let inputDateFomat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        static let outputDateFormat = "yyyy.MM.dd"
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let backButtonTapped: Observable<Void>
        let moreButtonTapped: Observable<Void>
        let editActionTapped: Observable<Void>
        let deleteActionTapped: Observable<Void>
        let deleteOkActionTapped: Observable<Void>
    }

    struct Output {
        let post: Observable<FetchPostResponse?>
        let date: Observable<String>
        let image: Observable<UIImage?>
        let comment: Observable<String?>
        let tag: Observable<Tag?>
        let showActionSheet: Observable<Void>
        let showDeleteAlert: Observable<Void>
        let navigateToEdit: Observable<FetchPostResponse?>
        let navigateToBack: Observable<Void>
    }

    private let postId: Int

    init(postId: Int) {
        self.postId = postId
    }

    func transform(input: Input) -> Output {
        // 게시글 조회
        let postResult = input.viewWillAppear
            .map { PostTarget.fetch(.init(tagId: nil, postId: self.postId)) }
            .flatMapLatest {
                ApiService().request(type: [FetchPostResponse].self, target: $0)
                    .materialize()
            }
            .share()
        
        let postSuccess = postResult
            .elements()
            .map { $0?.first }
            .share()
        
        let date = postSuccess.map { $0?.createdAt }
            .filterNil()
            .map {
                let formatter = DateFormatter()
                formatter.dateFormat = Constants.inputDateFomat
                guard let date = formatter.date(from: $0) else { return $0 }
                formatter.dateFormat = Constants.outputDateFormat
                return formatter.string(from: date)
            }
        let comment = postSuccess.map { $0?.comments }
        let tag = postSuccess.map { $0?.postTag }
        let image = postSuccess.map { $0?.imagePath }
            .filterNil()
            .flatMapLatest { FirebaseStorageService.shared.rx.download(forPath: $0) }
            .debug()

        // 수정하기 버튼 클릭시
        let navigateToEdit = input.editActionTapped
            .flatMap { _ in postSuccess }
        
        // 삭제하기 버튼 클릭시
        let deleteResult = input.deleteOkActionTapped
            .map { PostTarget.delete(self.postId) }
            .flatMapLatest {
                ApiService().request(type: Empty.self, target: $0)
                    .materialize()
            }
            .debug("게시글 삭제")
            .share()

        let deleteSuccess = deleteResult
            .elements()
            .map { _ in }

        let navigateToBack = Observable.merge(deleteSuccess, input.backButtonTapped)

        return .init(
            post: postSuccess,
            date: date,
            image: image,
            comment: comment,
            tag: tag,
            showActionSheet: input.moreButtonTapped,
            showDeleteAlert: input.deleteActionTapped,
            navigateToEdit: navigateToEdit,
            navigateToBack: navigateToBack
        )
    }
}