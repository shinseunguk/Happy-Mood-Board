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
            .observe(on: MainScheduler.instance)
            .responseData()
            .map { response, data -> T? in
                switch response.statusCode {
                case 200...299:
                    do {
                        let result = try JSONDecoder().decode(BaseResponse<T>.self, from: data)
                        traceLog(String(data: data, encoding: .utf8))
                        return result.responseData
                    } catch {
                        // TODO: 성공시 디코딩 에러 처리
                        print(
                            target.path,
                            "💥💥💥",
                            error.localizedDescription,
                            response.statusCode,
                            String(data: data, encoding: .utf8) ?? ""
                        )
                        throw ApiError.decodingError
                    }
                // TODO: case 400
                // TODO: default 케이스 ApiError에 추가
                default:
                    do {
                        let apiError = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        throw ApiError.failed(apiError)
                    } catch let decodingError as DecodingError {
                        print(
                            target.path,
                            "💥💥💥",
                            decodingError.localizedDescription,
                            response.statusCode,
                            String(data: data, encoding: .utf8) ?? ""
                        )
                        throw decodingError
                    } catch {
                        throw error
                    }
                }
            }
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
