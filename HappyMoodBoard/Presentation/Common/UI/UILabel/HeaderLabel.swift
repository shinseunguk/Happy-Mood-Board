//
//  HeaderLabel.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/24/24.
//

import UIKit

final class HeaderLabel: PaddingLabel {
    
    enum Constants {
        static let verticalInset: CGFloat = 8
        static let horizontalInset: CGFloat = 0
        static let lineHeightMultiple: CGFloat = 1.26
    }
    
    init(labelText: String) {
        super.init(
            inset: .init(
                top: Constants.verticalInset,
                left: Constants.horizontalInset,
                bottom: Constants.verticalInset,
                right: Constants.horizontalInset
            )
        )
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = Constants.lineHeightMultiple
        attributedText = .init(string: labelText, attributes: [
            .paragraphStyle: paragraphStyle
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
