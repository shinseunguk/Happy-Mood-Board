//
//  UpdatePostTag.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/09.
//

import Foundation

struct UpdatePostTagParameters: Encodable {
    let tagId: Int?
    let tagName: String
    let tagColorId: Int
}

struct PostTagResponse: Decodable {
    let tagId: Int
}
