//
//  SettingNotificationViewModel.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 1/5/24.
//

import Foundation

import RxSwift

final class SettingNotificationViewModel: ViewModel {
    struct Input {
        let navigateToBack: Observable<Void>
        let viewWillAppear: Observable<Void>
        let recordPushEvent: Observable<Bool>
        let dayOfWeekEvent: Observable<[Int]>
        let timeButtonEvent: Observable<Void>
        let pickerViewEvent: Observable<Date>
        let pickerViewCancel: Observable<Void>
        let pickerViewSave: Observable<Void>
        let marketingPushEvent: Observable<Bool>
    }
    
    struct Output {
        let navigateToBack: Observable<Void>
        let initRecordPush: Observable<Bool>
        let initDayOfWeek: Observable<[Int]>
        let initTime: Observable<String>
        let initMarketingPush: Observable<Bool>
        let timeButtonEvent: Observable<Void>
        let pickerViewCancel: Observable<Void>
        let pickerViewSave: Observable<Void>
        let responseRecordPush: Observable<Bool>
        let responseDayOfWeek: Observable<[Int]>
        let responseTime: Observable<String>
        let responseMarketingPush: Observable<Bool>
    }
    
    func transform(input: Input) -> Output {
        let initRecordPush: Observable<Bool>
        let initDayOfWeek: Observable<[Int]>
        let initTime: Observable<String>
        let dateString: Observable<String>
        let timeSaveString: Observable<String>
        let marketingActive: Observable<Bool>
        let notificationSettings: Observable<MemberResponse?>
        
        // MARK: - /api/notification/v1/member, 알림 설정 조회
        notificationSettings = input.viewWillAppear
            .map {
                NotificationTarget.member
            }
            .flatMapLatest {
                ApiService().request(type: MemberResponse.self, target: $0)
            }
            .share()
        
        // MARK: - 행복아이템 기록 알림 받기
        initRecordPush = notificationSettings
            .filter {
                $0 != nil
            }
            .compactMap {
                $0?.happyItem.active
            }

        // MARK: - 요일
        initDayOfWeek = notificationSettings
            .filter {
                $0 != nil
            }
            .compactMap {
                $0?.happyItem.dayOfWeek
            }
        
        // MARK: - 시간
        initTime = notificationSettings
            .filter {
                $0 != nil
            }
            .compactMap {
                $0?.happyItem.time
            }
        
        dateString = input.pickerViewEvent
            .distinctUntilChanged()
            .map { selectedDate in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                
                let formattedDate = dateFormatter.string(from: selectedDate)
                return formattedDate
            }
            .share()
        
        timeSaveString = input.pickerViewSave
            .flatMapLatest { _ in
                return dateString.take(1)
            }
        
        // MARK: - 마케팅 동의 알림
        marketingActive = notificationSettings
            .filter {
                $0 != nil
            }
            .compactMap {
                $0?.marketing.active
            }
        
        // MARK: - /api/notification/v1/member/happy-item, 행복 아이템 알림 설정 변경
        let responseRecordPush = Observable.combineLatest(input.recordPushEvent,
            Observable.combineLatest(initDayOfWeek, initTime)
        )
        .map { (recordPush, tuple) in
            let (dayOfWeek, time) = tuple
            traceLog(recordPush)
            traceLog(dayOfWeek)
            traceLog(time)
            return NotificationTarget.happyItem(
                .init(
                    active: recordPush,
                    dayOfWeek: dayOfWeek,
                    time: time
                )
            )
        }
        .flatMapLatest {
            ApiService().request(type: HappyItem.self, target: $0)
        }
        .compactMap {
            $0?.active
        }
        
        // MARK: - /api/notification/v1/member/happy-item, 행복 아이템 알림 설정 변경, 요일 설정 변경
        let responseDayOfWeek = Observable.combineLatest(input.dayOfWeekEvent,
            Observable.combineLatest(initRecordPush, initTime)
        )
        .map { (dayOfWeek, tuple) in
            let (recordPush, time) = tuple
            traceLog(recordPush)
            traceLog(dayOfWeek)
            traceLog(time)
            return NotificationTarget.happyItem(
                .init(
                    active: recordPush,
                    dayOfWeek: dayOfWeek,
                    time: time
                )
            )
        }
        .flatMapLatest {
            ApiService().request(type: HappyItem.self, target: $0)
        }
        .compactMap {
            $0?.dayOfWeek
        }
        
//        // MARK: - /api/notification/v1/member/happy-item, 행복 아이템 알림 설정 변경, 시간 설정 변경
        let responseTime = Observable.combineLatest(timeSaveString,
            Observable.combineLatest(initRecordPush, initDayOfWeek)
        )
        .map { (time, tuple) in
            let (recordPush, dayOfWeek) = tuple
            traceLog(recordPush)
            traceLog(dayOfWeek)
            traceLog(time)
            return NotificationTarget.happyItem(
                .init(
                    active: recordPush,
                    dayOfWeek: dayOfWeek,
                    time: time
                )
            )
        }
        .flatMapLatest {
            ApiService().request(type: HappyItem.self, target: $0)
        }
        .compactMap {
            $0?.time
        }
        
        // MARK: - /api/notification/v1/member/marketing, 마케팅 알림 설정 변경
        let responseMarketingPush = input.marketingPushEvent
            .map {
                NotificationTarget.marketing(
                    .init(
                        active: $0
                    )
                )
            }
            .flatMapLatest {
                ApiService().request(type: MarketingResponse.self, target: $0)
            }
            .compactMap {
                $0?.active
            }
            
        return Output(
            navigateToBack: input.navigateToBack,
            initRecordPush: initRecordPush,
            initDayOfWeek: initDayOfWeek,
            initTime: initTime,
            initMarketingPush: marketingActive,
            timeButtonEvent: input.timeButtonEvent,
            pickerViewCancel: input.pickerViewCancel,
            pickerViewSave: input.pickerViewSave,
            responseRecordPush: responseRecordPush,
            responseDayOfWeek: responseDayOfWeek,
            responseTime: responseTime,
            responseMarketingPush: responseMarketingPush
        )
    }
}
