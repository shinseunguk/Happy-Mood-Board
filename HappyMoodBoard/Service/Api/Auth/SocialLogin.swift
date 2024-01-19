//
//  SocialLogin.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/8.
//

import Foundation

struct SocialLoginParameters: Encodable {
    let accessToken: String
    let provider: String
    let deviceToken: String
    let deviceType: String
    let deviceId: String
}

struct TestSocialLoginParameters: Encodable {
    let provider: String
    let providerId: String
    let deviceToken: String
    let deviceType: String
    let deviceId: String
}

struct SocialLoginResponse: Decodable {
    let status: String
    let accessToken: String
    let refreshToken: String
}
