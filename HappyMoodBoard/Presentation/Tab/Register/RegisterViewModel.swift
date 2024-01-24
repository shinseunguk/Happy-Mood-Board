//
//  RegisterViewModel.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/27.
//

import Foundation

import RxSwift
import FirebaseStorage

final class RegisterViewModel: ViewModel {
    
    struct Input {
        let textChanged: Observable<String?>
        let backButtonTapped: Observable<Void>
        let registerButtonTapped: Observable<Void>
        let imageViewTapped: Observable<UITapGestureRecognizer>
        let deleteTagButtonTapped: Observable<Void>
        let deleteImageAlertActionTapped: Observable<Int>
        let addImageButtonTapped: Observable<Void>
        let addTagButtonTapped: Observable<Void>
        let keyboardButtonTapped: Observable<Void>
        let keyboardWillShow: Observable<Notification>
        let imageSelected: Observable<[UIImagePickerController.InfoKey: Any]>
    }
    
    struct Output {
        let canRegister: Observable<Bool>
        let showNavigateToBackAlert: Observable<Bool>
        let showImagePicker: Observable<Void>
        let showTagListViewController: Observable<Void>
        let showFullImageViewController: Observable<UIImage?>
        let image: Observable<UIImage?>
        let text: Observable<String?>
        let tag: Observable<Tag?>
        let keyboard: Observable<Void>
        let navigateToDetail: Observable<Int>
    }
    
    func transform(input: Input) -> Output {
        let image = Observable.merge(
            input.imageSelected
                .map { $0[.editedImage] as? UIImage },
            input.deleteImageAlertActionTapped
                .filter { $0 == 1 } // "네" 버튼 클릭시
                .map { _ in nil }
        )
            .startWith(nil)
            .share()
        
        let text = input.textChanged
            .filter { $0 != RegisterViewController.Constants.textViewPlaceholder }
            .startWith(nil)
            .share()
        
        let tag = Observable.merge(
            PreferencesService.shared.rx.tag.startWith(nil),
            input.deleteTagButtonTapped.map { _ in nil }
        )
            .share()
        
        let imageAndTextAndTag = Observable.combineLatest(
            image.startWith(nil),
            text.startWith(nil),
            tag.startWith(nil)
        )
            .share()
        
        // '뒤로가기' 눌렀을 때, 글씨, 이미지 등록, 태그 등록 중 1가지라도 되어있을 경우
        // "작성한 내용이 저장되지 않아요.\n정말 뒤로 가시겠어요?" 팝업 노출
        let showNavigateToBackAlert = input.backButtonTapped.withLatestFrom(imageAndTextAndTag)
            .map { image, text, tag in
                if image == nil && text == nil && tag == nil {
                    return false
                }
                return true
            }
        
        let textValid = text
            .map(checkTextValid)
            .startWith(false)
            .distinctUntilChanged()
        
        let imageValid = image
            .map(checkImageValid)
            .startWith(false)
            .distinctUntilChanged()
        
        // 본문이 1글자 이상 존재하거나 사진이 1개 등록인 상태일 경우
        // 발행 버튼 활성화
        let canRegister = Observable.combineLatest(textValid, imageValid) { $0 || $1 }
        
        // 발행 버튼 클릭시 이미지 업로드
        let uploadImage = input.registerButtonTapped.withLatestFrom(imageAndTextAndTag)
            .flatMapLatest { image, text, tag -> Observable<UpdatePostParameters> in
                if let image = image {
                    let path = "\(PreferencesService.shared.memberId ?? .init())/\(Date().timeIntervalSince1970.description)"
                    return FirebaseStorageService.shared.rx.upload(image: image, forPath: path)
                        .map {
                            UpdatePostParameters(
                                postId: nil,
                                tagId: tag?.id,
                                comments: text,
                                imagePath: $0
                            )
                        }
                } else {
                    return .just(
                        .init(
                            postId: nil,
                            tagId: tag?.id,
                            comments: text,
                            imagePath: nil
                        )
                    )
                }
            }
            .debug("이미지 업로드")
            .share()
        
        // 이미지 업로드 후 게시글 등록
        let result = uploadImage
            .map { PostTarget.create($0) }
            .flatMapLatest {
                ApiService().request(type: UpdatePostResponse.self, target: $0)
                    .materialize()
            }
            .share()
            .debug("게시글 등록")
        
        let success = result.elements()
            .compactMap { $0?.postId }
        
        let showFullImageViewController = input.imageViewTapped.withLatestFrom(image)
            .debug()
            .asObservable()
        
        return .init(
            canRegister: canRegister,
            showNavigateToBackAlert: showNavigateToBackAlert,
            showImagePicker: input.addImageButtonTapped,
            showTagListViewController: input.addTagButtonTapped,
            showFullImageViewController: showFullImageViewController,
            image: image,
            text: text,
            tag: tag,
            keyboard: input.keyboardButtonTapped,
            navigateToDetail: success
        )
    }
    
    private func checkTextValid(_ text: String?) -> Bool {
        (text ?? "").count > 0
    }
    
    private func checkImageValid(_ image: UIImage?) -> Bool {
        image != nil
    }
    
}
