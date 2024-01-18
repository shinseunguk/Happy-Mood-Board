//
//  UpdateNotification.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 1/17/24.
//

import Foundation

struct HappyItem: Codable {
    let active: Bool
    let dayOfWeek: [Int]
    let time: String
}

struct MarketingParameter: Encodable {
    let active: Bool
}

struct MarketingResponse: Decodable {
    let active: Bool
    let updatedAt: String
}
