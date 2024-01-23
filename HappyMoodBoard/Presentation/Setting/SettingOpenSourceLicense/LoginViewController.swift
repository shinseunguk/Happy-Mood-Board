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

enum MemberStatus: String {
    case REQUIRED_CONSENT = "REQUIRED_CONSENT"
    case REQUIRED_NICKNAME = "REQUIRED_NICKNAME"
    case ACTIVE = "ACTIVE"
    case SUSPEND = "SUSPEND"
}

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
        .disposed(by: disposeBag)
        
        // 애플 로그인
        output.appleLogin
            .bind { [weak self] result in
                
                switch result {
                case MemberStatus.REQUIRED_CONSENT.rawValue: // 약관 동의 전 (= 회원가입 미완료 / 약관동의 화면 렌더링)
                    let viewController = AgreeViewController()
                    self?.show(viewController, sender: nil)
                    
                case MemberStatus.REQUIRED_NICKNAME.rawValue: // 닉네임 최초 설정 전 (= 회원가입 미완료 / 닉네임 설정 화면 렌더링)
                    let viewController = EnterNicknameViewController()
                    self?.show(viewController, sender: nil)
                    
                case MemberStatus.ACTIVE.rawValue: // 회원
                    let imageInsets: UIEdgeInsets = .init(top: 13, left: 0, bottom: 0, right: 0)
                    
                    // home
                    let homeViewController = HomeViewController()
                    homeViewController.tabBarItem.image = .init(named: "tabbar.home")
                    homeViewController.tabBarItem.selectedImage = .init(named: "tabbar.home.selected")
                    homeViewController.tabBarItem.imageInsets = imageInsets
                    let homeNavigationController = UINavigationController(rootViewController: homeViewController)
                    
                    // register
                    let registerViewController = UIViewController()
                    registerViewController.tabBarItem.image = .init(named: "tabbar.register")
                    registerViewController.tabBarItem.imageInsets = imageInsets
                    
                    // list
                    let listViewController = MyTabViewController()
                    listViewController.tabBarItem.image = .init(named: "tabbar.list")
                    listViewController.tabBarItem.selectedImage = .init(named: "tabbar.list.selected")
                    listViewController.tabBarItem.imageInsets = imageInsets
                    let listNavigationController = UINavigationController(rootViewController: listViewController)
                    
                    // tab
                    let tabBarController = TabBarController()
                    tabBarController.viewControllers = [
                        homeNavigationController,
                        registerViewController,
                        listNavigationController
                    ]
                    self?.show(tabBarController, sender: nil)
                    
                case MemberStatus.SUSPEND.rawValue: // 차단된 회원
                    self?.showPopUp(
                        title: "차단",
                        message: "차단된 회원입니다."
                        )
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
}
