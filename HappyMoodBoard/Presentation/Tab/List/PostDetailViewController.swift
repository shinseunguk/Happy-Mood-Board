//
//  PostDetailViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/18.
//

import UIKit

import Then
import SnapKit

import RxSwift
import RxCocoa

final class PostDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    enum Constants {
        static let deleteAlertTitle = "삭제하시겠어요?"
        static let deleteAlertMessage = "삭제된 행복 아이템은 복구할 수 없어요!"
        static let deleteAlertNoAction = "아니오"
        static let deleteAlertYesActon = "네"
    }
    
    private let backButton: UIBarButtonItem = .init(
        image: .init(named: "navigation.back"),
        style: .plain,
        target: nil,
        action: nil
    )
    
    private let moreButton: UIBarButtonItem = .init(
        image: .init(named: "navigation.more"),
        style: .done,
        target: nil,
        action: nil
    )
    
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.distribution = .fill
        $0.spacing = 24
    }
    
    private let dateLabel: UILabel = .init().then {
        $0.textColor = .primary900
        $0.font = UIFont(name: "Pretendard-Regular", size: 16)
        $0.numberOfLines = 1
        let verticalInset: CGFloat = 8
        let horizontalInset: CGFloat = 24
        $0.layoutMargins = .init(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
    
    private let imageView: UIImageView = .init().then {
        $0.isHidden = true
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let commentLabel: UILabel = .init().then {
        $0.textColor = .gray900
        $0.font = UIFont(name: "Pretendard-Regular", size: 16)
        $0.numberOfLines = 0
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
        $0.configuration = configuration
        $0.isHidden = true
    }
    
    private let viewModel: PostDetailViewModel
    private let disposeBag: DisposeBag = .init()
    
    init(viewModel: PostDetailViewModel) {
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

extension PostDetailViewController: ViewAttributes {
    
    func setupNavigationBar() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = moreButton
    }
    
    func setupSubviews() {
        [
            dateLabel,
            contentStackView
        ].forEach { view.addSubview($0) }
        
        [
            imageView,
            commentLabel,
            tagButton
        ].forEach { contentStackView.addArrangedSubview($0) }
    }
    
    func setupLayouts() {
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(8)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }
    }
    
    func setupBindings() {
        let editActionTapped: PublishSubject<Void> = .init()
        let deleteActionTapped: PublishSubject<Void> = .init()
        let deleteOkActionTapped: PublishSubject<Void> = .init()
        
        let input = PostDetailViewModel.Input(
            viewWillAppear: rx.viewWillAppear.asObservable(),
            backButtonTapped: backButton.rx.tap.asObservable(),
            moreButtonTapped: moreButton.rx.tap.asObservable(),
            editActionTapped: editActionTapped.asObservable(),
            deleteActionTapped: deleteActionTapped.asObservable(),
            deleteOkActionTapped: deleteOkActionTapped.asObservable()
        )
        let output = viewModel.transform(input: input)
        output.date.asDriver(onErrorJustReturn: "")
            .drive(dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.image.asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, image in
                guard let image = image else {
                    owner.imageView.isHidden = true
                    return
                }
                owner.imageView.isHidden = false
                owner.imageView.image = image
            }
            .disposed(by: disposeBag)
        
        output.comment.asDriver(onErrorJustReturn: "")
            .drive(commentLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.tag.asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, tag in
                guard let tag = tag else {
                    owner.tagButton.isHidden = true
                    return
                }
                var configuration = owner.tagButton.configuration
                var container = AttributeContainer()
                container.font = UIFont(name: "Pretendard-Medium", size: 14)
                configuration?.attributedTitle = AttributedString(tag.tagName ?? "", attributes: container)
                configuration?.baseBackgroundColor = .tagColor(for: tag.tagColorId)
                configuration?.baseForegroundColor = .gray700
                owner.tagButton.configuration = configuration
                owner.tagButton.isHidden = false
            }
            .disposed(by: disposeBag)
        
        output.showActionSheet.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                let viewController = PostDetailModalViewController()
                viewController.addAction(title: "수정하기") {
                    viewController.dismiss(animated: true) {
                        editActionTapped.onNext(())
                    }
                }
                viewController.addAction(title: "삭제하기") {
                    viewController.dismiss(animated: true) {
                        deleteActionTapped.onNext(())
                    }
                }
                viewController.modalPresentationStyle = .custom
                viewController.transitioningDelegate = owner
                owner.present(viewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.navigateToEdit.asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, post in
                // TODO: RegisterViewModel 수정
                let viewController = RegisterViewController()
                owner.navigationController?.pushViewController(viewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.showDeleteAlert.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.showPopUp(
                    title: Constants.deleteAlertTitle,
                    message: Constants.deleteAlertMessage,
                    leftActionTitle: Constants.deleteAlertNoAction,
                    rightActionTitle: Constants.deleteAlertYesActon,
                    rightActionCompletion: {
                        deleteOkActionTapped.onNext(())
                    }
                )
            }
            .disposed(by: disposeBag)
        
        output.navigateToBack.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.navigationController?.popToRootViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate

extension PostDetailViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
