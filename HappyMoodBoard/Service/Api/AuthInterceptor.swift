//
//  AuthInterceptor.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/09.
//

import Foundation

import Alamofire

final class AuthInterceptor: RequestInterceptor {
    
    enum Key: String {
        case accessToken
        case refreshToken
    }
    
    private let retryLimit = 3
    private let retryDelay: TimeInterval = 1
    
    private var accessToken: String {
        UserDefaults.standard.string(forKey: Key.accessToken.rawValue) ?? .init()
    }
    
    private var refreshToken: String {
        UserDefaults.standard.string(forKey: Key.refreshToken.rawValue) ?? .init()
    }
    
    // MARK: RequestAdaptor
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        // TODO: urlRequest.url이 서버인지 체크하는 로직 추가
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: accessToken))
        completion(.success(urlRequest))
    }

    // MARK: RequestRetrier
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let _ = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        guard let data = (request as? DataRequest)?.data,
              let apiError = try? JSONDecoder().decode(ErrorResponse.self, from: data) else {
            completion(.retry)
            return
        }
        
        switch apiError.code {
        case 100_000:
            // TODO: 로그인 페이지로 이동
            completion(.doNotRetryWithError(error))
        case 100_003:
            // accessToken 만료됨
            // refreshToken을 이용하여 accessToken 재발급
            guard var request = try? AuthTarget.refresh(.init(token: refreshToken)).asURLRequest() else {
                completion(.doNotRetryWithError(error))
                return
            }
            request.headers.add(.authorization(bearerToken: accessToken))
            AF.request(request)
                .validate()
                .responseDecodable(of: BaseResponse<ReissueAccessTokenResponse>.self) { response in
                    switch response.result {
                    case .success(let result):
                        guard let accessToken = result.responseData?.token else {
                            completion(.doNotRetryWithError(error))
                            return
                        }
                        UserDefaults.standard.setValue(accessToken, forKey: Key.accessToken.rawValue)
                        completion(.retry)
                    case .failure(let error):
                        // TODO: 리프레쉬 토큰이 만료된 경우 다시 로그인을 통해 엑세스 토큰과 리프레쉬 토큰을 재발급
                        completion(.doNotRetryWithError(error))
                    }
                }
        default:
            completion(.doNotRetryWithError(error))
        }
    }
    
}
