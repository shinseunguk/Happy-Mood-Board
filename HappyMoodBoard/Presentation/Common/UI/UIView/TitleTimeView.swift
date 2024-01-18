//
//  TitleTimeView.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/6/24.
//

import Foundation

import SnapKit
import Then

import RxSwift

final class TitleTimeView: UIView, ViewAttributes {
    
    private let titleLabel = CustomLabel(
        text: nil,
        textColor: UIColor.black,
        font: UIFont(name: "Pretendard-Regular", size: 16)
    )
    
    private let timeButton = PushNotificationButton(
        title: nil,
        titleColor: .black,
        titleFont: UIFont(name: "Pretendard-Regular", size: 14) ?? UIFont(),
        backgroundColor: .gray200 ?? UIColor(),
        radius: 4
    )
    
    let timePublishSubject = PublishSubject<String>()
    let timeButtonEvent = PublishSubject<Void>()
    let disposeBag: DisposeBag = .init()
    
    init(type: SettingNotificationType) {
        super.init(frame: .zero)
        
        setupSubviews()
        setupLayouts()
        setupBindings()
        
        titleLabel.text = type.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TitleTimeView {
    func setupSubviews() {
        [
            titleLabel,
            timeButton
        ].forEach { addSubview($0) }
    }
    
    func setupLayouts() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(24)
        }
        
        timeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(24)
            $0.width.equalTo(81)
            $0.height.equalTo(29)
        }
    }
    
    func setupBindings() {
        timePublishSubject.asDriver(onErrorJustReturn: "")
            .map {
                convertTo12HourFormat(timeString: $0)
            }
            .drive(onNext: { [weak self] title in
                self?.timeButton.setTitle(title, for: .normal)
            })
            .disposed(by: disposeBag)
        
        timeButton.rx.tap
            .bind(to: timeButtonEvent)
            .disposed(by: disposeBag)
    }
}
