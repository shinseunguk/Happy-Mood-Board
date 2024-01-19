//
//  MyInformationResponse.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/10.
//

import Foundation

struct MyInformationResponse: Decodable {
    let nickname: String
    let provider: String
    let email: String
    let status: String
}
