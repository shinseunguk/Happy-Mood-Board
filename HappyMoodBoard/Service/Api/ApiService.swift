//
//  ApiService.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/09.
//

import Foundation

import RxSwift
import RxAlamofire

final class ApiService {
    
    func request<T: Decodable>(type: T.Type, target: TargetType) -> Observable<T?> {
        return RxAlamofire
            .request(target, interceptor: AuthInterceptor())
            .validate()
            .responseData()
            .map { _, data -> T? in
                do {
                    let result = try JSONDecoder().decode(BaseResponse<T>.self, from: data)
                    return result.responseData
                } catch {
                    throw ApiError.decodingError
                }
            }
            .catch { error in
                if case let .requestRetryFailed(retryError, _) = error.asAFError {
                    throw retryError
                }
                throw error
            }
            .observe(on: MainScheduler.instance)
    }
    
}

enum ApiError: LocalizedError {
    case decodingError
    case failed(ErrorResponse)
    case unknown
}

extension ApiError {
    var errorDescription: String? {
        switch self {
        case .decodingError:
            return "Failed to decode the object from the service"
        case .failed(let response):
            return response.message
        case .unknown:
            return "The error is unknown"
        }
    }
}
