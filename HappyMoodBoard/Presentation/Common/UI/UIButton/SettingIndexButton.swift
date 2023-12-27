//
//  SettingIndexButton.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/24/23.
//

import Foundation

import Then
import SnapKit

final class SettingIndexButton: UIButton {
    
    private let customLabel = UILabel().then {
        $0.font = UIFont(name: "Pretendard-Regula", size: 16)
    }
    
    private let disclosureButton = UIButton().then {
        $0.setImage(UIImage(named: "arrow.right"), for: .normal)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    init(type: SettingType) {
        super.init(frame: .zero)
        
        setupSubviews()
        setupLayouts()
        
        customLabel.text = type.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        [
            customLabel,
            disclosureButton
        ].forEach { addSubview($0) }
    }
    
    func setupLayouts() {
        customLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(24)
        }
        
        disclosureButton.snp.makeConstraints {
            $0.centerY.equalTo(customLabel)
            $0.trailing.equalTo(-15.25)
        }
    }
}
