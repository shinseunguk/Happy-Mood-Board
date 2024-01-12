//
//  TitleDayOfWeekView.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/6/24.
//

import Foundation

import SnapKit
import Then

final class TitleDayOfWeekView: UIView, ViewAttributes {
    
    private let titleLabel = CustomLabel(
        font: UIFont(name: "Pretendard-Regular", size: 16),
        textColor: UIColor.black,
        text: nil
    )
    
    private let contentStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
        $0.distribution = .fillProportionally
//        $0.layer.borderWidth = 1
    }
    
    private let mondayButton = PushNotificationButton(
        title: DayOfTheWeek.monday.title,
        titleColor: .black,
        titleFont: UIFont(name: "Pretendard-Regular", size: 14) ?? UIFont(),
        backgroundColor: .gray200 ?? UIColor(),
        radius: 4
    )

    private let tuesdayButton = PushNotificationButton(
        title: DayOfTheWeek.tuesday.title,
        titleColor: .black,
        titleFont: UIFont(name: "Pretendard-Regular", size: 14) ?? UIFont(),
        backgroundColor: .gray200 ?? UIColor(),
        radius: 4
    )

    private let wednesdayButton = PushNotificationButton(
        title: DayOfTheWeek.wednesday.title,
        titleColor: .black,
        titleFont: UIFont(name: "Pretendard-Regular", size: 14) ?? UIFont(),
        backgroundColor: .gray200 ?? UIColor(),
        radius: 4
    )

    private let thursdayButton = PushNotificationButton(
        title: DayOfTheWeek.thursday.title,
        titleColor: .black,
        titleFont: UIFont(name: "Pretendard-Regular", size: 14) ?? UIFont(),
        backgroundColor: .gray200 ?? UIColor(),
        radius: 4
    )

    private let fridayButton = PushNotificationButton(
        title: DayOfTheWeek.friday.title,
        titleColor: .black,
        titleFont: UIFont(name: "Pretendard-Regular", size: 14) ?? UIFont(),
        backgroundColor: .gray200 ?? UIColor(),
        radius: 4
    )
    
    private let saturdayButton = PushNotificationButton(
        title: DayOfTheWeek.saturday.title,
        titleColor: .black,
        titleFont: UIFont(name: "Pretendard-Regular", size: 14) ?? UIFont(),
        backgroundColor: .gray200 ?? UIColor(),
        radius: 4
    )

    private let sundayButton = PushNotificationButton(
        title: DayOfTheWeek.sunday.title,
        titleColor: .black,
        titleFont: UIFont(name: "Pretendard-Regular", size: 14) ?? UIFont(),
        backgroundColor: .gray200 ?? UIColor(),
        radius: 4
    )


    private let everydayButton = PushNotificationButton(
        title: DayOfTheWeek.everyday.title,
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
            contentStackView
        ].forEach { addSubview($0) }
        
        [
            mondayButton,
            tuesdayButton,
            wednesdayButton,
            thursdayButton,
            fridayButton,
            saturdayButton,
            sundayButton,
            everydayButton
        ].forEach { contentStackView.addArrangedSubview($0) }

    }
    
    func setupLayouts() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(45)
        }
    }
    
    func setupBindings() {
        
    }
}
