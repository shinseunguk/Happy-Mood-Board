//
//  NotificationModalViewController.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 1/5/24.
//

import Foundation

import Then
import SnapKit

import RxSwift
import RxCocoa

protocol NotificationModalDelegate: AnyObject {
    func didDismissModal()
}

final class NotificationModalViewController: UIViewController, ViewAttributes {
    weak var delegate: NotificationModalDelegate?
    
    private let guideLabel = UILabel().then {
        $0.font = UIFont(name: "Pretendard-Bold", size: 22)
        $0.textColor = .black
        $0.text = "기기의 알림 설정이 꺼진 상태입니다."
        $0.textAlignment = .center
        $0.sizeToFit()
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = UIFont(name: "Pretendard-Regular", size: 16)
        $0.textColor = .black
        $0.text = "알림 수신을 위해 시스템 설정에서\n알림을 허용해 주세요."
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.sizeToFit()
    }
    
    private let goToSettingButton = UIButton(type: .system).then {
        $0.configurationUpdateHandler = { button in
            var container = AttributeContainer()
            container.font = UIFont(name: "Pretendard-Bold", size: 16)
            container.foregroundColor = button.isEnabled ? .gray900 : .gray400
            var configuration = UIButton.Configuration.filled()
            configuration.cornerStyle = .capsule
            configuration.background.backgroundColor = .primary500
            configuration.attributedTitle = AttributedString("설정 바로 가기", attributes: container)
            button.configuration = configuration
        }
    }
    
    private let dismissButton = UIButton(type: .system).then {
        let title = "닫기"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Pretendard-Medium", size: 16),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.black // 원하는 색상으로 설정
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        $0.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    private let disposeBag: DisposeBag = .init()
    private let viewModel: NotificationModalViewModel = .init()
    
    override func viewDidLoad() {
        setCommonBackgroundColor()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
}

extension NotificationModalViewController {
    func setupSubviews() {
        [
            guideLabel,
            descriptionLabel,
            goToSettingButton,
            dismissButton
        ].forEach { self.view.addSubview($0) }
        
        self.view.layer.cornerRadius = 15
    }
    
    func setupLayouts() {
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(52)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(40)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(guideLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        goToSettingButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
        
        dismissButton.snp.makeConstraints {
            $0.top.equalTo(goToSettingButton.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupBindings() {
        let input = NotificationModalViewModel.Input(
            prefNotification: goToSettingButton.rx.tap.asObservable(),
            dismiss: dismissButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.prefNotification
            .bind { [weak self] in
                let prefURL = NSURL(string:"App-prefs:root=NOTIFICATIONS_ID")! as URL
                UIApplication.shared.open(prefURL)
                
                self?.delegate?.didDismissModal()
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.dismiss
            .bind { [weak self] in
                
                self?.delegate?.didDismissModal()
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
