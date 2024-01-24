//
//  LoginViewModel.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/28/23.
//

import Foundation

import RxSwift
import RxCocoa

import AuthenticationServices

import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

import RxKakaoSDKCommon
import RxKakaoSDKAuth
import RxKakaoSDKUser

final class LoginViewModel: NSObject, ViewModel {
    
    struct Input {
        let kakaoLogin: Observable<Void>
        let appleLogin: Observable<Void>
    }
    
    struct Output {
        let success: Observable<String?>
    }
    
    let disposeBag: DisposeBag = .init()
    let socialLoginSubject = PublishSubject<SocialLoginParameters>()
    
    func transform(input: Input) -> Output {
        let loginResult: Observable<String?>
        
        input.kakaoLogin
            .subscribe(onNext: { [weak self] in
                // TODO: 실제 기기에서 테스트 해야함. 현재 Certificates, Identifiers & Profiles에 디바이스 등록이 제한되어 있음....
                if (UserApi.isKakaoTalkLoginAvailable()) {
                    UserApi.shared.rx.loginWithKakaoTalk()
                        .subscribe(onNext:{ [weak self] (oAuthToken) in
                            let accessToken = oAuthToken.accessToken
                            
                            if let deviceToken = UserDefaults.standard.string(forKey: "deviceToken"),
                               let deviceId = getDeviceUUID() {
                                let paramters = SocialLoginParameters(
                                    accessToken: accessToken,
                                    provider: ProviderType.kakao.rawValue,
                                    deviceToken: deviceToken,
                                    deviceType: DeviceType.ios.rawValue,
                                    deviceId: deviceId
                                )
                                
                                self?.socialLoginSubject.onNext(paramters)
                            }
                        }, onError: {error in
                            print(error)
                        })
                    //                        .disposed(by: self?.disposeBag)
                } else {
                    UserApi.shared.rx.loginWithKakaoAccount(prompts: [.Login])
                        .subscribe(onNext: {  [weak self] (oAuthToken) in
                            let accessToken = oAuthToken.accessToken
                            
                            if let deviceToken = UserDefaults.standard.string(forKey: "deviceToken"),
                               let deviceId = getDeviceUUID() {
                                let paramters = SocialLoginParameters(
                                    accessToken: accessToken,
                                    provider: ProviderType.kakao.rawValue,
                                    deviceToken: deviceToken,
                                    deviceType: DeviceType.ios.rawValue,
                                    deviceId: deviceId
                                )
                                
                                self?.socialLoginSubject.onNext(paramters)
                            }
                        })
                }
            })
            .disposed(by: disposeBag)
        
        input.appleLogin
            .subscribe(onNext: { [weak self] in
                self?.performAppleSignIn()
            })
            .disposed(by: disposeBag)
        
        loginResult = socialLoginSubject.map {
            // TODO: 운영 API
            AuthTarget.login(
                .init(
                    accessToken: $0.accessToken,
                    provider: $0.provider,
                    deviceToken: $0.deviceToken,
                    deviceType: $0.deviceType,
                    deviceId: $0.deviceId
                )
            )
            // TODO: 개발 API
//            AuthTarget.internalLogin(
//                .init(
//                    provider: $0.provider,
//                    providerId: "12345",
//                    deviceToken: $0.deviceToken,
//                    deviceType: $0.deviceType,
//                    deviceId: $0.deviceId
//                )
//            )
        }
        .do(onNext: {
            dump($0)
        })
        .debug("소셜 로그인(애플)")
        .flatMapLatest {
            ApiService().request(type: SocialLoginResponse.self, target: $0)
        }
        .filter {
            $0 != nil
        }
        .map { result in
            if let response = result {
                UserDefaults.standard.set(response.accessToken, forKey: "accessToken")
                UserDefaults.standard.set(response.refreshToken, forKey: "refreshToken")
                
                return response.status
            } else {
                return nil
            }
        }
        
        return Output(
            success: loginResult.asObservable()
        )
    }
    
    func performAppleSignIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email] // 유저로 부터 알 수 있는 정보들(name, email)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension LoginViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return LoginViewController().view.window!
    }
    
    // MARK: - 애플 로그인 성공
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // You can create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            if  let authorizationCode = appleIDCredential.authorizationCode,
                let identityToken = appleIDCredential.identityToken,
                let authCodeString = String(data: authorizationCode, encoding: .utf8),
                let identifyTokenString = String(data: identityToken, encoding: .utf8),
                let deviceId = getDeviceUUID() {
                print("authorizationCode: \(authorizationCode)")
                print("identityToken: \(identityToken)")
                print("authCodeString: \(authCodeString)")
                print("identifyTokenString: \(identifyTokenString)")
                
                parseAppleIdentityToken(identityToken: identifyTokenString)
                
                let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") ?? "123456789" 
                
                let paramters = SocialLoginParameters(
                    accessToken: identifyTokenString,
                    provider: ProviderType.apple.rawValue,
                    deviceToken: deviceToken,
                    deviceType: DeviceType.ios.rawValue,
                    deviceId: deviceId
                )
                
                socialLoginSubject.onNext(paramters)
            }
            
            print("useridentifier: \(userIdentifier)")
            print("fullName: \(fullName)")
            print("email: \(email)")
            
            //Move to MainPage
            //let validVC = SignValidViewController()
            //validVC.modalPresentationStyle = .fullScreen
            //present(validVC, animated: true, completion: nil)
        default:
            break
        }
    }
    
    // MARK: - 애플 로그인 실패(유저의 취소도 포함)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("login failed - \(error.localizedDescription)")
    }
    
    /// 사용자 정보 가져오기
    private func kakaoGetUserInfo() {
        UserApi.shared.rx.me()
            .subscribe (onSuccess:{ user in
                print("me() success.")

                //do something
                let userName = user.kakaoAccount?.name
                let userEmail = user.kakaoAccount?.email
                let userGender = user.kakaoAccount?.gender
                let userProfile = user.kakaoAccount?.profile?.profileImageUrl
                let userBirthYear = user.kakaoAccount?.birthyear

                traceLog("user name : \(userName)\n userEmail : \(userEmail)\n userGender : \(userGender), userBirthYear : \(userBirthYear)\n userProfile : \(userProfile)")
                
                print("user - \(user)")

//                if userEmail == nil {
//                    self.kakaoRequestAgreement()
//                    return
//                }

//                self.textField.text = contentText

            }, onFailure: {error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
}
