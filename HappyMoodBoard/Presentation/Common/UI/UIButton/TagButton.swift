//
//  TagButton.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/21/24.
//

import Foundation
import UIKit

class TagButton: UIButton {
    init(title: String?, bgColor: UIColor?) {
        super.init(frame: .zero)
        setupButton(title: title, bgColor: bgColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupButton(title: String?, bgColor: UIColor?) {
        setTitle(title, for: .normal)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
        backgroundColor = .white
        layer.cornerRadius = 13
        layer.borderWidth = 1
        layer.borderColor = bgColor?.cgColor
        
        // Content hugging priority 설정하여 버튼의 크기를 글자 크기에 맞게 동적으로 조절
        contentHuggingPriority(for: .horizontal)
        contentCompressionResistancePriority(for: .horizontal)
        
        // 좌우 여백 설정
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    }
    
    override var intrinsicContentSize: CGSize {
        let originalSize = super.intrinsicContentSize
        let increasedWidth = originalSize.width + titleEdgeInsets.left + titleEdgeInsets.right
        let increasedHeight = originalSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom
        return CGSize(width: increasedWidth, height: increasedHeight)
    }
}
