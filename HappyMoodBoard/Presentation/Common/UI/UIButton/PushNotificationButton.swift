//
//  PushNotificationButton.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/6/24.
//

import Foundation
import UIKit

final class PushNotificationButton: UIButton {
    
    init(title: String?, titleColor: UIColor, titleFont: UIFont, backgroundColor: UIColor, radius: CGFloat) {
        super.init(frame: .zero)
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = titleFont
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = radius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
