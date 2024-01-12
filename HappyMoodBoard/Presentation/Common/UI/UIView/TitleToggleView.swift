//
//  TitleToggleView.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/6/24.
//

import Foundation

import SnapKit
import Then

final class TitleToggleView: UIView, ViewAttributes {
    
    private let titleLabel = CustomLabel(
        font: UIFont(name: "Pretendard-Regular", size: 16),
        textColor: UIColor.black,
        text: nil
    )
    
    private let toggleButton = UISwitch().then {
        $0.onTintColor = .primary500
        $0.isOn = true
    }
    
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
            toggleButton
        ].forEach { addSubview($0) }
    }
    
    func setupLayouts() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(24)
        }
        
        toggleButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(24)
            $0.width.equalTo(44)
            $0.height.equalTo(24)
        }
    }
    
    func setupBindings() {
        
    }
}
