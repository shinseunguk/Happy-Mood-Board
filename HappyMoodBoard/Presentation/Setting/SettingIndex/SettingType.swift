//
//  SettingType.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/24/23.
//

import Foundation


enum SettingType {
    
    case mySettings
    case notificationSettings
    case termsOfService
    case privacyPolicy
    case openSourceLicense
    case leaveReview
    case versionInformation
    case logout
    case withdrawMembership
    
    var title: String {
        switch self {
        case .mySettings:
            return "내 계정"
        case .notificationSettings:
            return "알림 설정"
        case .termsOfService:
            return "이용약관"
        case .privacyPolicy:
            return "개인정보 처리방침"
        case .openSourceLicense:
            return "오픈소스 라이센스"
        case .leaveReview:
            return "리뷰 남기기"
        case .versionInformation:
            return "버전 정보"
        case .logout:
            return "로그아웃"
        case .withdrawMembership:
            return "회원탈퇴"
        }
    }
}
