//
//  RegisterViewModel.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/27.
//

import Foundation

import RxSwift
import FirebaseStorage

struct PostDomain {
    let id: Int?
    let comments: String?
    let tag: Tag?
    let image: UIImage?
}

extension PostDomain {
    init() {
        self.init(id: nil, comments: nil, tag: nil, image: nil)
    }
}

final class RegisterViewModel: ViewModel {
    
    enum Constants {
        static let maxLength = 1000
    }
    
    struct Input {
        let textDidChanged: Observable<Void>
        let textChanged: Observable<String?>
        let backButtonTapped: Observable<Void>
        let navigatToBackOkActionTapped: Observable<Void>
        let registerButtonTapped: Observable<Void>
        let imageViewTapped: Observable<UITapGestureRecognizer>
        let deleteTagButtonTapped: Observable<Void>
        let deleteImageButtonTapped: Observable<Void>
        let deleteImageOkActionTapped: Observable<Void>
        let addImageButtonTapped: Observable<Void>
        let addTagButtonTapped: Observable<Void>
        let tagSelected: Observable<Tag?>
        let keyboardButtonTapped: Observable<Void>
        let keyboardWillShow: Observable<Notification>
        let imageSelected: Observable<[UIImagePickerController.InfoKey: Any]>
    }
    
    struct Output {
        let textDidChanged: Observable<Void>
        let canRegister: Observable<Bool>
        let showNavigateToBackAlert: Observable<Bool>
        let showImagePicker: Observable<Bool>
        let shwoDeleteImageAlert: Observable<Void>
        let showTagListViewController: Observable<Void>
        let showFullImageViewController: Observable<UIImage?>
        let post: Observable<PostDomain>
        let keyboard: Observable<Void>
        let showLoadingView: Observable<Bool>
        let navigateToDetail: Observable<Int?>
        let error: Observable<String>
        let navigateToBack: Observable<Void>
    }
    
    private let post: PostDomain
    
    init(post: PostDomain = .init()) {
        self.post = post
    }
    
    func transform(input: Input) -> Output {
        let image = Observable.merge(
            input.imageSelected
                .map { $0[.editedImage] as? UIImage },
            input.deleteImageOkActionTapped
                .map { _ in nil }
        )
            .startWith(self.post.image)

        let text = input.textChanged
            .filter { $0 != RegisterViewController.Constants.textViewPlaceholder }
            .startWith(self.post.comments)
            .distinctUntilChanged()
        
        let tag = Observable.merge(
            input.tagSelected,
            input.deleteTagButtonTapped.map { _ in nil }
        )
            .startWith(self.post.tag)
        
        let textAndTagAndImage = Observable.combineLatest(text, tag, image)
        
        let post = Observable.combineLatest(
            Observable.just(self.post),
            textAndTagAndImage
        ) { post, textAndTagAndImage -> PostDomain in
            return PostDomain(
                id: post.id,
                comments: textAndTagAndImage.0,
                tag: textAndTagAndImage.1,
                image: textAndTagAndImage.2
            )
        }
            .startWith(self.post)
        
        let showImagePicker = input.addImageButtonTapped
            .withLatestFrom(image)
            .map { $0 == nil ? true : false }
        
        // '뒤로가기' 눌렀을 때, 글씨, 이미지 등록, 태그 등록 중 1가지라도 되어있을 경우
        // "작성한 내용이 저장되지 않아요.\n정말 뒤로 가시겠어요?" 팝업 노출
        let showNavigateToBackAlert = input.backButtonTapped.withLatestFrom(post)
            .map { post in
                if post.comments == nil && post.tag == nil && post.image == nil {
                    return false
                }
                return true
            }
            .debug("뒤로가기")
        
        let textValid = post
            .map(checkTextValid)
            .startWith(false)
            .distinctUntilChanged()
        
        let imageValid = post
            .map(checkImageValid)
            .startWith(false)
            .distinctUntilChanged()
        
        // 본문이 1글자 이상 존재하거나 사진이 1개 등록인 상태일 경우
        // 발행 버튼 활성화
        let canRegister = Observable.combineLatest(textValid, imageValid) { $0 || $1 }
        
        // 발행 버튼 클릭시 애니메이션
        let showLoadingView: BehaviorSubject<Bool> = .init(value: false)
        
        // 발행 버튼 클릭시 이미지 업로드
        let uploadImage = input.registerButtonTapped.withLatestFrom(post)
            .do(onNext: { _ in
                showLoadingView.onNext(true)
            })
            .flatMapLatest { post -> Observable<UpdatePostParameters> in
                if let image = post.image {
                    let path = "\(PreferencesService.shared.memberId ?? .init())/\(Date().timeIntervalSince1970.description)"
                    return FirebaseStorageService.shared.rx.upload(image: image, forPath: path)
                        .map {
                            UpdatePostParameters(
                                postId: post.id,
                                tagId: post.tag?.id,
                                comments: post.comments,
                                imagePath: $0
                            )
                        }
                } else {
                    return .just(
                        .init(
                            postId: post.id,
                            tagId: post.tag?.id,
                            comments: post.comments,
                            imagePath: nil
                        )
                    )
                }
            }
            .debug("이미지 업로드")
            .share()
        
        // 이미지 업로드 후 게시글 등록 또는 수정
        let result = uploadImage
            .map {
                // 게시글 등록
                if $0.postId != nil {
                    return PostTarget.update($0)
                }
                // 게시글 수정
                return PostTarget.create($0)
            }
            .flatMapLatest {
                ApiService().request(type: UpdatePostResponse.self, target: $0)
                    .materialize()
            }
            .share()
            .debug("게시글 등록")
            .delay(.seconds(3), scheduler: MainScheduler.instance) // 딜레이
            .do(onNext: { _ in
                showLoadingView.onNext(false)
            })
        
        let success = result.elements()
            .map { $0?.postId }
        
        let failure = result.errors().map { $0.localizedDescription }
            
        let showFullImageViewController = input.imageViewTapped.withLatestFrom(image)
            .asObservable()
        
        return .init(
            textDidChanged: input.textDidChanged,
            canRegister: canRegister,
            showNavigateToBackAlert: showNavigateToBackAlert,
            showImagePicker: showImagePicker,
            shwoDeleteImageAlert: input.deleteImageButtonTapped,
            showTagListViewController: input.addTagButtonTapped,
            showFullImageViewController: showFullImageViewController,
            post: post,
            keyboard: input.keyboardButtonTapped,
            showLoadingView: showLoadingView,
            navigateToDetail: success,
            error: failure,
            navigateToBack: input.navigatToBackOkActionTapped
        )
    }
    
    private func checkTextValid(_ post: PostDomain) -> Bool {
        (post.comments ?? "").count > 0
    }
    
    private func checkImageValid(_ post: PostDomain) -> Bool {
        post.image != nil
    }
    
}
