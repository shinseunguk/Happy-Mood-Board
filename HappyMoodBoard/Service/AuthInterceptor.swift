//
//  AuthInterceptor.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/09.
//

import Foundation

import Alamofire

class AuthInterceptor: RequestInterceptor {
    
    let retryLimit = 3
    let retryDelay: TimeInterval = 1
    
    // TODO: UserDefaults에 저장된 값으로 accessToken 설정
    var accessToken: String {
        "eyJhbGciOiJIUzI1NiJ9.eyJtZW1iZXJJZCI6MiwiaWF0IjoxNzA1MDE5NTg0LCJleHAiOjE3MDUxMDU5ODR9.vFszu24KBkcS7u53mIPJkh_7a2_zwJp0AqQLj05mFyc"
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        // TODO: urlRequest.url이 서버인지 체크하는 로직 추가
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: accessToken))
        completion(.success(urlRequest))
    }
//    
//    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
//        guard let response = request.task?.response as? HTTPURLResponse else {
//            completion(.doNotRetryWithError(error))
//            return
//        }
//        
//        // TODO: accessToken 만료시 refreshToken을 이용하여 accessToken 재발급
//        completion(.doNotRetry)
//    }
    
}
