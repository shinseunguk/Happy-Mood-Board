//
//  TagTarget.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/09.
//

import Foundation

import Alamofire

enum TagTarget {
    case create(UpdatePostTagParameters)
    case update(UpdatePostTagParameters)
    case fetch(Int? = nil)
    case delete(Int)
}

extension TagTarget: TargetType {
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
        return "/api/v1/post/tag"
    }
    
    var parameters: RequestParameters? {
        switch self {
        case .create(let parameters):
            return .body(parameters)
        case .update(let parameters):
            return .body(parameters)
        case .fetch(let parameters):
            guard let parameters = parameters else { return .none }
            return .query([
                "tagId": parameters
            ])
        case .delete(let parameters):
            return .query([
                "tagId": parameters
            ])
        }
    }
}
