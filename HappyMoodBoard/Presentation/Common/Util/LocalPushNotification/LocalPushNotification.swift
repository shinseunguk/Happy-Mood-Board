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

func scheduleNotificationAtSpecificTime(handler: Bool, hourMinute: (Int, Int)) {
    if handler {
        // 알림 내용 설정
        let content = UNMutableNotificationContent()
        content.title = "행복한 순간을 담아볼 시간이에요🍯"
        content.body = "지금 기록하러 가기"
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hourMinute.0
        dateComponents.minute = hourMinute.1
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
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
    } else {
        traceLog("로컬 푸시 알림 스케줄링 해제")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Constants.localPushNotification])
    }
}
