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
        let navigateToBack: Observable<Void>
        let recordPush: Observable<Bool>
        let dayOfWeek: Observable<[Int]>
        let pushTime: Observable<String>
        let marketingPush: Observable<Bool>
        let timeButtonEvent: Observable<Void>
        let pickerViewCancel: Observable<Void>
        let pickerViewSave: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let recordPush = PublishSubject<Bool>()
        
        let dayOfWeek = PublishSubject<[Int]>()
        
        let pushTime = PublishSubject<String>()
        let dateString: Observable<String>
        let timeSaveString = PublishSubject<String>()
        
        let marketing = PublishSubject<Bool>()
        
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
        notificationSettings
            .filter {
                $0 != nil
            }
            .compactMap {
                $0?.happyItem.active
            }
            .bind(to: recordPush)
            .disposed(by: disposeBag)

        // MARK: - 요일
        notificationSettings
            .filter {
                $0 != nil
            }
            .compactMap {
                $0?.happyItem.dayOfWeek
            }
            .bind(to: dayOfWeek)
            .disposed(by: disposeBag)
        
        // MARK: - 시간
        notificationSettings
            .filter {
                $0 != nil
            }
            .compactMap {
                $0?.happyItem.time
            }
            .bind(to: pushTime)
            .disposed(by: disposeBag)
        
        // MARK: - 시간 버튼 터치시 HH:mm으로 format
        dateString = input.pickerViewEvent
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
        notificationSettings
            .filter {
                $0 != nil
            }
            .compactMap {
                $0?.marketing.active
            }
            .bind(to: marketing)
            .disposed(by: disposeBag)
        
        // MARK: - /api/notification/v1/member/happy-item, 행복 아이템 알림 설정 변경
        input.recordPushEvent
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
            }
            .compactMap {
                $0?.active
            }
            .bind(to: recordPush)
            .disposed(by: disposeBag)
        
        // MARK: - /api/notification/v1/member/happy-item, 행복 아이템 알림 설정 변경
        input.dayOfWeekEvent
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
            }
            .compactMap {
                $0?.dayOfWeek
            }
            .bind(to: dayOfWeek)
            .disposed(by: disposeBag)
        
        // MARK: - /api/notification/v1/member/happy-item, 행복 아이템 알림 설정 변경
        timeSaveString
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
            }
            .compactMap {
                $0?.time
            }
            .bind(to: pushTime)
            .disposed(by: disposeBag)
        
        // MARK: - /api/notification/v1/member/marketing, 이벤트·혜택 알림 설정 변경
        input.marketingPushEvent
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
            .bind(to: marketing)
            .disposed(by: disposeBag)
            
        return Output(
            navigateToBack: input.navigateToBack,
            recordPush: recordPush,
            dayOfWeek: dayOfWeek,
            pushTime: pushTime,
            marketingPush: marketing,
            timeButtonEvent: input.timeButtonEvent,
            pickerViewCancel: input.pickerViewCancel,
            pickerViewSave: input.pickerViewSave
        )
    }
}
