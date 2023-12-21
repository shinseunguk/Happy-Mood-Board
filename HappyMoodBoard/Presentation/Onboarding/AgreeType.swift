//
//  AgreeType.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/07.
//

import Foundation

enum AgreeType {
    
    case ageRequirements
    case terms
    case privacyPolicy
    case marketingEmail
    case all
    
    var title: String {
        switch self {
        case .ageRequirements:
            return "만 14세 이상입니다."
        case .terms:
            return "이용약관 동의"
        case .privacyPolicy:
            return "개인정보 수집 및 이용 동의"
        case .marketingEmail:
            return "이벤트, 혜택 등 마케팅 수신 동의"
        case .all:
            return "모두 동의합니다."
        }
    }
    
    var option: String? {
        switch self {
        case .all:
            return nil
        case .marketingEmail:
            return "선택"
        default:
            return "필수"
        }
    }
    
    var showDisclosureButton: Bool {
        switch self {
        case .all, .ageRequirements:
            return false
        default:
            return true
        }
    }
    
    public func url(withBaseUrl baseUrl: URL) -> URL? {
        switch self {
        case .terms:
            return baseUrl.appendingPathComponent("terms-of-use")
        case .privacyPolicy:
            return baseUrl.appendingPathComponent("privacy")
        case .marketingEmail:
            return baseUrl.appendingPathComponent("marketing")
        default:
            return nil
        }
    }
    
}
