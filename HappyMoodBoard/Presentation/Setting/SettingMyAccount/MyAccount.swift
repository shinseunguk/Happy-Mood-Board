//
//  MyAccount.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/3/24.
//

import Foundation

enum MyAccount {
    case nickname
    case connectAccount
    case email
    
    var title: String {
        switch self {
        case .nickname:
            return "닉네임"
        case .connectAccount:
            return "연결된 계정"
        case .email:
            return "이메일"
        }
    }
}
