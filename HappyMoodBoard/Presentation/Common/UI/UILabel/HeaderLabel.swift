//
//  HeaderLabel.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/24/24.
//

import Foundation
import UIKit

final class HeaderLabel: UILabel {
    
    init(labelText: String) {
        super.init(frame: .zero)
        
        // 줄 간격 설정
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.26
        
        // NSAttributedString을 사용하여 속성 설정
        let attributedString = NSMutableAttributedString(string: labelText)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        // UILabel에 속성 적용
        attributedText = attributedString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
