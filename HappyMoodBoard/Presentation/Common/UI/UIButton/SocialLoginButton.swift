//
//  SocialLoginButton.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/28/23.
//

import Foundation

import Then
import SnapKit

final class SocialLoginButton: UIButton {
    
    private let socialLoginIcon = UIImageView()
    
    init(type: LoginType) {
        super.init(frame: .zero)
        
        self.layer.cornerRadius = 25
        self.setTitleColor(.black, for: .normal)
        self.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 18)
        
        [
            socialLoginIcon
        ].forEach { self.addSubview($0) }
        
        socialLoginIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(49)
            $0.width.height.equalTo(32)
        }
        
        let handler = type.title
        
        switch handler {
        case "kakao":
            self.backgroundColor = .yellow100
            self.setTitle("카카오로 계속하기", for: .normal)
            
            self.socialLoginIcon.image = .init(named: "KakaoLogo")
        case "apple":
            self.backgroundColor = .white
            self.setTitle("Apple로 계속하기", for: .normal)
            self.layer.borderWidth = 1
            
            self.socialLoginIcon.image = .init(named: "AppleLogo")
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
