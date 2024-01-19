//
//  MemberTarget.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/09.
//

import Foundation

import Alamofire

enum MemberTarget {
    case consent(ConsentParameters)
    case me
    case nickname(UpdateNicknameParameters)
    case retire
    case review
}

extension MemberTarget: TargetType {
    var baseURL: String { environment.rawValue }
    
    var method: HTTPMethod {
        switch self {
        case .consent:
            return .post
        case .me:
            return .get
        case .nickname:
            return .put
        case .retire:
            return .delete
        case .review:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .consent:
            return "/api/member/v1/consent"
        case .me:
            return "/api/member/v1/me"
        case .nickname:
            return "/api/member/v1/nickname"
        case .retire:
            return "/api/member/v1/retire"
        case .review:
            return "/api/member/v1/review"
        }
    }
    
    var parameters: RequestParameters? {
        switch self {
        case .consent(let parameters):
            return .body(parameters)
        case .nickname(let parameters):
            return .body(parameters)
        default:
            return nil
        }
    }
}
