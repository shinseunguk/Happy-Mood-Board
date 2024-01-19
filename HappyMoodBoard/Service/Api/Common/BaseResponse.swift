//
//  BaseResponse.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/09.
//

import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let timestamp: Int
    let responseData: T?
    
    private enum CodingKeys: String, CodingKey {
        case responseData = "data"
        case timestamp = "timestamp"
    }
}

// Empty Data 처리를 위함
struct Empty: Decodable { }
