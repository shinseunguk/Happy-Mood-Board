//
//  AccountView.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/3/24.
//

import Foundation
import UIKit

final class AccountView: UIView {
    
    var socialImage: UIImage?
    
    private let label = CustomLabel(
        text: nil,
        textColor: UIColor.black,
        font: UIFont(name: "Pretendard-Regular", size: 16)
    )
    
    // 닉네임
    private lazy var nicknameLabel = CustomLabel(
        text: nil,
        textColor: UIColor.gray500,
        font: UIFont(name: "Pretendard-Regular", size: 16)
        
    )
    private let disclosureButton = UIButton().then {
        $0.setImage(UIImage(named: "arrow.right"), for: .normal)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    // 연결된 계정
    private lazy var socialLoginLabel = CustomLabel(
        text: nil,
        textColor: UIColor.black,
        font: UIFont(name: "Pretendard-Regular", size: 16)
    )
    private let socialImageView = UIImageView().then {
        $0.image = UIImage(named: "KakaoLogin")
        $0.layer.cornerRadius = 4
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    // 이메일
    private lazy var emailLabel = CustomLabel(
        text: nil,
        textColor: UIColor.black,
        font: UIFont(name: "Pretendard-Regular", size: 16)
    )
    
    init(type: MyAccount) {
        super.init(frame: .zero)
 
        setupTitleLabel(type)
        
        switch type {
        case .nickname:
            typeNickname()
        case .connectAccount:
            typeConnectAccount()
        case .email:
            typeEmail()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTitleLabel(_ type: MyAccount) {
        self.addSubview(label)
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(24)
            $0.height.equalTo(40)
        }
        
        label.text = type.title
    }
    
    func typeNickname() {
        [
            nicknameLabel,
            disclosureButton
        ].forEach { self.addSubview($0) }
        
        nicknameLabel.snp.makeConstraints {
            $0.centerY.equalTo(label)
            $0.trailing.equalTo(disclosureButton.snp.leading).offset(-12)
        }
        
        disclosureButton.snp.makeConstraints {
            $0.centerY.equalTo(label)
            $0.trailing.equalTo(-24)
        }
    }
    
    func typeConnectAccount() {
        [
            socialImageView,
            socialLoginLabel
        ].forEach { self.addSubview($0) }
        
        socialImageView.snp.makeConstraints {
            $0.centerY.equalTo(label)
            $0.width.height.equalTo(24)
            $0.trailing.equalTo(socialLoginLabel.snp.leading).offset(-12)
        }
        
        socialLoginLabel.snp.makeConstraints {
            $0.centerY.equalTo(label)
            $0.trailing.equalTo(-24)
        }
    }
    
    func typeEmail() {
        addSubview(emailLabel)
        
        emailLabel.snp.makeConstraints {
            $0.centerY.equalTo(label)
            $0.trailing.equalTo(-24)
        }
    }
    
    func bindNickname(nickname: String) {
        nicknameLabel.text = nickname
    }
    
    func bindEmail(email: String) {
        emailLabel.text = email
    }
    
    func bindSocialLogin(provider: String) {
        
        switch provider {
        case ProviderType.apple.rawValue:
            socialImage = UIImage(named: "AppleLogin")
        case ProviderType.kakao.rawValue:
            socialImage = UIImage(named: "KakaoLogin")
        default:
            break
        }
        
        socialImageView.image = socialImage
        socialLoginLabel.text = provider
    }
}
