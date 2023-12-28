//
//  VersionInfoButton.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/25/23.
//

import Foundation

import Then
import SnapKit

final class VersionInfoButton: UIButton {
    
    private let customLabel = UILabel().then {
        $0.font = UIFont(name: "Pretendard-Regula", size: 16)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.textColor = .init(hexString: "#BEBCB9")
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
        $0.text = "최신 버전이에요."
    }
    
    private let versionLabel = UILabel().then {
        $0.textColor = .init(hexString: "#FF5D5D")
    }
    
    init(type: SettingType) {
        super.init(frame: .zero)
        
        setupSubviews()
        setupLayouts()
        
        customLabel.text = type.title
        versionLabel.text = fetchAppVersion()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        [
            customLabel,
            descriptionLabel,
            versionLabel
        ].forEach { addSubview($0) }
    }
    
    func setupLayouts() {
        customLabel.snp.makeConstraints {
            $0.bottom.equalTo(self.snp.centerY).offset(2)
            $0.leading.equalTo(24)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.centerY).offset(2)
            $0.leading.equalTo(customLabel)
        }
        
        versionLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(-15.25)
        }
    }
}
