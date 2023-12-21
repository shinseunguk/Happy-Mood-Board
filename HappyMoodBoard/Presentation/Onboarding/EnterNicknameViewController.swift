//
//  EnterNicknameViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/09.
//

import UIKit

import Then
import SnapKit

import RxSwift
import RxCocoa

final class EnterNicknameViewController: UIViewController, ViewAttributes {

    private let pageOneLabel = UILabel().then {
        $0.text = "1"
        $0.textColor = .init(hexString: "#AEAEAE")
        $0.textAlignment = .center
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
        $0.layer.cornerRadius = 10
    }

    private let pageTwoLabel = UILabel().then {
        $0.text = "2"
        $0.textColor = .init(hexString: "#242424")
        $0.textAlignment = .center
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
        $0.layer.cornerRadius = 10
        $0.layer.backgroundColor = UIColor(hexString: "#FFDF7C")?.cgColor
    }

    private let titleLabel = UILabel().then {
        $0.textColor = .label
        $0.font = UIFont(name: "Pretendard-Bold", size: 24)
        $0.numberOfLines = 0
        $0.text = "회원님만의\n애칭을 알려주세요."
    }
    
    private let nicknameTextField = UITextField().then {
        $0.textColor = .init(hexString: "#242424")
        $0.font = UIFont(name: "Pretendard-Bold", size: 20)
        $0.placeholder = "최대 10자까지 쓸 수 있어요."
    }
    
    private let divider = UIView().then {
        $0.backgroundColor = .init(hexString: "#FFCE53")
    }
    
    private let infoLabel = UILabel().then {
        $0.textColor = .init(hexString: "#AEAEAE")
        $0.font = UIFont(name: "Pretendard-Regular", size: 14)
        $0.text = "* 특수문자는 쓸 수 없어요"
    }
    
    private let nextButton = UIButton(type: .system).then {
        $0.configurationUpdateHandler = { button in
            var container = AttributeContainer()
            container.font = UIFont(name: "Pretendard-Bold", size: 16)
            container.foregroundColor = button.isEnabled ? .init(hexString: "#555555") : .init(hexString: "#888888")
            var configuration = UIButton.Configuration.filled()
            configuration.cornerStyle = .capsule
            configuration.background.backgroundColor = button.isEnabled ? .init(hexString: "#FFCE53") : .init(hexString: "#DFDFDF")
            configuration.attributedTitle = AttributedString("다음", attributes: container)
            button.configuration = configuration
        }
        $0.isEnabled = false
    }

    private let viewModel: EnterNicknameViewModel = .init()
    private let disposeBag: DisposeBag = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCommonBackgroundColor()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
    
    func setupSubviews() {
        [
            pageOneLabel,
            pageTwoLabel,
            titleLabel,
            nicknameTextField,
            divider,
            infoLabel,
            nextButton
        ].forEach { view.addSubview($0) }
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
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        divider.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(16)
            make.height.equalTo(2)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-60)
            make.height.equalTo(52)
        }
    }
    
    func setupBindings() {
        let input = EnterNicknameViewModel.Input(
            nickname: nicknameTextField.rx.text.orEmpty.asObservable(),
            navigateToHome: nextButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)

        output.nickname
            .bind(to: nicknameTextField.rx.text)
            .disposed(by: disposeBag)

        output.isValid
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)

        output.navigateTohome
            .bind { [weak self] in
                let viewController = UIViewController()
                self?.show(viewController, sender: nil)
            }
            .disposed(by: disposeBag)
    }
    
}
