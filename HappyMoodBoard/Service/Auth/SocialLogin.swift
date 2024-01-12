//
//  SocialLogin.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/8.
//

import Foundation

struct SocialLoginParameters: Encodable {
    let provider: ProviderType
    let providerId: String
    let deviceToken: String
    let deviceType: DeviceType
    let deviceId: String
}

struct SocialLoginResponse: Decodable {
    let status: String
    let accessToken: String
    let refreshToken: String
}
