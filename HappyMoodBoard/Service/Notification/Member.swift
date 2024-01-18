//
//  Member.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 1/15/24.
//

import Foundation

struct MemberResponse: Decodable {
    let happyItem: HappyItemData
    let marketing: MarketingData
}

struct HappyItemData: Decodable {
    let active: Bool
    let dayOfWeek: [Int]
    let time: String
}

struct MarketingData: Decodable {
    let active: Bool
    let updatedAt: String
}

