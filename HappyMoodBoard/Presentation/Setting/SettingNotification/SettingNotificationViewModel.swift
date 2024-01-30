//
//  SettingNotificationViewModel.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 1/5/24.
//

import Foundation

import RxSwift

final class SettingNotificationViewModel: ViewModel {
    
    let disposeBag: DisposeBag = .init()
    
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
        let viewWillAppearErrorMessage: Observable<String>
        let navigateToBack: Observable<Void>
        let recordPush: Observable<Bool>
        let recordPushErrorMessage: Observable<String>
        let dayOfWeek: Observable<[Int]>
        let dayOfWeekErrorMessage: Observable<String>
        let pushTime: Observable<String>
        let pushTimeErrorMessage: Observable<String>
        let marketingPush: Observable<Bool>
        let marketingErrorMessage: Observable<String>
        let timeButtonEvent: Observable<Void>
        let pickerViewCancel: Observable<Void>
        let pickerViewSave: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let recordPush = PublishSubject<Bool>()
        let dayOfWeek = PublishSubject<[Int]>()
        let pushTime = PublishSubject<String>()
        let timeSaveString = PublishSubject<String>()
        let marketing = PublishSubject<Bool>()
        
        // MARK: - /api/notification/v1/member, 알림 설정 조회
        let notificationSettings = input.viewWillAppear
            .map {
                NotificationTarget.member
            }
            .flatMapLatest {
                ApiService().request(type: MemberResponse.self, target: $0)
                    .materialize()
            }
            .share()
        
        let notificationSettingsFailure = notificationSettings.errors().map { $0.localizedDescription }
        
        notificationSettings.elements()
            .subscribe(onNext: { value in
                if let active = value?.happyItem.active,
                   let dayOfWeek = value?.happyItem.dayOfWeek,
                   let time = value?.happyItem.time {
                    
                    let parsingTime = parseTimeString(time) ?? (20, 0)
                    scheduleNotificationAtSpecificTime(
                        handler: active,
                        hourMinute: parsingTime,
                        dayOfWeek: dayOfWeek
                    )
                }
            })
            .disposed(by: disposeBag)
        
        // MARK: - 행복아이템 기록 알림 받기
        notificationSettings.elements()
            .filter {
                $0 != nil
            }
            .compactMap {
                $0?.happyItem.active
            }
            .bind(to: recordPush)
            .disposed(by: disposeBag)

        // MARK: - 요일
        notificationSettings.elements()
            .filter {
                $0 != nil
            }
            .compactMap {
                $0?.happyItem.dayOfWeek
            }
            .bind(to: dayOfWeek)
            .disposed(by: disposeBag)
        
        // MARK: - 시간
        notificationSettings.elements()
            .filter {
                $0 != nil
            }
            .compactMap {
                $0?.happyItem.time
            }
            .bind(to: pushTime)
            .disposed(by: disposeBag)
        
        // MARK: - 시간 버튼 터치시 HH:mm으로 format
        let dateString = input.pickerViewEvent
            .distinctUntilChanged()
            .map { selectedDate in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                
                let formattedDate = dateFormatter.string(from: selectedDate)
                return formattedDate
            }
            .share()
        
        // MARK: - pickerview의 [저장] 버튼 터치시 HH:mm으로 bind timeSaveString
        input.pickerViewSave
            .flatMapLatest { _ in
                return dateString.take(1)
            }
            .bind(to: timeSaveString)
            .disposed(by: disposeBag)
        
        // MARK: - 이벤트·혜택 알림 받기
        notificationSettings.elements()
            .filter {
                $0 != nil
            }
            .compactMap {
                $0?.marketing.active
            }
            .bind(to: marketing)
            .disposed(by: disposeBag)
        
        // MARK: - /api/notification/v1/member/happy-item, 행복 아이템 알림 설정 변경
        let recordPushEvent = input.recordPushEvent
            .withLatestFrom(dayOfWeek) { ($0, $1) }
            .withLatestFrom(pushTime) { ($0, $1) }
            .map { values in
                let ((record, dayOfWeek), time) = values
                
                return NotificationTarget.happyItem(
                    .init(
                        active: record,
                        dayOfWeek: dayOfWeek,
                        time: time
                    )
                )
            }
            .flatMapLatest {
                ApiService().request(type: HappyItem.self, target: $0)
                    .materialize()
            }
        
        recordPushEvent.elements()
            .do(onNext: {
                if let active = $0?.active,
                   let time = $0?.time,
                   let dayOfWeek = $0?.dayOfWeek,
                   let parsingTime = parseTimeString(time) {
                    
                    scheduleNotificationAtSpecificTime(
                        handler: active,
                        hourMinute: parsingTime,
                        dayOfWeek: dayOfWeek
                    )
                }
            })
            .compactMap {
                $0?.active
            }
            .bind(to: recordPush)
            .disposed(by: disposeBag)
        
        let recordEventError = recordPushEvent.errors().map { $0.localizedDescription }
            
        
        // MARK: - /api/notification/v1/member/happy-item, 행복 아이템 알림 설정 변경
        let dayOfWeekEvent = input.dayOfWeekEvent
            .withLatestFrom(recordPush) { ($1, $0) }
            .withLatestFrom(pushTime) { ($0, $1) }
            .map { values in
                let ((record, dayOfWeek), time) = values
                
                return NotificationTarget.happyItem(
                    .init(
                        active: record,
                        dayOfWeek: dayOfWeek,
                        time: time
                    )
                )
            }
            .flatMapLatest {
                ApiService().request(type: HappyItem.self, target: $0)
                    .materialize()
            }
        
        dayOfWeekEvent.elements()
            .do(onNext: {
                if let active = $0?.active,
                   let time = $0?.time,
                   let dayOfWeek = $0?.dayOfWeek,
                   let parsingTime = parseTimeString(time) {
                    
                    scheduleNotificationAtSpecificTime(
                        handler: active,
                        hourMinute: parsingTime,
                        dayOfWeek: dayOfWeek
                    )
                }
            })
            .compactMap {
                $0?.dayOfWeek
            }
            .bind(to: dayOfWeek)
            .disposed(by: disposeBag)
        
        let dayOfWeekEventError = dayOfWeekEvent.errors().map { $0.localizedDescription }
        
        // MARK: - /api/notification/v1/member/happy-item, 행복 아이템 알림 설정 변경
        let timeEvent = timeSaveString
            .withLatestFrom(recordPush) { ($0, $1) }
            .withLatestFrom(dayOfWeek) { ($0, $1) }
            .map { values in
                let ((time, record), dayOfWeek) = values
                
                return NotificationTarget.happyItem(
                    .init(
                        active: record,
                        dayOfWeek: dayOfWeek,
                        time: time
                    )
                )
            }
            .flatMapLatest {
                ApiService().request(type: HappyItem.self, target: $0)
                    .materialize()
            }
        
        timeEvent.elements()
            .do(onNext: {
                if let active = $0?.active,
                   let time = $0?.time,
                   let dayOfWeek = $0?.dayOfWeek,
                   let parsingTime = parseTimeString(time) {
                    
                    scheduleNotificationAtSpecificTime(
                        handler: active,
                        hourMinute: parsingTime,
                        dayOfWeek: dayOfWeek
                    )
                }
            })
            .compactMap {
                $0?.time
            }
            .bind(to: pushTime)
            .disposed(by: disposeBag)
        
        let timeEventError = timeEvent.errors().map { $0.localizedDescription }
        
        // MARK: - /api/notification/v1/member/marketing, 이벤트·혜택 알림 설정 변경
        let marketingPushEvent = input.marketingPushEvent
            .map {
                NotificationTarget.marketing(
                    .init(
                        active: $0
                    )
                )
            }
            .flatMapLatest {
                ApiService().request(type: MarketingResponse.self, target: $0)
                    .materialize()
            }
        
        marketingPushEvent.elements()
            .compactMap {
                $0?.active
            }
            .bind(to: marketing)
            .disposed(by: disposeBag)
        
        let marketingPushEventError = marketingPushEvent.errors().map { $0.localizedDescription }
            
        return Output(
            viewWillAppearErrorMessage: notificationSettingsFailure,
            navigateToBack: input.navigateToBack,
            recordPush: recordPush,
            recordPushErrorMessage: recordEventError,
            dayOfWeek: dayOfWeek,
            dayOfWeekErrorMessage: dayOfWeekEventError,
            pushTime: pushTime,
            pushTimeErrorMessage: timeEventError,
            marketingPush: marketing,
            marketingErrorMessage: marketingPushEventError,
            timeButtonEvent: input.timeButtonEvent,
            pickerViewCancel: input.pickerViewCancel,
            pickerViewSave: input.pickerViewSave
        )
    }
}
