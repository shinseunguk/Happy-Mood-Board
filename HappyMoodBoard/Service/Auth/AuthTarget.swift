//
//  AuthTarget.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/09.
//

import Foundation

import Alamofire

enum AuthTarget {
    case internalLogin(SocialLoginParameters) // 개발용 로그인/회원가입
    case login(SocialLoginParameters)
    case logout(LogoutParameters)
    case refresh(ReissueAccessTokenParameters)
}

extension AuthTarget: TargetType {
    var baseURL: String { environment.rawValue }
    
    var method: Alamofire.HTTPMethod {
        .post
    }
    
    var path: String {
        switch self {
        case .internalLogin:
            return "/test/api/auth/v1/login/social"
        case .login:
            return "/api/auth/v1/login/social"
        case .logout:
            return "/api/auth/v1/logout"
        case .refresh:
            return "/api/auth/v1/token/refresh"
        }
    }
    
    var parameters: RequestParameters? {
        switch self {
        case .internalLogin(let parameters):
            return .body(parameters)
        case .login(let parameters):
            return .body(parameters)
        case .logout(let parameters):
            return .body(parameters)
        case .refresh(let parameters):
            return .body(parameters)
        }
    }
}
