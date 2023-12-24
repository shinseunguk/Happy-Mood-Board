//
//  AgreeViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/07.
//

import UIKit

import Then
import SnapKit

import RxSwift
import RxCocoa

final class AgreeViewController: UIViewController {

    private let pageOneLabel = UILabel().then {
        $0.text = "1"
        $0.textColor = .gray900
        $0.textAlignment = .center
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
        $0.layer.cornerRadius = 10
        $0.layer.backgroundColor = UIColor.primary400?.cgColor
    }

    private let pageTwoLabel = UILabel().then {
        $0.text = "2"
        $0.textColor = .gray400
        $0.textAlignment = .center
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
        $0.layer.cornerRadius = 10
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = UIFont(name: "Pretendard-Bold", size: 24)
        $0.numberOfLines = 0
        $0.text = "회원가입을 위해\n약관에 동의해 주세요."
    }
    
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 16
    }
    
    private let allOptionsButton = AgreeCheckboxButton(type: .all)
    
    private let dividerView = UIView().then {
        $0.backgroundColor = .gray200
    }
    
    private let ageButton = AgreeCheckboxButton(type: .ageRequirements)
    private let termsButton = AgreeCheckboxButton(type: .terms)
    private let privacyPolicyButton = AgreeCheckboxButton(type: .privacyPolicy)
    private let marketingEmailButton = AgreeCheckboxButton(type: .marketingEmail)
    
    private let nextButton = UIButton(type: .system).then {
        $0.configurationUpdateHandler = { button in
            var container = AttributeContainer()
            container.font = UIFont(name: "Pretendard-Bold", size: 16)
            container.foregroundColor = button.isEnabled ? .gray900 : .gray400
            var configuration = UIButton.Configuration.filled()
            configuration.cornerStyle = .capsule
            configuration.background.backgroundColor = button.isEnabled ? .primary500 : .gray200
            configuration.attributedTitle = AttributedString("다음", attributes: container)
            button.configuration = configuration
        }
        $0.isEnabled = false
    }
    
    // MARK: Properties
    
    private let viewModel: AgreeViewModel = .init()
    private let disposeBag: DisposeBag = .init()
    
    // MARK: View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCommonBackgroundColor()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
    
}

// MARK: - ViewAttributes

extension AgreeViewController: ViewAttributes {
    
    func setupSubviews() {
        [
            pageOneLabel,
            pageTwoLabel,
            titleLabel,
            contentStackView,
            nextButton
        ].forEach { view.addSubview($0) }
        
        [
            allOptionsButton,
            dividerView,
            ageButton,
            termsButton,
            privacyPolicyButton,
            marketingEmailButton
        ].forEach { contentStackView.addArrangedSubview($0) }
    }
    
    func setupLayouts() {
        pageOneLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.equalToSuperview().inset(24)
            make.width.height.equalTo(20)
        }

        pageTwoLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.equalTo(pageOneLabel.snp.trailing).offset(4)
            make.width.height.equalTo(20)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(pageOneLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
        }
        
        dividerView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(1)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-26)
            make.height.equalTo(52)
        }
    }
    
    func setupBindings() {
        let input = AgreeViewModel.Input(
            agreeToAllOptions: allOptionsButton.checkboxButton.rx.tap.asObservable(),
            agreeToAgeRequirements: ageButton.checkboxButton.rx.tap.asObservable(),
            agreeToPrivacyPolicy: privacyPolicyButton.checkboxButton.rx.tap.asObservable(),
            agreeToTerms: termsButton.checkboxButton.rx.tap.asObservable(),
            agreeToMarketingEmail: marketingEmailButton.checkboxButton.rx.tap.asObservable(),
            navigateToPrivacyPolicy: privacyPolicyButton.disclosureButton.rx.tap.asObservable(),
            navigateToTerms: termsButton.disclosureButton.rx.tap.asObservable(),
            navigateToMarketingEmail: marketingEmailButton.disclosureButton.rx.tap.asObservable(),
            navigateToNextStep: nextButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)
        output.agreeToAllOptions.asDriver(onErrorJustReturn: false)
            .drive(allOptionsButton.checkboxButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        output.agreeToAge.asDriver(onErrorJustReturn: false)
            .drive(ageButton.checkboxButton.rx.isSelected)
            .disposed(by: disposeBag)
            
        output.agreeToPrivacyPolicy.asDriver(onErrorJustReturn: false)
            .drive(privacyPolicyButton.checkboxButton.rx.isSelected)
            .disposed(by: disposeBag)
            
        output.agreeToTerms.asDriver(onErrorJustReturn: false)
            .drive(termsButton.checkboxButton.rx.isSelected)
            .disposed(by: disposeBag)
            
        output.agreeToMarketingEmail.asDriver(onErrorJustReturn: false)
            .drive(marketingEmailButton.checkboxButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        output.agreeToAllOptions.asDriver(onErrorJustReturn: false)
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)

        output.navigateToNextStep
            .bind { [weak self] in
                let viewController = EnterNicknameViewController()
                self?.show(viewController, sender: nil)
            }
            .disposed(by: disposeBag)
    }
    
}
