//
//  CustomLabel.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/3/24.
//

import Foundation
import UIKit

final class CustomLabel: UILabel {
    init(text: String?, textColor: UIColor?, font: UIFont?) {
        super.init(frame: .zero)
        
        self.text = text
        self.textColor = textColor
        self.font = font
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
