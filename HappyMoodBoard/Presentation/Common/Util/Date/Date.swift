//
//  Date.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 1/17/24.
//

import Foundation

func convert24Hour(timeString: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"

    guard let date = dateFormatter.date(from: timeString) else {
        return nil
    }

    let twelveHourFormat = DateFormatter()
    twelveHourFormat.locale = Locale(identifier: "ko_KR")
    twelveHourFormat.dateFormat = "hh:mm"

    return twelveHourFormat.string(from: date)
}

func convertTo12HourFormat(timeString: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"

    guard let date = dateFormatter.date(from: timeString) else {
        return nil
    }

    let twelveHourFormat = DateFormatter()
    twelveHourFormat.locale = Locale(identifier: "ko_KR")
    twelveHourFormat.dateFormat = "a hh:mm"
    
    return twelveHourFormat.string(from: date)
}

func convertStringToDate(dateString: String, dateFormat: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat

    return dateFormatter.date(from: dateString)
}

func convertDateString(_ inputDateString: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"

    guard let date = dateFormatter.date(from: inputDateString) else {
        print("날짜 형식이 올바르지 않습니다.")
        return nil
    }

    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "yyyy.MM.dd"
    let resultString = outputFormatter.string(from: date)
    return resultString
}

/// 오늘 날짜 가져오기
/// - Returns: 오늘 날짜 가져오기
func getCurrentDateFormatted() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy.MM.dd"
    return dateFormatter.string(from: Date())
}


/// ex) 22:05 string를 (22,5)로 변환
/// - Parameter timeString: String값
/// - Returns: (hour, minute)
func parseTimeString(_ timeString: String) -> (hour: Int, minute: Int)? {
    let components = timeString.components(separatedBy: ":")
    
    // 유효한 컴포넌트가 두 개 있는지 확인
    guard components.count == 2,
          let hour = Int(components[0]),
          let minute = Int(components[1]) else {
        return nil
    }
    
    // 유효한 시간과 분 범위인지 확인
    guard (0...23).contains(hour),
          (0...59).contains(minute) else {
        return nil
    }
    
    return (hour, minute)
}
