//
//  PostTarget.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/18.
//

import Foundation

import Alamofire

enum PostTarget {
    case create(UpdatePostParameters)
    case update(UpdatePostParameters)
    case fetch(FetchPostParamaters)
    case delete(Int)
}

extension PostTarget: TargetType {
    var baseURL: String { environment.rawValue }
    
    var method: HTTPMethod {
        switch self {
        case .create:
            return .post
        case .update:
            return .put
        case .fetch:
            return .get
        case .delete:
            return .delete
        }
    }
    
    var path: String {
        return "/api/v1/post"
    }
    
    var parameters: RequestParameters? {
        switch self {
        case .create(let parameters):
            return .body(parameters)
        case .update(let parameters):
            return .body(parameters)
        case .fetch(let parameters):
            return .query(parameters)
        case .delete(let parameters):
            return .query([
                "postId": parameters
            ])
        }
    }
}
