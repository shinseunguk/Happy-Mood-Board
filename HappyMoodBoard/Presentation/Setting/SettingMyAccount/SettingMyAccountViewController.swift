//
//  SettingMyAccountViewController.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/25/23.
//

import Foundation

import Then
import SnapKit

import RxSwift
import RxCocoa
import RxGesture

final class SettingMyAccountViewController: UIViewController ,ViewAttributes, UIGestureRecognizerDelegate {
    
    // 네비게이션
    private let navigationTitle = NavigationTitle(title: "내 계정")
    private let navigationItemBack = NavigtaionItemBack()
    //
    
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 0
    }
    
    private let nicknameView = AccountView(type: .nickname)
    private let connectAccountView = AccountView(type: .connectAccount)
    private let emailView = AccountView(type: .email)
    
    private let viewModel: SettingMyAccountViewModel = .init()
    private let disposeBag: DisposeBag = .init()
    
    override func viewDidLoad() {
        
        setCommonBackgroundColor()
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
}

extension SettingMyAccountViewController {
    func setupNavigationBar() {
        self.navigationItem.titleView = navigationTitle
        self.navigationItem.leftBarButtonItem = navigationItemBack
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func setupSubviews() {
        self.view.addSubview(contentStackView)
        
        [
            nicknameView,
            connectAccountView,
            emailView
        ].forEach{ self.contentStackView.addArrangedSubview($0) }
    }
    
    func setupLayouts() {
        [
            nicknameView,
            connectAccountView,
            emailView
        ].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(56)
            }
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(24)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    func setupBindings() {
        let input = SettingMyAccountViewModel.Input(
            navigateToBack: navigationItemBack.rxTap.asObservable(),
            navigateToNextStep: nicknameView.rx.tapGesture().when(.recognized),
            viewWillAppear: rx.viewWillAppear.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.navigateToBack.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        .disposed(by: disposeBag)
        
        output.navigateToNextStep.bind { [weak self] _ in
            let VC = ModifyNickNameViewController()
            self?.show(VC, sender: nil)
        }
        .disposed(by: disposeBag)
        
        output.myInfo.bind { [weak self] result in
            if let nickname = result?.nickname {
                self?.nicknameView.bindNickname(nickname: nickname)
            } else {
                self?.nicknameView.bindNickname(nickname: "알 수 없음")
            }
            
            if let provider = result?.provider {
                self?.connectAccountView.bindSocialLogin(provider: provider)
            } else {
                self?.connectAccountView.bindSocialLogin(provider: "알 수 없음")
            }
            
            if let email = result?.email {
                self?.emailView.bindEmail(email: email)
            } else {
                self?.emailView.bindEmail(email: "알 수 없음")
            }
        }
        .disposed(by: disposeBag)
    }
}
