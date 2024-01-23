//
//  SettingNotificationType.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/6/24.
//

import Foundation

enum SettingNotificationType {
    case recordPushOnOff
    case dayOfTheWeek
    case time
    case marketingPushOnOff
    
    var title: String {
        switch self {
        case .recordPushOnOff:
            return "행복아이템 기록 알림 받기"
        case .dayOfTheWeek:
            return "요일"
        case .time:
            return "시간"
        case .marketingPushOnOff:
            return "이벤트·혜택 알림 받기"
        }
        
    }
}
