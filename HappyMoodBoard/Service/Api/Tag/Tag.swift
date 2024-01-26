//
//  Tag.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/02.
//

import Foundation

struct Tag: Codable, Equatable {
    let id: Int?
    let tagName: String?
    let tagColorId: Int
}

extension Tag {
    init() {
        self.init(id: nil, tagName: nil, tagColorId: 0)
    }
}
