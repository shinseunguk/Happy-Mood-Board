//
//  NotificationTarget.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 1/15/24.
//

import Foundation

import Alamofire

enum NotificationTarget {
    case member
    case happyItem(HappyItem)
    case marketing(MarketingParameter)
}

extension NotificationTarget: TargetType {
    var baseURL: String { environment.rawValue }
    
    var method: HTTPMethod {
        switch self {
        case .member:
            return .get
        case .happyItem:
            return .put
        case .marketing:
            return .put
        }
    }
    
    var path: String {
        switch self {
        case .member:
            return "/api/notification/v1/member"
        case .happyItem:
            return "/api/notification/v1/member/happy-item"
        case .marketing:
            return "/api/notification/v1/member/marketing"
        }
    }
    
    var parameters: RequestParameters? {
        switch self {
        case .happyItem(let parameters):
            return .body(parameters)
        case .marketing(let parameters):
            return .body(parameters)
        default:
            return nil
        }
    }
}
