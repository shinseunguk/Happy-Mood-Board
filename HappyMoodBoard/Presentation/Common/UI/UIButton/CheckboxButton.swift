//
//  CheckboxButton.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/07.
//

import UIKit

import Then
import SnapKit

final class CheckboxButton: UIButton {
    
    init() {
        super.init(frame: .zero)
        var configuration = UIButton.Configuration.gray()
        configuration.baseForegroundColor = .gray900
        configuration.baseBackgroundColor = .clear
        self.configuration = configuration
        self.setImage(UIImage(named: "circle"), for: .init())
        self.setImage(UIImage(named: "checkmark.circle"), for: .highlighted)
        self.setImage(UIImage(named: "checkmark.circle"), for: .selected)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

final class AgreeCheckboxButton: UIView {
    
    private let contentStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 12
    }
    
    let checkboxButton = CheckboxButton().then {
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    private let labelStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 4
    }
    
    private let optionLabel = UILabel().then {
        $0.font = UIFont(name: "Pretendard-Regular", size: 14)
        $0.textColor = .accent100
        $0.textAlignment = .center
        $0.backgroundColor = .primary300
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }

    private let titleLabel = UILabel().then {
        $0.font = UIFont(name: "Pretendard-Regular", size: 16)
        $0.textColor = .gray900
        $0.textAlignment = .left
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    let disclosureButton = UIButton().then {
        $0.setImage(UIImage(named: "arrow.right"), for: .normal)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    init(type: AgreeType) {
        super.init(frame: .zero)
        addSubview(contentStackView)
        [
            checkboxButton,
            labelStackView,
            disclosureButton
        ].forEach { contentStackView.addArrangedSubview($0) }
        [
            optionLabel,
            titleLabel
        ].forEach { labelStackView.addArrangedSubview($0) }
        
        contentStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        checkboxButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        optionLabel.snp.makeConstraints { make in
            make.width.equalTo(39)
        }

        titleLabel.text = type.title
        optionLabel.isHidden = type.option == nil
        optionLabel.text = type.option
        disclosureButton.isHidden = !type.showDisclosureButton
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
