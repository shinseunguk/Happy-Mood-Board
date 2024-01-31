//
//  SettingIndexViewController.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 12/22/23.
//

import Foundation
import StoreKit

import Then
import SnapKit

import RxSwift
import RxCocoa


final class SettingIndexViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // 네비게이션
    private let navigationTitle = NavigationTitle(title: "설정")
    private let navigationItemBack = NavigtaionItemBack()
    //
    
    private let contentStackViewTop = UIStackView().then {
        $0.backgroundColor = .primary100
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 0
    }
    
    private let dividerViewTop = UIView().then {
        $0.backgroundColor = .init(hexString: "#DFDFDF")
    }
    
    private let contentStackViewMiddle = UIStackView().then {
        $0.backgroundColor = .primary100
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 0
    }
    
    private let dividerViewBottom = UIView().then {
        $0.backgroundColor = .init(hexString: "#DFDFDF")
    }
    
    private let contentStackViewBottom = UIStackView().then {
        $0.backgroundColor = .primary100
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 0
    }
    
    let dimView = UIView().then {
        $0.backgroundColor = .black
        $0.alpha = 0.0
    }
    private let accountSettingButton = SettingIndexButton(type: .mySettings)
    private let notificationSettingButton = SettingIndexButton(type: .notificationSettings)
    private let termsOfServiceButton = SettingIndexButton(type: .termsOfService)
    private let privacyPolicyButton = SettingIndexButton(type: .privacyPolicy)
    private let openSourceLicenseButton = SettingIndexButton(type: .openSourceLicense)
    private let leaveReviewButton = SettingIndexButton(type: .leaveReview)
    
    private let versionInformationButton = VersionInfoButton(type: .versionInformation)
    
    private let logoutButton = SettingIndexButton(type: .logout)
    private let withdrawMembershipButton = SettingIndexButton(type: .withdrawMembership)
    
    override func viewDidLoad() {
        
        setCommonBackgroundColor()
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
    
    private let viewModel: SettingIndexViewModel = .init()
    private let disposeBag: DisposeBag = .init()
}

extension SettingIndexViewController: ViewAttributes, NotificationModalDelegate {
    func didDismissModal() {
        self.dimView.alpha = 0.0
    }
    
    func setupNavigationBar() {
        self.navigationItem.titleView = navigationTitle
        self.navigationItem.leftBarButtonItem = navigationItemBack
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func setupSubviews() {
        [
            contentStackViewTop,
            dividerViewTop,
            contentStackViewMiddle,
            dividerViewBottom,
            contentStackViewBottom,
            dimView
        ].forEach { self.view.addSubview($0) }
        
        [
            accountSettingButton,
            notificationSettingButton
        ].forEach { self.contentStackViewTop.addArrangedSubview($0) }
        
        [
            termsOfServiceButton,
            privacyPolicyButton,
            openSourceLicenseButton,
            leaveReviewButton,
            versionInformationButton
        ].forEach { self.contentStackViewMiddle.addArrangedSubview($0) }
        
        [
            logoutButton,
            withdrawMembershipButton
        ].forEach { self.contentStackViewBottom.addArrangedSubview($0) }
        
        
    }
    
    func setupLayouts() {
        [
            accountSettingButton,
            notificationSettingButton,
            termsOfServiceButton,
            privacyPolicyButton,
            openSourceLicenseButton,
            leaveReviewButton,
            versionInformationButton,
            logoutButton,
            withdrawMembershipButton
        ].forEach { object in
            (object as UIButton).snp.makeConstraints {
                $0.height.equalTo(56)
            }
            
            //            object.layer.borderWidth = 1
        }
        
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentStackViewTop.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(24)
            $0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        dividerViewTop.snp.makeConstraints {
            $0.top.equalTo(contentStackViewTop.snp.bottom).offset(8)
            $0.width.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        contentStackViewMiddle.snp.makeConstraints {
            $0.top.equalTo(dividerViewTop.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        dividerViewBottom.snp.makeConstraints {
            $0.top.equalTo(contentStackViewMiddle.snp.bottom).offset(8)
            $0.width.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        contentStackViewBottom.snp.makeConstraints {
            $0.top.equalTo(dividerViewBottom.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func setupBindings() {
        let logoutAction = PublishSubject<Void>()
        let withdrawAction = PublishSubject<Void>()
        
        let input = SettingIndexViewModel.Input(
            viewWillAppear: rx.viewWillAppear.asObservable(),
            navigationBack: navigationItemBack.rxTap,
            mySettings: accountSettingButton.rx.tap.asObservable(),
            notificationSettings: notificationSettingButton.rx.tap.asObservable(),
            termsOfService: termsOfServiceButton.rx.tap.asObservable(),
            privacyPolicy: privacyPolicyButton.rx.tap.asObservable(),
            openSourceLicense: openSourceLicenseButton.rx.tap.asObservable(),
            leaveReview: leaveReviewButton.rx.tap.asObservable(),
            versionInformation: versionInformationButton.rx.tap.asObservable(),
            logout: logoutButton.rx.tap.asObservable(),
            logoutAction: logoutAction.asObservable(),
            withdrawMembership: withdrawMembershipButton.rx.tap.asObservable(),
            withdrawAction: withdrawAction.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        // MARK: - 네비게이션 뒤로가기
        output.navigationBack.bind { [weak self] in
            print("네비게이션 뒤로가기")
            self?.navigationController?.popViewController(animated: true)
        }
        .disposed(by: disposeBag)
        
        // 내 계정
        // MARK: - 내 계정
        output.mySettings.bind { [weak self] in
            let viewController = SettingMyAccountViewController()
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        .disposed(by: disposeBag)
        
        // MARK: - 알림 설정
        output.notificationSettings
            .withLatestFrom(viewModel.isSystemNotificationEnabled())
            .bind { [weak self] handler in
                
                if handler {
                    self?.dimView.alpha = 0.0
                    
                    let viewController = SettingNotificationViewController()
                    self?.navigationController?.pushViewController(viewController, animated: true)
                } else {
                    self?.dimView.alpha = 0.5
                    
                    let VC = NotificationModalViewController(direction: .bottom, viewSize: (.full, .fit))
                    VC.delegate = self
                    
                    self?.present(VC, animated: true, completion: nil)
                }
        }
        .disposed(by: disposeBag)
        
        // MARK: - 이용 약관
        output.termsOfService.bind { [weak self] in
            let viewController = SettingWebViewController(type: .termsOfService)
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        .disposed(by: disposeBag)
        
        // MARK: - 개인정보 처리방침
        output.privacyPolicy.bind { [weak self] in
            let viewController = SettingWebViewController(type: .privacyPolicy)
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        .disposed(by: disposeBag)
        
        // 오픈소스 라이센스
        // MARK: - 오픈소스 라이센스
        output.openSourceLicense.bind { [weak self] in
            let viewController = SettingWebViewController(type: .openSourceLicense)
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        .disposed(by: disposeBag)
        
        // MARK: - 리뷰 남기기
        output.leaveReview.bind {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                // SKStoreReviewController.requestReview(in:)를 호출하여 리뷰 요청을 합니다.
                SKStoreReviewController.requestReview(in: windowScene)
            } else {
                makeToast("리뷰 남기기 에러")
            }
        }
        .disposed(by: disposeBag)
        
        // MARK: - 리뷰 description
        output.checkVersion.asDriver(onErrorJustReturn: "")
            .drive(versionInformationButton.descriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
        // MARK: - 리뷰 터치시, 업데이트가 필요하면 OpenAppStore
        output.versionInformation.bind { [weak self] in
            $0 ? self?.viewModel.openAppStore() : nil
        }
        .disposed(by: disposeBag)
        
        // MARK: - 로그아웃
        output.logout.bind { [weak self] in
            self?.showPopUp(
                title: "로그아웃",
                message: "로그아웃 하시겠습니까?",
                leftActionTitle: "아니오",
                rightActionTitle: "네",
                rightActionCompletion: {
                    logoutAction.onNext(())
                })
        }
        .disposed(by: disposeBag)
        
        // MARK: - 로그아웃 서버 response 이후
        output.logoutSuccess.bind { [weak self] in
            UserDefaults.standard.set(false, forKey: "autoLogin")
            self?.setRootViewController(LoginViewController())
        }
        .disposed(by: disposeBag)
        
        output.logoutError.bind {
            makeToast($0)
        }
        .disposed(by: disposeBag)
        
        // MARK: - 회원탈퇴
        output.withdrawMembership.bind { [weak self] in
            self?.showPopUp(
                title: "회원탈퇴",
                message: "회원탈퇴 이후에는 기록한 행복 아이템과\n저장된 모든 것을 볼 수 없어요.\n정말로 탈퇴하시겠습니까?",
                leftActionTitle: "유지하기",
                rightActionTitle: "탈퇴하기",
                rightActionCompletion: {
                    withdrawAction.onNext(())
                })
        }
        .disposed(by: disposeBag)
        
        // MARK: - 회원탈퇴 서버 response 이후
        output.withdrawSuccess.bind { [weak self] in
            UserDefaults.standard.set(false, forKey: "autoLogin")
            self?.setRootViewController(LoginViewController())
        }
        .disposed(by: disposeBag)
        
        output.withdrawError.bind {
            makeToast($0)
        }
        .disposed(by: disposeBag)
    }
    
    // 루트 뷰 컨트롤러를 설정하는 함수
    func setRootViewController(_ viewController: UIViewController) {
        if let window = UIApplication.shared.windows.first {
            let rootViewController = viewController
            let navigationController = UINavigationController(rootViewController: rootViewController)
            navigationController.isNavigationBarHidden = true
            window.rootViewController = navigationController
            window.backgroundColor = .primary100
            window.makeKeyAndVisible()
        }
    }
}
