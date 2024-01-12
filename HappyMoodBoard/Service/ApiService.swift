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
                        return result.data
                    } catch {
                        // TODO: 성공시 디코딩 에러 처리
                        print(
                            target.path,
                            "💥💥💥",
                            error.localizedDescription,
                            response.statusCode,
                            String(data: data, encoding: .utf8) ?? ""
                        )
                        return nil
                    }
                default:
                    do {
                        let apiError = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        // TODO: 실패시 에러 처리 (ex: Alert)
                        print(
                            target.path,
                            "💥💥💥",
                            response.statusCode,
                            apiError
                        )
                        return nil
                    } catch {
                        // TODO: 실패시 디코딩 에러 처리
                        print(
                            target.path,
                            "💥💥💥",
                            error.localizedDescription,
                            response.statusCode,
                            String(data: data, encoding: .utf8) ?? ""
                        )
                        return nil
                    }
                }
            }
    }
}
