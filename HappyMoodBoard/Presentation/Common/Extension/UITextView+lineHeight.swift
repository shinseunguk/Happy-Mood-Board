//
//  UITextView+lineHeight.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/28.
//

import UIKit

extension UITextView {
    func setTextWithLineHeight(text: String?, lineHeight: CGFloat) {
        if let text = text {
            let style = NSMutableParagraphStyle()
            style.lineHeightMultiple = lineHeight
            let attrString = NSAttributedString(string: text, attributes: [.paragraphStyle: style])
            self.attributedText = attrString
        }
    }
}
