//
//  NavigationTitle.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 12/22/23.
//

import Foundation
import UIKit

final class NavigationTitle: UIView {
    
    let titleLabel = UILabel().then {
        $0.font = UIFont(name: "Pretendard-Medium", size: 18)
        $0.textColor = .init(hexString: "#000000")
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        setupSubviews()
        setupLayouts()
        
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        [
            titleLabel
        ].forEach { addSubview($0) }
    }
    
    func setupLayouts() {
        titleLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}
