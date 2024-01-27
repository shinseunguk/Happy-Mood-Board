//
//  RegisterViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/20.
//

import UIKit
import Photos

import Then
import SnapKit
import Lottie

import RxSwift
import RxCocoa
import RxGesture
import RxKeyboard

final class RegisterViewController: UIViewController {
    
    enum Constants {
        static let registerImage: UIImage = .init(named: "navigation.register") ?? .init()
        static let textViewPlaceholder: String = "최대 1000자까지 작성 가능해요."
        static let textViewPlaceholderColor: UIColor? = .gray400
        static let textViewTextColor: UIColor? = .gray900
        
        static let deleteImageAlertTitle = "사진을 삭제하시겠어요?"
        static let navigateToBackAlertMessage = "작성한 내용이 저장되지 않아요.\n정말 뒤로 가시겠어요?"
        static let alertNoAction = "아니오"
        static let alertYesActon = "네"
        
        
        // 최소 높이와 최대 높이를 정의합니다.
        static let minHeight: CGFloat = 200.0
        static let maxHeight: CGFloat = 400.0
    }
    
    private let backButton: UIBarButtonItem = .init(
        image: .init(named: "navigation.back"),
        style: .plain,
        target: nil,
        action: nil
    )
    
    private let registerButton: UIBarButtonItem = .init(
        image: Constants.registerImage,
        style: .done,
        target: nil,
        action: nil
    )
    
    private let headerLabel: UILabel = .init().then {
        $0.text = "오늘의 행복은 어떤건가요?"
        $0.textColor = .gray900
        $0.font = UIFont(name: "Pretendard-Bold", size: 24)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private let contentStackView: UIStackView = .init().then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 24
    }
    
    private let imageView: UIImageView = .init().then {
        $0.isHidden = true
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let frameImageView: UIImageView = .init().then {
        $0.isHidden = true
        $0.image = UIImage(named: "frame")
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.primary500?.cgColor
    }
    
    private let deleteImageButton: UIButton = .init().then {
        $0.setImage(UIImage(named: "delete"), for: .normal)
    }
    
    private let tagButton: UIButton = .init(type: .system).then {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        let verticalInset: CGFloat = 4.5
        let horizontalInset: CGFloat = 18.5
        configuration.contentInsets = .init(
            top: verticalInset,
            leading: horizontalInset,
            bottom: verticalInset,
            trailing: horizontalInset
        )
        configuration.image = .init(named: "tag.delete")
        configuration.imagePadding = 10
        configuration.imagePlacement = .trailing
        $0.configuration = configuration
        $0.isHidden = true
    }
    
    private let textView: UITextView = .init().then {
        $0.text = Constants.textViewPlaceholder
        $0.textColor = Constants.textViewPlaceholderColor
        $0.font = UIFont(name: "Pretendard-Regular", size: 16)
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.primary900?.cgColor
        $0.textContainerInset = .init(top: 24, left: 24, bottom: 24, right: 24)
    }
    
    private let addImageButton: UIButton = .init().then {
        $0.tintColor = .primary900
        $0.setImage(UIImage(named: "toolbar.camera"), for: .normal)
        $0.setImage(UIImage(named: "toolbar.camera.disabled"), for: .disabled)
    }
    
    private let addTagButton: UIBarButtonItem = .init(
        image: .init(named: "toolbar.tag"),
        style: .plain,
        target: nil,
        action: nil
    )
    
    private let keyboardToggleButton: UIBarButtonItem = .init(
        image: .init(named: "toolbar.keyboard.up"),
        style: .plain,
        target: nil,
        action: nil
    )
    
    private let imagePicker: UIImagePickerController = .init().then {
        $0.navigationBar.tintColor = .primary100
    }
    
    private lazy var toolbar: UIToolbar = .init(
        frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48)
    ).then {
        $0.items = [
            .init(customView: addImageButton),
            .fixedSpace(20),
            addTagButton,
            .flexibleSpace(),
            keyboardToggleButton
        ]
        $0.barTintColor = .primary100
        $0.backgroundColor = .primary100
    }
    
    private let loadingDimView: UIView = .init().then {
        $0.backgroundColor = .black
        $0.alpha = 0.7
    }
    
    private let loadingLabel: UILabel = .init().then {
        $0.text = "나의 꿀단지에 행복을 담는 중"
        $0.textAlignment = .center
        $0.textColor = .white
        $0.font = UIFont(name: "Pretendard-Bold", size: 24)
    }
    
    private let animationView: LottieAnimationView = .init(name: "beewrite").then {
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .loop
        $0.play()
    }
    
    private let viewModel: RegisterViewModel
    private let disposeBag: DisposeBag = .init()
    
    init(viewModel: RegisterViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCommonBackgroundColor()
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
}

extension RegisterViewController: ViewAttributes {
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = registerButton
    }
    
    func setupSubviews() {
        [
            headerLabel,
            imageView,
            contentStackView,
            deleteImageButton,
            toolbar,
            loadingDimView,
            animationView,
            loadingLabel
        ].forEach { view.addSubview($0) }
        
        [
            frameImageView,
            textView,
            tagButton
        ].forEach { contentStackView.addArrangedSubview($0) }
    }
    
    func setupLayouts() {
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        textView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        
        frameImageView.snp.makeConstraints { make in
            make.width.height.equalTo(216)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(frameImageView).inset(8)
        }
        
        deleteImageButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(frameImageView)
        }
        
        toolbar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(48)
        }
        
        loadingDimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        animationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(245)
            make.height.equalTo(362)
        }
        
        loadingLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(animationView).offset(74)
        }
    }
    
    func setupBindings() {
        let deleteImageOkActionTapped: PublishSubject<Void> = .init()
        let navigatToBackOkActionTapped: PublishSubject<Void> = .init()
        let tagSelected: PublishSubject<Tag?> = .init()
        
        let input = RegisterViewModel.Input(
            textDidChanged: textView.rx.didChange.asObservable(),
            textChanged: textView.rx.text.asObservable(),
            backButtonTapped: backButton.rx.tap.asObservable(),
            navigatToBackOkActionTapped: navigatToBackOkActionTapped.asObservable(),
            registerButtonTapped: registerButton.rx.tap.asObservable(),
            imageViewTapped: frameImageView.rx.tapGesture().when(.recognized).asObservable(),
            deleteTagButtonTapped: tagButton.rx.tap.asObservable(),
            deleteImageButtonTapped: deleteImageButton.rx.tap.asObservable(),
            deleteImageOkActionTapped: deleteImageOkActionTapped.asObservable(),
            addImageButtonTapped: addImageButton.rx.tap.asObservable(),
            addTagButtonTapped: addTagButton.rx.tap.asObservable(),
            tagSelected: tagSelected.asObservable(),
            keyboardButtonTapped: keyboardToggleButton.rx.tap.asObservable(),
            keyboardWillShow: NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification),
            imageSelected: imagePicker.rx.didFinishPickingMediaWithInfo.asObservable()
        )
        let output = viewModel.transform(input: input)
        // MARK: - TextView가 자동으로 줄어들고 늘어나는 로직, minHeight / maxHeight 으로 최소 높이, 최대 높이 설정
        output.textDidChanged
            .bind { [weak self] in
                guard let self = self else { return }
                
                let size = CGSize(width: self.view.frame.width, height: .infinity)
                let estimatedSize = self.textView.sizeThatFits(size)
                
                // 최소 높이와 최대 높이를 적용하여 높이를 제한합니다.
                let constrainedHeight = max(Constants.minHeight, min(estimatedSize.height, Constants.maxHeight))
                
                self.textView.constraints.forEach { (constraint) in
                    if constraint.firstAttribute == .height {
                        constraint.constant = constrainedHeight
                    }
                }
            }
            .disposed(by: disposeBag)
        
        output.canRegister.asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, isEnabled in
                owner.registerButton.isEnabled = isEnabled
                owner.registerButton.tintColor = isEnabled ? .primary900 : .gray200
            }
            .disposed(by: disposeBag)
                
        output.showNavigateToBackAlert.asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, isShow in
                if isShow {
                    owner.showPopUp(
                        title: nil,
                        message: Constants.navigateToBackAlertMessage,
                        leftActionTitle: Constants.alertNoAction,
                        rightActionTitle: Constants.alertYesActon,
                        rightActionCompletion: {
                            navigatToBackOkActionTapped.onNext(())
                        }
                    )
                } else {
                    navigatToBackOkActionTapped.onNext(())
                }
            }
            .disposed(by: disposeBag)
        
        output.showImagePicker.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.requestPhotoLibraryAuthorization()
            }
            .disposed(by: disposeBag)
        
        output.shwoDeleteImageAlert.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.showPopUp(
                    title: Constants.deleteImageAlertTitle,
                    message: nil,
                    leftActionTitle: Constants.alertNoAction,
                    rightActionTitle: Constants.alertYesActon,
                    rightActionCompletion: {
                        deleteImageOkActionTapped.onNext(())
                    }
                )
            }
            .disposed(by: disposeBag)
        
        output.showTagListViewController.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                let viewModel = TagListViewModel(tagSelected: tagSelected)
                let viewController = TagListViewController(viewModel: viewModel)
                let navigationController = UINavigationController(rootViewController: viewController)
                navigationController.sheetPresentationController?.detents = [.medium()]
                navigationController.sheetPresentationController?.prefersGrabberVisible = false
                owner.show(navigationController, sender: nil)
            }
            .disposed(by: disposeBag)
        
        output.showFullImageViewController.asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, image in
                let viewController = FullImageViewController(image: image)
                viewController.modalPresentationStyle = .overFullScreen
                owner.present(viewController, animated: false)
            }
            .disposed(by: disposeBag)
        
        output.post.asDriver(onErrorJustReturn: .init())
            .drive(with: self) { owner, post in
                // image
                owner.imageView.image = post.image
                owner.imageView.isHidden = (post.image == nil)
                owner.frameImageView.isHidden = (post.image == nil)
                owner.addImageButton.isEnabled = (post.image == nil)
                owner.imagePicker.dismiss(animated: true)
                
                // tag
                if post.tag == nil {
                    owner.tagButton.isHidden = true
                } else {
                    var configuration = owner.tagButton.configuration
                    var container = AttributeContainer()
                    container.font = UIFont(name: "Pretendard-Medium", size: 14)
                    configuration?.attributedTitle = AttributedString(post.tag?.tagName ?? "", attributes: container)
                    configuration?.baseBackgroundColor = .tagColor(for: post.tag?.tagColorId ?? 0)
                    configuration?.baseForegroundColor = .gray700
                    owner.tagButton.configuration = configuration
                    owner.tagButton.isHidden = false
                }
                
                // comments
                owner.textView.text = post.comments
            }
            .disposed(by: disposeBag)
        
        output.showLoadingView.asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, isHidden in
                owner.loadingDimView.isHidden = !isHidden
                owner.animationView.isHidden = !isHidden
                owner.loadingLabel.isHidden = !isHidden
            }
            .disposed(by: disposeBag)
        
        output.navigateToDetail.asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, postId in
                guard let postId = postId else { return }
                let viewController = PostDetailViewController(viewModel: .init(postId: postId))
                owner.navigationController?.pushViewController(viewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.navigateToBack.asDriver(onErrorJustReturn: ())
            .debug()
            .drive(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        keyboardToggleButton.rx.tap.asDriver()
            .drive(with: self) { owner, _ in
                if owner.textView.isFirstResponder {
                    owner.keyboardToggleButton.image = .init(named: "toolbar.keyboard.up")
                    owner.textView.resignFirstResponder()
                } else {
                    owner.keyboardToggleButton.image = .init(named: "toolbar.keyboard.down")
                    owner.textView.becomeFirstResponder()
                }
            }
            .disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(with: self) { owner, keyboardVisibleHeight in
                owner.toolbar.snp.updateConstraints { make in
                    make.bottom.equalTo(owner.view.safeAreaLayoutGuide.snp.bottom).offset(-keyboardVisibleHeight)
                }
                owner.view.setNeedsLayout()
            }
            .disposed(by: disposeBag)
        
        textView.rx.didBeginEditing.asDriver()
            .drive(with: self) { owner, _ in
                if owner.textView.textColor == Constants.textViewPlaceholderColor
                    && owner.textView.text == Constants.textViewPlaceholder {
                    owner.textView.text = nil
                    owner.textView.textColor = Constants.textViewTextColor
                }
            }
            .disposed(by: disposeBag)
        
        textView.rx.didEndEditing.asDriver()
            .drive(with: self) { owner, _ in
                if owner.textView.text.isEmpty {
                    owner.textView.text = Constants.textViewPlaceholder
                    owner.textView.textColor = Constants.textViewPlaceholderColor
                }
            }
            .disposed(by: disposeBag)
    }
    
}

// MARK: 이미지 처리

extension RegisterViewController {
    
    func showImagePickerSourceTypeSelectionAlert() {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.showImagePickerController(for: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.requestPhotoLibraryAuthorization()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func requestPhotoLibraryAuthorization() {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .notDetermined, .restricted:
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    DispatchQueue.main.async { [weak self] in
                        self?.showImagePickerController(for: .photoLibrary)
                    }
                }
            }
        case .denied:
            DispatchQueue.main.async { [weak self] in
                self?.showPhotoLibraryAuthorizationAlert()
            }
        case .authorized, .limited:
            DispatchQueue.main.async { [weak self] in
                self?.showImagePickerController(for: .photoLibrary)
            }
        @unknown default: break
        }
    }
    
    func showImagePickerController(for sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: nil, message: "\(sourceType)에 접근할 수 없습니다", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func showPhotoLibraryAuthorizationAlert() {
        let viewController = PhotoLibraryAuthorizationViewController()
        viewController.sheetPresentationController?.detents = [.medium()]
        viewController.sheetPresentationController?.prefersGrabberVisible = true
        present(viewController, animated: true, completion: nil)
    }
    
}
