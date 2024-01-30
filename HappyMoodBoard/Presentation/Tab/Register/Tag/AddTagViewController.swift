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
    
    private let titleLabel: UILabel = .init().then {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.17
        $0.attributedText = NSMutableAttributedString(
            string: "태그 생성",
            attributes: [
                NSAttributedString.Key.kern: -0.36,
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                .font: UIFont(name: "Pretendard-Bold", size: 18),
                .foregroundColor: UIColor.gray900
            ]
        )
    }
    
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
    
    private lazy var nameStackView = UIStackView(
        arrangedSubviews: [
            nameLabel,
            nameTextField
        ]).then {
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
    
    private let doneButton: UIBarButtonItem = .init(
                title: "완료",
                style: .plain,
                target: nil,
                action: nil
            )
    
    private lazy var toolbar = UIToolbar().then {
        $0.sizeToFit()
        $0.items = [.flexibleSpace(), doneButton]
    }
    
    private lazy var buttonStackView: UIStackView = .init(
        arrangedSubviews: [
            completeButton,
            dismissButton
    ]
    ).then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 16
    }
    private let completeButton: UIButton = .init(type: .system).then {
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
    }
    
    private let dismissButton: UIButton = .init(type: .system).then {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Pretendard-Medium", size: 16),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.gray900 // 원하는 색상으로 설정
        ]
        let attributedTitle = NSAttributedString(string: "닫기", attributes: attributes)
        $0.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    private let viewModel: AddTagViewModel
    private let disposeBag: DisposeBag = .init()
    
    init(viewModel: AddTagViewModel = .init()) {
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
    
}

extension AddTagViewController: ViewAttributes {
    
    func setupNavigationBar() {
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItems = [.init(customView: titleLabel)]
    }
    
    func setupSubviews() {
        view.setCornerRadiusForTopCorners(radius: 30)
        
        [
            contentStackView,
            buttonStackView
        ].forEach { view.addSubview($0) }
        
        [
            nameStackView,
            colorStackView,
            errorLabel,
            
        ].forEach { contentStackView.addArrangedSubview($0) }
        
//
//        nameTextField.inputAccessoryView = toolbar
    }
    
    func setupLayouts() {
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.leading.trailing.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-26)
            make.leading.trailing.equalToSuperview()
        }
        
        completeButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        
        dismissButton.snp.makeConstraints { make in
            make.height.equalTo(41)
        }
    }
    
    func setupBindings() {
        doneButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.nameTextField.resignFirstResponder()
                // 추가로 필요한 동작을 수행할 수 있습니다.
            })
            .disposed(by: disposeBag)
        
//        RxKeyboard.instance.visibleHeight
//            .drive(with: self) { owner, keyboardVisibleHeight in
//                owner.completeButton.snp.updateConstraints {
//                    $0.bottom.equalTo(owner.view.safeAreaLayoutGuide.snp.bottom).offset(-keyboardVisibleHeight)
//                }
//                owner.view.setNeedsLayout()
//            }
//            .disposed(by: disposeBag)
        
        let colorButtons = colorButtonStackView.arrangedSubviews.compactMap { $0 as? UIButton }
        let colorButtonTapped = Observable.from(colorButtons.map { button in
            button.rx.tap.map { button }
        })
            .merge()
            .share()
        let colorButtonSelected = colorButtonTapped
            .map { colorButtons.firstIndex(of: $0) ?? 0 }
        
        let input = AddTagViewModel.Input(
            name: nameTextField.rx.text.orEmpty.asObservable(),
            colorButtonTapped: colorButtonSelected,
            completeButtonTapped: completeButton.rx.tap.asObservable(),
            dismissButtonTapped: dismissButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        output.title.asDriver(onErrorJustReturn: "")
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.hasExistingTag.asDriver(onErrorJustReturn: true)
            .drive(with: self) { owner, hasExistingTag in
                owner.dismissButton.isHidden = hasExistingTag
                let offset: CGFloat = hasExistingTag ? -26 : 0
                owner.buttonStackView.snp.updateConstraints { make in
                    make.bottom.equalTo(owner.view.safeAreaLayoutGuide.snp.bottom).offset(offset)
                }
            }
            .disposed(by: disposeBag)
        
        output.tag.asDriver(onErrorJustReturn: .init())
            .drive(with: self) { owner, tag in
                owner.nameTextField.text = tag.tagName
                for (index, colorButton) in colorButtons.enumerated() {
                    colorButton.isSelected = (index == tag.tagColorId)
                }
            }.disposed(by: disposeBag)

        output.dismiss.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.navigateToBack.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.errorMessage.asDriver(onErrorJustReturn: "")
            .drive(errorLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
}
