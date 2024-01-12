//
//  ErrorResponse.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/09.
//

import Foundation

struct ErrorResponse: Decodable {
    let code: Int
    let message: String
    let timestamp: Int
}
