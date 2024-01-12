//
//  TitleTimeView.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/6/24.
//

import Foundation

import SnapKit
import Then

final class TitleTimeView: UIView, ViewAttributes {
    
    private let titleLabel = CustomLabel(
        font: UIFont(name: "Pretendard-Regular", size: 16),
        textColor: UIColor.black,
        text: nil
    )
    
    private let timeButton = PushNotificationButton(
        title: "오후 8:00",
        titleColor: .black,
        titleFont: UIFont(name: "Pretendard-Regular", size: 14) ?? UIFont(),
        backgroundColor: .gray200 ?? UIColor(),
        radius: 4
    )
    
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
        
    }
}
