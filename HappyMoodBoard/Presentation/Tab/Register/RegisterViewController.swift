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

import RxSwift
import RxCocoa
import RxKeyboard

final class RegisterViewController: UIViewController {
    
    enum Constants {
        static let normalImage: UIImage = .init(named: "navigation.register.normal") ?? .init()
        static let disabledImage: UIImage = .init(named: "navigation.register.disabled") ?? .init()
        static let textViewPlaceholder: String = "최대 1000자까지 작성 가능해요."
        static let textViewPlaceholderColor: UIColor? = .gray400
        static let textViewTextColor: UIColor? = .gray900
    }
    
    private let backButton: UIBarButtonItem = .init(
        image: .init(named: "navigation.back"),
        style: .plain,
        target: nil,
        action: nil
    )
    
    private let registerButton: UIBarButtonItem = .init(
        image: .init(named: "navigation.register.normal"),
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
    }
    
    private let textView: UITextView = .init().then {
        $0.text = Constants.textViewPlaceholder
        $0.textColor = Constants.textViewPlaceholderColor
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
            addTagButton,
            .flexibleSpace(),
            keyboardToggleButton
        ]
        $0.barTintColor = .primary100
    }
    
    private let viewModel: RegisterViewModel = .init()
    private let disposeBag: DisposeBag = .init()
    
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
            toolbar
        ].forEach { view.addSubview($0) }
        
        [
            frameImageView,
            textView,
            tagButton
        ].forEach { contentStackView.addArrangedSubview($0) }
    }
    
    func setupLayouts() {
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
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
    }
    
    func setupBindings() {
        let deleteImageAlertActionTapped = deleteImageButton.rx.tap
            .flatMap {
                self.showAlert(
                    title: nil,
                    message: "사진을 삭제하시겠어요?",
                    style: .alert,
                    actions: [
                        .action(title: "아니오", style: .cancel),
                        .action(title: "네", style: .default)
                    ]
                )
            }
        
        let addTagButtonTapped = addTagButton.rx.tap
            .flatMap {
                self.showTagListViewController()
            }
        
        let input = RegisterViewModel.Input(
            textChanged: textView.rx.text.asObservable(),
            backButtonTapped: backButton.rx.tap.asObservable(),
            registerButtonTapped: registerButton.rx.tap.asObservable(),
            deleteImageAlertActionTapped: deleteImageAlertActionTapped,
            addImageButtonTapped: addImageButton.rx.tap.asObservable(),
            addTagButtonTapped: addTagButton.rx.tap.asObservable(),
            keyboardButtonTapped: keyboardToggleButton.rx.tap.asObservable(),
            keyboardWillShow: NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification),
            imageSelected: imagePicker.rx.didFinishPickingMediaWithInfo.asObservable()
        )
        let output = viewModel.transform(input: input)
        output.canRegister
            .withUnretained(self)
            .subscribe(onNext: { owner, isEnabled in
                owner.registerButton.image = isEnabled ? Constants.normalImage : Constants.disabledImage
            })
            .disposed(by: disposeBag)
        
        output.navigateToBack
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: false)
            })
            .disposed(by: disposeBag)
        
        output.showImagePicker
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.requestPhotoLibraryAuthorization()
            })
            .disposed(by: disposeBag)
        
        output.showTagListViewController.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.showTagListViewController()
            }
            .disposed(by: disposeBag)
        
        output.image
            .withUnretained(self)
            .subscribe(onNext: { onwer, image in
                onwer.imageView.image = image
                onwer.imageView.isHidden = (image == nil)
                onwer.frameImageView.isHidden = (image == nil)
                onwer.addImageButton.isEnabled = (image == nil)
                onwer.imagePicker.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        output.tag
            .withUnretained(self)
            .subscribe { owner, tag in
                guard let tag = tag else {
                    owner.tagButton.isHidden = true
                    return
                }
                var configuration = owner.tagButton.configuration
                var container = AttributeContainer()
                container.font = UIFont(name: "Pretendard-Medium", size: 14)
                configuration?.attributedTitle = AttributedString(tag.name, attributes: container)
                configuration?.baseBackgroundColor = .init(hexString: tag.color)
                configuration?.baseForegroundColor = .gray700
                owner.tagButton.configuration = configuration
                owner.tagButton.isHidden = false
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
                if owner.textView.textColor == Constants.textViewPlaceholderColor {
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
    
    func showTagListViewController() -> Observable<Void> {
        return Observable.create { observer in
            let viewController = UIViewController()
            viewController.sheetPresentationController?.detents = [.medium()]
            viewController.sheetPresentationController?.prefersGrabberVisible = true
            self.present(viewController, animated: true, completion: nil)
            return Disposables.create {
                viewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
