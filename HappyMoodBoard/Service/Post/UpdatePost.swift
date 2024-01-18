//
//  UpdatePost.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/18.
//

import Foundation

struct UpdatePostParameters: Encodable {
    let postId: Int?
    let tagId: Int?
    let comments: String?
    let imagePath: String?
}

struct UpdatePostResponse: Decodable {
    let postId: Int
}
