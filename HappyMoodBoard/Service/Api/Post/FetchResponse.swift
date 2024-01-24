//
//  FetchResponse.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/21/24.
//

import Foundation

struct Post: Decodable {
    let createdAt: String
    let updatedAt: String
    let id: Int
    let postTag: PostTag?
    let memberId: Int
    let comments: String?
    let imagePath: String?
    let tagId: Int?
}

struct PostTag: Decodable {
    let createdAt: String
    let updatedAt: String
    let id: Int
    let memberId: Int
    let tagName: String
    let tagColorId: Int
}

