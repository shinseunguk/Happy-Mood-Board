//
//  LoginType.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/28/23.
//

import Foundation

enum LoginType {
    
    case apple
    case kakao
    
    var title: String {
        switch self {
        case .apple:
            return "apple"
        case .kakao:
            return "kakao"
        }
    }
}
