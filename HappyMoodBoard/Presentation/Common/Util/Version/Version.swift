//
//  Version.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/25/23.
//

import Foundation

func fetchAppVersion() -> String {
    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        return appVersion
    } else {
        return "버전 정보 가져오기 실패"
    }
}
