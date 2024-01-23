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
        $0.textColor = .gray400
        $0.textAlignment = .center
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
        $0.layer.cornerRadius = 10
    }
    
    private let pageTwoLabel = UILabel().then {
        $0.text = "2"
        $0.textColor = .accent100
        $0.textAlignment = .center
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
        $0.layer.cornerRadius = 10
        $0.layer.backgroundColor = UIColor.primary400?.cgColor
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = UIFont(name: "Pretendard-Bold", size: 24)
        $0.numberOfLines = 0
        $0.text = "회원님만의\n애칭을 알려주세요."
    }
    
    private let nicknameTextField = UITextField().then {
        $0.textColor = .gray900
        $0.font = UIFont(name: "Pretendard-Bold", size: 22)
        $0.attributedPlaceholder = .init(
            string: "최대 10자까지 쓸 수 있어요.",
            attributes: [
                .foregroundColor: UIColor.gray400
            ]
        )
    }
    
    private let divider = UIView().then {
        $0.backgroundColor = .primary500
    }
    
    private let infoLabel = UILabel().then {
        $0.textColor = .gray400
        $0.font = UIFont(name: "Pretendard-Regular", size: 14)
        $0.text = "닉네임은 나중에도 변경 가능해요."
    }
    
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
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-26)
            make.height.equalTo(52)
        }
    }
    
    func setupBindings() {
        let input = EnterNicknameViewModel.Input(
            nickname: nicknameTextField.rx.text.orEmpty.asObservable(),
            navigateToHome: nextButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.nickname.asDriver(onErrorRecover: { _ in .empty() })
            .drive(nicknameTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.nextButtonEnabled.asDriver(onErrorJustReturn: false)
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.navigateTohome.asDriver(onErrorRecover: { _ in .empty() })
            .drive(with: self) { owner, _ in
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
                owner.show(tabBarController, sender: nil)
            }
            .disposed(by: disposeBag)
    }
    
}
