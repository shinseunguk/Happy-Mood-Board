//
//  DayOfTheWeek.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/6/24.
//

import Foundation

enum DayOfTheWeek {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    case everyday
    
    var title: String {
        switch self {
        case .monday:
            return "월"
        case .tuesday:
            return "화"
        case .wednesday:
            return "수"
        case .thursday:
            return "목"
        case .friday:
            return "금"
        case .saturday:
            return "토"
        case .sunday:
            return "일"
        case .everyday:
            return "매일"
        }
    }
}
