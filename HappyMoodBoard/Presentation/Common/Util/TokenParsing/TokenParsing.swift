//
//  TokenParsing.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 1/18/24.
//

import Foundation
import JWTDecode

func parseAppleIdentityToken(identityToken: String) {
    do {
        // JWT 디코딩
        let jwt = try decode(jwt: identityToken)
        
        // 클레임에서 JSON 객체 추출
        if let json = jwt.body as? [String: Any] {
            traceLog("Decoded JSON: \(json)")
            
            // 여기서부터는 필요한 클레임을 사용하여 로직을 추가할 수 있습니다.
            if let sub = json["sub"] as? String {
                traceLog("Subject: \(sub)")
            }
            
            if let email = json["email"] as? String {
                traceLog("Email: \(email)")
            }
            
            // 필요한 클레임들을 사용하여 추가적인 로직을 구현할 수 있습니다.
        } else {
            traceLog("Failed to decode identity token.")
        }
    } catch {
        traceLog("Error decoding identity token: \(error)")
    }
}
