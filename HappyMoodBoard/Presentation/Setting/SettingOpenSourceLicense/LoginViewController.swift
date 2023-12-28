//
//  LoginViewController.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/28/23.
//

import Foundation

import Then
import SnapKit

import RxSwift
import RxCocoa

final class LoginViewController: UIViewController, ViewAttributes {
    
    private let kakaoLoginButton = SocialLoginButton(type: .kakao)
    private let appleLoginButton = SocialLoginButton(type: .apple)
    
    private let viewModel: LoginViewModel = .init()
    private let disposeBag: DisposeBag = .init()
    
    override func viewDidLoad() {
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
}

extension LoginViewController {
    func setupSubviews() {
        [
            kakaoLoginButton,
            appleLoginButton
        ].forEach { self.view.addSubview($0) }
    }
    
    func setupLayouts() {
        appleLoginButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-26)
            $0.leading.equalTo(24)
            $0.trailing.equalTo(-24)
            $0.height.equalTo(52)
        }
        
        kakaoLoginButton.snp.makeConstraints {
            $0.leading.trailing.height.equalTo(appleLoginButton)
            $0.bottom.equalTo(appleLoginButton.snp.top).offset(-16)
        }
    }
    
    func setupBindings() {
     
        let input = LoginViewModel.Input(
            kakaoLogin: kakaoLoginButton.rx.tap.asObservable(),
            appleLogin: appleLoginButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 카카오 로그인
        output.kakaoLogin.bind { [weak self] in
            print("카카오 로그인")
        }
        
        // 애플 로그인
        output.appleLogin.bind { [weak self] in
            print("애플 로그인")
        }
    }
}
