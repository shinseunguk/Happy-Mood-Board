//
//  AddTagViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/10.
//

import UIKit

import Then
import SnapKit

import RxSwift
import RxCocoa
import RxGesture
import RxKeyboard

final class AddTagViewController: UIViewController {
    
    private let editButton: UIBarButtonItem = .init(systemItem: .edit)
    
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 30
        let verticalInset: CGFloat = 8
        let horizontalInset: CGFloat = 24
        $0.layoutMargins = .init(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    private lazy var nameStackView = UIStackView(arrangedSubviews: [nameLabel, nameTextField]).then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 22
    }
    
    private let nameLabel = UILabel().then {
        $0.font = UIFont(name: "Pretendard-Bold", size: 16)
        $0.textColor = .gray700
        $0.text = "태그"
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    private let nameTextField = UITextField().then {
        $0.textColor = .gray900
        $0.font = UIFont(name: "Pretendard-Regular", size: 14)
        $0.attributedPlaceholder = .init(
            string: "최대 10자까지 쓸 수 있어요.",
            attributes: [
                .foregroundColor: UIColor.gray400
            ]
        )
    }
    
    private lazy var colorStackView = UIStackView(arrangedSubviews: [colorLabel, colorButtonStackView]).then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 22
    }
    
    private let colorLabel = UILabel().then {
        $0.font = UIFont(name: "Pretendard-Bold", size: 16)
        $0.textColor = .gray700
        $0.text = "색상"
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    private let colorButtonStackView = UIStackView().then { stackView in
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        UIColor.tagColors.forEach { tagColor in
            let image = UIImage(named: "circle.fill")?.withTintColor(tagColor!)
            let checkmarkImage = UIImage(named: "checkmark.circle 1")!
            let selectedImage = image?.withImage(checkmarkImage)
            let button = UIButton(frame: .init(x: 0, y: 0, width: 22, height: 22))
            button.setImage(image, for: .init())
            button.setImage(selectedImage, for: .selected)
            button.tintColor = tagColor
            stackView.addArrangedSubview(button)
        }
    }
    
    private let errorLabel = UILabel().then {
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
        $0.textColor = .accent100
        $0.textAlignment = .center
    }
    
    private let completeButton = UIButton(type: .system).then {
        $0.configurationUpdateHandler = { button in
            var container = AttributeContainer()
            container.font = UIFont(name: "Pretendard-Medium", size: 18)
            container.foregroundColor = button.isEnabled ? .gray900 : .gray400
            var configuration = UIButton.Configuration.filled()
            configuration.cornerStyle = .capsule
            configuration.background.backgroundColor = button.isEnabled ? .primary500 : .gray200
            configuration.attributedTitle = AttributedString("완료", attributes: container)
            button.configuration = configuration
        }
//        $0.isEnabled = false
    }
    
    private let viewModel: AddTagViewModel = .init()
    private let disposeBag: DisposeBag = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCommonBackgroundColor()
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
    
}

extension AddTagViewController: ViewAttributes {
    
    func setupNavigationBar() {
        navigationItem.title = "태그 생성"
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    func setupSubviews() {
        [
            contentStackView,
            completeButton
        ].forEach { view.addSubview($0) }
        
        [
            nameStackView,
            colorStackView,
            errorLabel
        ].forEach { contentStackView.addArrangedSubview($0) }
    
    }
    
    func setupLayouts() {
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.leading.trailing.equalToSuperview()
        }
        
        completeButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-26)
            make.height.equalTo(52)
        }
    }
    
    func setupBindings() {
        let colorButtons = colorButtonStackView.arrangedSubviews.compactMap { $0 as? UIButton }
//        colorButtons.first?.isSelected = true
        let colorButtonsTapped = Observable.from(
            colorButtons.map { button in
                button.rx.tap.map { button }
            }
        ).merge().startWith(colorButtons.first!)
        colorButtons.reduce(Disposables.create()) { disposable, button in
            let subscription = colorButtonsTapped.map { $0 == button }
                .bind(to: button.rx.isSelected)
            return Disposables.create(disposable, subscription)
        }
        .disposed(by: disposeBag)
        
        let input = AddTagViewModel.Input(
            name: nameTextField.rx.text.orEmpty.asObservable(),
            completeButtonTapped: completeButton.rx.tap.asObservable(),
            colorButtonTapped: colorButtonsTapped
        )
        
        let output = viewModel.transform(input: input)
        output.errorMessage.asDriver(onErrorJustReturn: "")
            .drive(errorLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.dismiss.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
}
