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


