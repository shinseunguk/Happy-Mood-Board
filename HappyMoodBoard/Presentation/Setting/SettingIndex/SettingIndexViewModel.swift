//
//  SettingIndexViewModel.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/25/23.
//

import Foundation

import RxSwift
import RxCocoa

final class SettingIndexViewModel: ViewModel {
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let navigationBack: ControlEvent<Void>
        let mySettings: Observable<Void>
        let notificationSettings: Observable<Void>
        let termsOfService: Observable<Void>
        let privacyPolicy: Observable<Void>
        let openSourceLicense: Observable<Void>
        let leaveReview: Observable<Void>
        let versionInformation: Observable<Void>
        let logout: Observable<Void>
        let logoutAction: Observable<Void>
        let withdrawMembership: Observable<Void>
        let withdrawAction: Observable<Void>
    }
    
    struct Output {
        let checkVersion: Observable<String>
        let navigationBack: Observable<Void>
        let mySettings: Observable<Void>
        let notificationSettings: Observable<Void>
        let termsOfService: Observable<Void>
        let privacyPolicy: Observable<Void>
        let openSourceLicense: Observable<Void>
        let leaveReview: Observable<Void>
        let versionInformation: Observable<Bool>
        let logout: Observable<Void>
        let logoutSuccess: Observable<Void>
        let logoutError: Observable<String>
        let withdrawMembership: Observable<Void>
        let withdrawSuccess: Observable<Void>
        let withdrawError: Observable<String>
    }
    
    let disposeBag: DisposeBag = .init()
    
    func transform(input: Input) -> Output {
        // MARK: - 현재 앱버전과 서버에 올라가있는 버전을 체크하는 로직
        let compareVersion = input.viewWillAppear
            .flatMap { _ in
                return self.getLatestAppStoreVersion()
            }
            .map { result in
                if let version = result {
                    if version == fetchAppVersion() { // 앱 스토어 버전 == 현재 앱 버전
                        return "최신 버전이에요."
                    } else if version > fetchAppVersion() {
                        return "업데이트가 필요해요."
                    } else {
                        return "현재 앱 버전이 더 높아요."
                    }
                } else {
                    return "서버 연결 실패, 네트워크 상태를 확인해주세요."
                }
            }
        
        // MARK: - 현재 앱버전과 서버에 올라가있는 버전을 체크하여 앱스토어로 보냄
        let versionInformation = input.versionInformation
            .flatMap { _ in
                return self.getLatestAppStoreVersion()
            }
            .map { result in
                if let version = result {
                    if version > fetchAppVersion() {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            }
        
        // MARK: - 로그아웃 버튼 클릭 Action
        let logout = input.logoutAction
            .map {
                AuthTarget.logout(
                    .init(
                        deviceType: DeviceType.ios.rawValue,
                        deviceId: getDeviceUUID() ?? ""
                    )
                )
            }
            .debug("로그아웃")
            .flatMapLatest {
                ApiService().request(type: Empty.self, target: $0)
                    .materialize()
            }
            .share()
        
        let logoutSuccess = logout.elements()
            .do(onNext: { _ in
                UserDefaults.standard.removeObject(forKey: "autoLogin")
                UserDefaults.standard.removeObject(forKey: "accessToekn")
                UserDefaults.standard.removeObject(forKey: "refreshToken")
            })
            .map { _ in Void() }
        
        let logoutError = logout.errors()
            .map { $0.localizedDescription }
        
        
        // MARK: - 탈퇴하기 버튼 클릭 Action
        let withdraw = input.withdrawAction
            .map {
                MemberTarget.retire
            }
            .debug("탈퇴하기")
            .flatMapLatest {
                ApiService().request(type: Empty.self, target: $0)
                    .materialize()
            }
            .share()
        
        let withdrawSuccess = withdraw.elements()
            .do(onNext: { _ in
                UserDefaults.standard.removeObject(forKey: "autoLogin")
                UserDefaults.standard.removeObject(forKey: "accessToekn")
                UserDefaults.standard.removeObject(forKey: "refreshToken")
            })
            .map { _ in Void() }
        
        let withdrawError = withdraw.errors()
            .map { $0.localizedDescription }
        
        return Output(
            checkVersion: compareVersion,
            navigationBack: input.navigationBack.asObservable(),
            mySettings: input.mySettings,
            notificationSettings: input.notificationSettings,
            termsOfService: input.termsOfService,
            privacyPolicy: input.privacyPolicy,
            openSourceLicense: input.openSourceLicense,
            leaveReview: input.leaveReview,
            versionInformation: versionInformation,
            logout: input.logout,
            logoutSuccess: logoutSuccess,
            logoutError: logoutError,
            withdrawMembership: input.withdrawMembership,
            withdrawSuccess: withdrawSuccess,
            withdrawError: withdrawError
        )
    }
    
    /// 시스템 알림설정 확인 함수
    /// - Returns: <#description#>
    func isSystemNotificationEnabled() -> Observable<Bool> {
        return Observable.create { observer in
            let center = NotificationCenter.default
            let notificationObserver = center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { _ in
                let isEnabled = UIApplication.shared.currentUserNotificationSettings?.types != []
                observer.onNext(isEnabled)
            }

            // Initial check for notification status
            let isEnabled = UIApplication.shared.currentUserNotificationSettings?.types != []
            observer.onNext(isEnabled)

            return Disposables.create {
                center.removeObserver(notificationObserver)
            }
        }
    }
    
    /// 앱스토에 올라가있는 버전을 체크하는 함수
    /// - Returns: ex) 1.0.0 or nil
    func getLatestAppStoreVersion() -> Observable<String?> {
        return Observable.create { observer in
            guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create {}
            }
            
            let url = URL(string: "https://itunes.apple.com/kr/lookup?bundleId=\(bundleIdentifier)") // 여기에 앱의 번들 ID를 넣어주세요
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                guard let data = data, error == nil else {
                    observer.onNext(nil)
                    observer.onCompleted()
                    return
                }
                do {
//                    traceLog(String(data: data, encoding: .utf8))
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let results = json["results"] as? [[String: Any]],
                       let appStoreVersion = results.first?["version"] as? String {
                        traceLog(appStoreVersion)
                        observer.onNext(appStoreVersion)
                    } else {
                        observer.onNext(nil)
                    }
                    observer.onCompleted()
                } catch {
                    observer.onNext(nil)
                    observer.onCompleted()
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    /// 앱 스토어로 이동하는 함수
    func openAppStore() {
        // appID 넣어야 됨.
        let appID = "6455887973"
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)") else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
