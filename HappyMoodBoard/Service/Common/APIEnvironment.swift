//
//  APIEnvironment.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/09.
//

import Foundation

enum APIEnvironment: String {
    case dev = "https://dev.beehappy.today"
    case production = "https://api.beehappy.today"
    
    var url: URL? { .init(string: rawValue) }
}

let environment: APIEnvironment = .dev
