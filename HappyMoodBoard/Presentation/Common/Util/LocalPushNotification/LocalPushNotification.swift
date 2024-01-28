//
//  LocalPushNotification.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/28/24.
//

import Foundation

import UIKit

private enum Constants {
    static let localPushNotification = "specificTimeNotification"
}

func scheduleNotificationAtSpecificTime(handler: Bool, hourMinute: (Int, Int), dayOfWeek: [Int]) {
    
    let modifyDayOfWeek = modifyDayOfWeek(dayOfWeek: dayOfWeek)
    if handler {
        
        for i in modifyDayOfWeek {
            // 알림 내용 설정
            let content = UNMutableNotificationContent()
            content.title = "행복한 순간을 담아볼 시간이에요🍯"
            content.body = "지금 기록하러 가기"
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = hourMinute.0
            dateComponents.minute = hourMinute.1
            dateComponents.weekday = i
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // 알림 요청 생성
            let request = UNNotificationRequest(
                identifier: Constants.localPushNotification,
                content: content,
                trigger: trigger
            )
            
            // 알림 스케줄링
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    traceLog("로컬 푸시 알림 스케줄링 실패: \(error)")
                } else {
                    traceLog("로컬 푸시 알림이 성공적으로 스케줄링됨 \(hourMinute.0)시 \(hourMinute.1)분")
                }
            }
        }
    } else {
        traceLog("로컬 푸시 알림 스케줄링 해제")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Constants.localPushNotification])
    }
}

/// (월,화,수,목,금)기준 서버 return은 [1,2,3,4,5] 로 됨
/// 그러나 apple Push Noti는 [2, 3, 4, 5, 6]임
/// - Parameter dayOfWeek: 서버 Response
/// - Returns: applePush Noti
func modifyDayOfWeek(dayOfWeek: [Int]) -> [Int] {
    var modifiedArray = dayOfWeek.map { $0 + 1 }

    if modifiedArray.contains(8) {
        if let index = modifiedArray.firstIndex(of: 8) {
            modifiedArray[index] = 1
        }
    }
    
    return modifiedArray
}
