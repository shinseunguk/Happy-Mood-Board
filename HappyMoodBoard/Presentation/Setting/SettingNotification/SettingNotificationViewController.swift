//
//  SettingNotificationViewController.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/25/23.
//

import Foundation

import Then
import SnapKit

import RxSwift
import RxCocoa
import RxViewController


final class SettingNotificationViewController: UIViewController, ViewAttributes, UIGestureRecognizerDelegate {
    
    // 네비게이션
    private let navigationTitle = NavigationTitle(title: "알림 설정")
    private let navigationItemBack = NavigtaionItemBack()
    //
    
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 20
    }
    
    private let recordPushOnOffView = TitleToggleView(type: .recordPushOnOff)
    private let titleDayOfWeekView = TitleDayOfWeekView(type: .dayOfTheWeek)
    private let titleTimeView = TitleTimeView(type: .time)
    private let marketingPushOnOffView = TitleToggleView(type: .marketingPushOnOff)
    
    private let disposeBag: DisposeBag = .init()
    private let viewModel: SettingNotificationViewModel = .init()
    
    override func viewDidLoad() {
        
        setCommonBackgroundColor()
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
}

extension SettingNotificationViewController {
    func setupNavigationBar() {
        self.navigationItem.titleView = navigationTitle
        self.navigationItem.leftBarButtonItem = navigationItemBack
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func setupSubviews() {
        [
            contentStackView
        ].forEach { self.view.addSubview($0) }
        
        [
            recordPushOnOffView,
            titleDayOfWeekView,
            titleTimeView,
            marketingPushOnOffView
        ].forEach { self.contentStackView.addArrangedSubview($0) }
    }
    
    func setupLayouts() {
        [
            recordPushOnOffView,
            titleDayOfWeekView,
            titleTimeView,
            marketingPushOnOffView,
        ].enumerated().forEach { index, view in
//            view.layer.borderWidth = 1
            view.snp.makeConstraints {
                if index == 1 {
//                    view.layer.borderColor = UIColor.red.cgColor
                    $0.height.equalTo(75)
                } else {
                    $0.height.equalTo(40)
                }
            }
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(24)
            $0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func setupBindings() {
        let input = SettingNotificationViewModel.Input(
            navigateToBack: navigationItemBack.rxTap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.navigateToBack.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
