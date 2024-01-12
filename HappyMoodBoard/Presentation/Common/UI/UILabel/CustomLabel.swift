//
//  CustomLabel.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/3/24.
//

import Foundation
import UIKit

final class CustomLabel: UILabel {
    init(font: UIFont?, textColor: UIColor?, text: String?) {
        super.init(frame: .zero)
        
        self.font = font
        self.textColor = textColor
        self.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
